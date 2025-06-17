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
import urllib.request

SERVERS_COUNTS = [2, 3]

class SstateMirrorsTests(OESelftestTestCase):
    def _start_sstate_servers(self, servers_num: int):
        self.cache_dir = Path("/path/to/sstate-cache")
        self.start_port = 9000
        self.servers_num = servers_num
        self.server_processes = []
        self.server_dirs = []
        self.server_urls = []
        self.server_logs = []

        self._prepare_servers()
        self._start_servers()
        self._set_sstate_mirrors()

    def _stop_sstate_servers(self):
        for s in self.server_processes:
            s.stop()
        for d in self.server_dirs:
            shutil.rmtree(d)

    def _clear_sstate_cache(self):
        tmp_cache = Path(self.builddir) / "tmp"
        if tmp_cache.exists():
            shutil.rmtree(tmp_cache)

    def _exit_test(self):
        self._stop_sstate_servers()
        self.fail(f'Command failed to execute\n')

    def _run_build_and_measure(self) -> float:
        start = time.time()
       
        try:
            result = bitbake("core-image-minimal", ignore_status=True)
        except CommandError as e:
            self._exit_test()
        if result.status:
            self._exit_test()
        duration = time.time() - start
        return duration

    def _prepare_servers(self):
        universal_path = self.cache_dir / "universal"
        if not universal_path.exists():
            raise RuntimeError("cache_dir must contain a 'universal' folder")

        other_dirs = [d for d in self.cache_dir.iterdir() if d.is_dir() and d.name != "universal"]
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
                    shutil.copytree(d, sstate_dir / d.name, dirs_exist_ok=True)
            self.server_dirs.append(tempdir)

    def _start_servers(self):
        for i, dir_path in enumerate(self.server_dirs):
            port = self.start_port + i
            log_path = os.path.join(dir_path, "access.log")
            logger = logging.getLogger(f"HTTPServer-{port}")
            logger.setLevel(logging.INFO)
            file_handler = logging.FileHandler(log_path)
            file_handler.setLevel(logging.INFO)
            logger.addHandler(file_handler)

            service = HTTPService(dir_path, port=port, logger=logger)
            service.start()
            self.server_processes.append(service)
            self.server_urls.append(f"http://127.0.0.1:{port}/sstate-cache")
            self.server_logs.append(log_path)

    def _set_sstate_mirrors(self):
        mirrors = ""
        for url in self.server_urls:
            mirrors += f'file://.* {url}/PATH;downloadfilename=PATH \\\n'
        mirrors = mirrors.strip()
        self.append_config(f'SSTATE_MIRRORS ?= "\\\n{mirrors}"')

    def test_build_time_increases_with_more_mirrors(self):
        timings = []

        for mirrors in SERVERS_COUNTS:  
            print(f"\n>>> Starting build with {mirrors} mirror(s)")
            self._start_sstate_servers(servers_num=mirrors)
            self._clear_sstate_cache()

            build_time = self._run_build_and_measure()
            timings.append(build_time)

            print(f"<<< Build with {mirrors} mirror(s) took {build_time:.2f} seconds")
            self._stop_sstate_servers()

        print("\n=== Build timings by number of mirrors ===")
        for i, duration in enumerate(timings):
            print(f"{SERVERS_COUNTS[i]} mirror(s): {duration:.2f} seconds")

        self.assertTrue(all(map(lambda i: timings[i] < timings[i + 1], range(len(timings) - 1))), 
                           "Expected longer build time with more mirrors")