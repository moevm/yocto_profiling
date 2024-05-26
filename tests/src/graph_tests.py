import unittest
from src.dep_graph.src.analyze_graph import analyze_graph

class GraphTest(unittest.TestCase):
    def __init__(self, *args, **kwargs):
        super(GraphTest, self).__init__(*args, **kwargs)
        self.info = {'core-image-sato': {'do_build': {'Started': 1000, 'Ended': 1015},
                                        'do_create_runtime_spdx': {'Started': 900, 'Ended': 970},
                                        'do_create_spdx': {'Started': 870, 'Ended': 920},
                                        'do_image_complete': {'Started': 680, 'Ended': 860},
                                        'do_populate_lic_deploy': {'Started': 100, 'Ended': 200},
                                        'do_recipe_qa': {'Started': 180, 'Ended': 850}},
                    'dnf': {'do_package_write_rpm': {'Started': 50, 'Ended': 99}},
                    'glibc-locale': {'do_package_write_rpm': {'Started': 50, 'Ended': 100}},
                    'linux-yocto': {'do_deploy': {'Started': 50, 'Ended': 200}},
                    'packagegroup-base': {'do_package_write_rpm': {'Started': 250, 'Ended': 300}},
                    'packagegroup-core-boot': {'do_package_write_rpm': {'Started': 450, 'Ended': 451}},
                    'packagegroup-core-ssh-dropbear': {'do_package_write_rpm': {'Started': 500, 'Ended': 502}},
                    'packagegroup-core-x11-base': {'do_package_write_rpm': {'Started': 600, 'Ended': 602}},
                    'packagegroup-core-x11-sato': {'do_package_write_rpm': {'Started': 650, 'Ended': 653}},
                    'psplash': {'do_package_write_rpm': {'Started': 50, 'Ended': 950}},
                    'rpm': {'do_package_write_rpm': {'Started': 910, 'Ended': 915}},
                    'run-postinsts': {'do_package_write_rpm': {'Started': 530, 'Ended': 540}}}
        

    def test1(self): #найдем задачу с самым большим offset'ом
        self.assertEqual(analyze_graph('./tests/src/test_files/testDotFile.dot', self.info)[0], ('node: core-image-sato.do_build, Started: 1000.0, child: dnf.do_package_write_rpm, Ended: 99.0', 901.0))

    def test2(self): #удалили задачу из пр. теста и пытаемся снова найти задачу с самым большим offset'ом
        self.info.pop('dnf')
        self.assertEqual(analyze_graph('./tests/src/test_files/testDotFile.dot', self.info)[0], ('node: core-image-sato.do_build, Started: 1000.0, child: glibc-locale.do_package_write_rpm, Ended: 100.0', 900.0))

    def test3(self): #тест с двумя задачами с одинаковым offset'ом
        self.info.pop('dnf')
        self.info.pop('glibc-locale')
        self.assertEqual(analyze_graph('./tests/src/test_files/testDotFile.dot', self.info)[0], ('node: core-image-sato.do_build, Started: 1000.0, child: core-image-sato.do_populate_lic_deploy, Ended: 200.0', 800.0))
        
    

if __name__ == '__main__':
    unittest.main()
