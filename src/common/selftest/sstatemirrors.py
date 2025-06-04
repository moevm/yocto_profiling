import os
import re
from oeqa.selftest.case import OESelftestTestCase
from oeqa.utils.commands import runCmd

SERVERS_NUM = 5
PORT = 9000
MANIPULATE_CACHE_SCRIPT_PATH = '../../os_profiling/src/experiment/cache_server_setuper/manipulate_cache.sh'


def log(msg, filename='./logfile'):
    with open(filename, 'a') as file:
        file.write(f'{msg}\n')


class SstateMirrorsTests(OESelftestTestCase):

    servers_num = SERVERS_NUM
    port = PORT

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.script_path = MANIPULATE_CACHE_SCRIPT_PATH
        runCmd(f'sudo {cls.script_path} start {cls.port} {cls.servers_num}')

    @classmethod
    def tearDownClass(cls):
        runCmd(f'sudo {cls.script_path} kill')
        super().tearDownClass()

    def count_cache_containers(self):
        result = runCmd("sudo docker ps --format '{{.Names}}'")
        pattern = re.compile(r'^cache-part-\d+$|^cache-universal$')
        matched = [name for name in result.output.splitlines() if pattern.match(name)]
        return len(matched)

    def configure_sstate_mirrors(self):
        lines = []
        for i in range(self.servers_num):
            port = self.port + i
            line = f'file://.* http://localhost:{port}/sstate-cache/PATH;downloadfilename=PATH \\'
            lines.append(line)

        sstate_mirrors = 'SSTATE_MIRRORS ?= "\\\n' + '\n'.join(lines) + '"'
        self.append_config(sstate_mirrors)
        return sstate_mirrors

    def parse_sstate_mirrors(self, sstate_mirrors_var):
        urls = re.findall(r'http://[^;\s]+', sstate_mirrors_var)
        return [url.replace('/PATH', '/') for url in urls]

    def check_url_accessible(self, url):
        try:
            runCmd(f'curl -sSf {url}')
            return True
        except Exception as e:
            log(e)
            return False

    def test_expected_number_of_cache_containers(self):
        self.configure_sstate_mirrors()
        actual_count = self.count_cache_containers()
        self.assertEqual(actual_count, self.servers_num, f"Expected {self.servers_num} cache containers, found {actual_count}")

    def test_mirrors_availability(self):
        sstate_mirrors = self.parse_sstate_mirrors(self.configure_sstate_mirrors())
        results = []
        for mirror in sstate_mirrors:
            url = mirror[mirror.find("http") : mirror.find('/PATH')] + '/'
            results.append(self.check_url_accessible(url))
        self.assertTrue(all(results), msg="One or more mirrors are not accessible\n")

            
