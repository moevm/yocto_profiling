from oeqa.selftest.case import OESelftestTestCase
from oeqa.utils.httpserver import HTTPService
from oeqa.utils.commands import bitbake, runCmd, CommandError
import unittest
import tempfile
import shutil
import os
from pathlib import Path
import logging
import time
import subprocess

SERVERS_COUNTS = [2, 3, 10]

class SstateMirrorsTests(OESelftestTestCase):
    SSTATE_CACHE_PATH = Path("/path/to/sstate-cache")
    OE_INIT_SCRIPT = "/path/to/oe-init-build-env"
    HASH_SERVER_WORKDIR = Path('/path/to/hashserv_dir')
    HASH_SERVER_IP = "127.0.0.1"
    LOG_PATH = '/path/to/result.log'
    HASH_SERVER_PORT = 8686
    HTTP_START_PORT = 9000

    def setUp(self):
        super().setUp()

        self.logger = logging.getLogger("SstateMirrorsTest")
        self.logger.setLevel(logging.INFO)
        handler = logging.FileHandler(self.LOG_PATH)
        handler.setLevel(logging.INFO)
        self.logger.addHandler(handler)

        self.server_processes = []
        self.server_dirs = []
        self.server_urls = []
        self.server_logs = []

    def _start_hash_server(self):
        self.HASH_SERVER_WORKDIR.mkdir(parents=True, exist_ok=True)
        self.hashserv_log = self.HASH_SERVER_WORKDIR / "hashserv.log"

        env_command = (
            f"bash -c '"
            f"cd {self.HASH_SERVER_WORKDIR} && "
            f"source {self.OE_INIT_SCRIPT} > /dev/null && "
            f"cd .. && "
            f"bitbake-hashserv --bind {self.HASH_SERVER_IP}:{self.HASH_SERVER_PORT}"
            f"'"
        )
        self.logger.info(f"Starting hash server with: {env_command}")

        log_file = open(self.hashserv_log, "w")
        self.hashserv_process = subprocess.Popen(env_command, shell=True, stdout=log_file, stderr=log_file)

        self.append_config(f'''
BB_HASHSERVE = "auto"
BB_SIGNATURE_HANDLER = "OEEquivHash"
BB_HASHSERVE_UPSTREAM = "{self.HASH_SERVER_IP}:{self.HASH_SERVER_PORT}"
        ''')

    def _stop_hash_server(self):
        if hasattr(self, 'hashserv_process'):
            self.hashserv_process.terminate()
            self.hashserv_process.wait()

    def _start_sstate_servers(self, servers_num: int):
        self.servers_num = servers_num
        self._prepare_servers()
        self._start_servers()
        self._set_sstate_mirrors()

    def _stop_sstate_servers(self):
        for s in self.server_processes:
            s.stop()

        for i, log_path in enumerate(self.server_logs):
            port = self.HTTP_START_PORT + i
            logger_name = f"HTTPServer-{port}"
            logger = logging.getLogger(logger_name)
            handlers = logger.handlers[:]
            for handler in handlers:
                handler.close()
                logger.removeHandler(handler)

        for d in self.server_dirs:
            shutil.rmtree(d)

        self.server_processes = []
        self.server_dirs = []
        self.server_urls = []
        self.server_logs = []

    def _clear_sstate_cache(self):
        tmp_cache = Path(self.builddir) / "tmp"
        if tmp_cache.exists():
            shutil.rmtree(tmp_cache)

    def _exit_test(self):
        self._stop_sstate_servers()
        self._stop_hash_server()
        self.fail(f'Command failed to execute\n')

    def _run_build_and_measure(self) -> float:
        start = time.time()
        try:
            result = bitbake("core-image-minimal", ignore_status=True)
        except CommandError:
            self._exit_test()

        if result.status:
            self._exit_test()
        return time.time() - start

    def _prepare_servers(self):
        universal_path = self.SSTATE_CACHE_PATH / "universal"
        if not universal_path.exists():
            raise RuntimeError("cache_dir must contain a 'universal' folder")

        other_dirs = [d for d in self.SSTATE_CACHE_PATH.iterdir() if d.is_dir() and d.name != "universal"]
        num_regular_servers = self.servers_num - 1
        distributed = [[] for _ in range(num_regular_servers)]
        for idx, d in enumerate(other_dirs):
            distributed[idx % num_regular_servers].append(d)

        for i in range(self.servers_num):
            tempdir = tempfile.mkdtemp()
            sstate_dir = Path(tempdir) / "sstate-cache"
            sstate_dir.mkdir(parents=True)
            if i == 0:
                shutil.copytree(universal_path, sstate_dir / "universal", dirs_exist_ok=True)
            else:
                for d in distributed[i - 1]:
                    shutil.copytree(d, sstate_dir / d.name,dirs_exist_ok=True)
            self.server_dirs.append(tempdir)

    def _start_servers(self):
        for i, dir_path in enumerate(self.server_dirs):
            port = self.HTTP_START_PORT + i
            log_path = os.path.join(dir_path, "access.log")
            logger = logging.getLogger(f"HTTPServer-{port}")
            logger.setLevel(logging.INFO)
            file_handler = logging.FileHandler(log_path)
            file_handler.setLevel(logging.INFO)
            logger.addHandler(file_handler)

            service = HTTPService(dir_path, port=port, logger=logger)
            service.start()
            self.server_processes.append(service)
            self.server_urls.append(f"http://{self.HASH_SERVER_IP}:{port}/sstate-cache")
            self.server_logs.append(log_path)

    def _set_sstate_mirrors(self):
        mirrors = ""
        for url in self.server_urls:
            mirrors += f'file://.* {url}/PATH;downloadfilename=PATH '
        self.append_config(f'SSTATE_MIRRORS ?= "\\\n{mirrors.strip()}"')

    def test_build_time_increases_with_more_mirrors(self):
        self._start_hash_server()
        timings = []

        try:
            for mirrors in SERVERS_COUNTS:
                self.logger.info(f"\n>>> Starting build with {mirrors} mirror(s)")
                self._start_sstate_servers(servers_num=mirrors)
                self._clear_sstate_cache()

                build_time = self._run_build_and_measure()
                timings.append(build_time)

                self.logger.info(f"<<< Build with {mirrors} mirror(s) took {build_time:.2f} seconds")
                self._stop_sstate_servers()
        finally:
            self._stop_hash_server()

        self.logger.info("\n=== Build timings by number of mirrors ===")

        for i, duration in enumerate(timings):
            self.logger.info(f"{SERVERS_COUNTS[i]} mirror(s): {duration:.2f} seconds")

        self.assertTrue(all(map(lambda i: timings[i] < timings[i + 1], range(len(timings) - 1))),
                        "Expected longer build time with more mirrors")
