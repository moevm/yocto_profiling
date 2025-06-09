from oeqa.selftest.case import OESelftestTestCase
from oeqa.utils.httpserver import HTTPService
import tempfile
import shutil
import os
from pathlib import Path
import logging

class SstateMirrorsTests(OESelftestTestCase):
    def setUpLocal(self):
        self.logger = logging.getLogger("SstateMirrorsTests")
        self.cache_dir = Path("/path/to/sstate-cache")
        self.start_port = 9000
        self.servers_num = 10
        self.server_processes = []
        self.server_dirs = []
        self.server_urls = []

        self._prepare_servers()
        self._start_servers()
        self._set_sstate_mirrors()


    def tearDownLocal(self):
        for s in self.server_processes:
            s.stop()
        for d in self.server_dirs:
            shutil.rmtree(d)
    
    def _set_sstate_mirrors(self):
        mirrors = ""
        for i, url in enumerate(self.server_urls):
            mirrors += (
                f'file://.* {url}/PATH;downloadfilename=PATH \\\n'
            )
        mirrors = mirrors.strip()
        self.append_config(f'SSTATE_MIRRORS ?= "\\\n{mirrors}"')

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
            service = HTTPService(dir_path, port=port, logger=self.logger)
            service.start()
            self.server_processes.append(service)
            self.server_urls.append(f"http://127.0.0.1:{port}/sstate-cache")

    def test_mirrors_availability(self):
        import urllib.request
        for url in self.server_urls:
            index_url = f"{url}/"
            with urllib.request.urlopen(index_url) as resp:
                self.assertEqual(resp.status, 200)