import unittest
from ranking import ranking_task_info


class RankingTest(unittest.TestCase):
    def __init__(self, *args, **kwargs):
        super(RankingTest, self).__init__(*args, **kwargs)
        self.info = {'package1': {'do_compile': {'Elapsed time': 1, 'utime': 1, 'stime': 1, 'cutime': 1, 'cstime': 1},
         'do_fetch': {'Elapsed time': 2, 'utime': 2, 'stime': 2, 'cutime': 2, 'cstime': 2},
         'do_install': {'Elapsed time': 3, 'utime': 3, 'stime': 3, 'cutime': 3, 'cstime': 3}},
         
         'package2': {'do_compile': {'Elapsed time': 17, 'utime': 24, 'stime': 13, 'cutime': 0.7, 'cstime': 8},
         'do_fetch': {'Elapsed time': 545, 'utime': 1.2, 'stime': 2.9, 'cutime': 3.18, 'cstime': 2.22},
         'do_install': {'Elapsed time': 99, 'utime': 34.3, 'stime': 3, 'cutime': 3.1, 'cstime': 0.99}},
         
         
        'package3': {'do_compile': {'Elapsed time': 28, 'utime': 4, 'stime': 0.08, 'cutime': 0.3, 'cstime': 900},
         'do_fetch': {'Elapsed time': 5, 'utime': 16, 'stime': 87, 'cutime': 132, 'cstime': 8.65},
         'do_install': {'Elapsed time': 0.001, 'utime': 13, 'stime': 4, 'cutime': 7.7, 'cstime': 0.02}}}

        self.pid_info = {'package1': {'do_compile': {"PID": 1}, 'do_fetch': {"PID": 2}, 'do_install': {"PID": 3}},
                        'package2': {'do_compile': {"PID": 4}, 'do_fetch': {"PID": 5}, 'do_install': {"PID": 6}},
                        'package3': {'do_compile': {"PID": 7}, 'do_fetch': {"PID": 8}, 'do_install': {"PID": 9}}}

    def test1(self): #базовый тест
        self.assertEqual(ranking_task_info(self.info, self.pid_info, 'do_compile', metric='Elapsed time')[0], ('package3', 7, 28))

    def test2(self): #теперь ранжируем по другой метрике
        self.assertEqual(ranking_task_info(self.info, self.pid_info, 'do_compile', metric='utime')[0], ('package2', 4, 24))

    def test3(self): #теперь ранжируем по другой задаче
        self.assertEqual(ranking_task_info(self.info, self.pid_info, 'do_fetch', metric='Elapsed time')[0], ('package2', 5, 545))

    def test4(self): #ранжируем по возрастанию
        self.assertEqual(ranking_task_info(self.info, self.pid_info, 'do_compile', metric='Elapsed time', reverse=False)[0], ('package1', 1, 1))
    
    def test5(self): #при попытке ранжирования пустых данных получаем пустой список
        self.assertEqual(ranking_task_info({}, {}, 'do_compile', metric='Elapsed time'), [])

    def test6(self): #при попытке ранжирования по несуществующей в статистике задаче получаем пустой список
        self.assertEqual(ranking_task_info(self.info, self.pid_info, 'do_build', metric='Elapsed time'), [])

    def test7(self): #при попытке ранжирования по несуществующей метрике получаем пустой список
        self.assertEqual(ranking_task_info(self.info, self.pid_info, 'do_compile', metric='ABCDEF'), [])

    


if __name__ == '__main__':
    unittest.main()