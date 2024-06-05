# Yocto Build Dependencies
## Общий ход работы BitBake
1. Парсинг .bb файлов:
BitBak парсит и анализирует .bb файлы для определения задач и соответствующих функций, которые должны быть выполнены. Парсеры находятся в папке /bitbake/lib/bb/parse/parse_py (https://github.com/yoctoproject/poky/tree/master/bitbake/lib/bb/parse/parse_py).

2. Строительство дерева зависимостей:
На основе информации из .bb файлов, BitBake строит дерево зависимостей, отображающее связи между задачами и рецептами. Функция buildDependTree() файл bitbake/lib/bb/cooker.py (https://github.com/yoctoproject/poky/blob/master/bitbake/lib/bb/cooker.py).

3. Построение очереди выполнения:
Затем BitBake формирует очередь выполнения задач. Функция prepare() файл bitbake/lib/bb/runqueue.py (https://github.com/yoctoproject/poky/blob/master/bitbake/lib/bb/runqueue.py).
Очередь состоит из объектов класса RunTaskEntry. В каждом таком объекте хранится следующая информация:
    - depends: множество идентификаторов задач, от которых зависит текущая задача.
    - revdeps: множество идентификаторов задач, которые зависят от текущей задачи.
    - hash: хэш.
    - unihash: уникальный хэш, который используется для идентификации задачи.
    - task: имя задачи.
    - weight: вес задачи.

4. Выполнение задач в порядке очереди:
BitBake выполняет задачи в порядке, определенном очередью выполнения, учитывая построенное дерево зависимостей. Функция execute_runqueue() файл bitbake/lib/bb/runqueue.py (https://github.com/yoctoproject/poky/blob/master/bitbake/lib/bb/runqueue.py).

## Парсинг рецептов
### В каком порядке происходит обход файлов
Список рецептов для парсинга берется из переменной BBFILES (тут также могут находиться регулярные выражения для названий
файлов рецептов). Если переменная BBFILES не указана, то берутся рецепты из текущей директории. Названия файлов (или 
регулярные выражения для таковых) сортируются по приоритету: в переменной BBFILE_PATTERN в файле конфигурации слоя 
указывается регулярное выражение для имени файла рецепта, а также приоритет BBFILE_PRIORITY для рецепта, если его 
название удовлетворяет данному паттерну.

Затем для каждого названия файла (или регулярного выражения) проверяется, является ли он директорией или файлом. Для 
директорий выполняется рекурсивный поиск файлов рецептов, а для шаблонов названий файлов используется glob для получения
списка соответствующих файлов. Все найденные файлы фильтруются по маске BBMASK, и файлы, соответствующие маске,
отбрасываются.

### Время парсинга файлов
Для конфигурации из коммита 62e64c4cd436a0c0b8fb579fc3f664b03f49cdc9 из папки build/conf - 43 сек.

### Статистика по процессу парсинга
Статистику по процессу парсинга можно узнать добавив флаг -P к команде сборки:
```shell
bitbake -P core-image-minimal
```
Файл со статистикой по процессу парсинга `profile-parse.log.processed` можно найти в папке build.
Пример содержимого:
```text
Tue May 28 11:30:26 2024    profile-parse-Parser-2.log
Tue May 28 11:30:28 2024    profile-parse-Parser-9.log
Tue May 28 11:30:28 2024    profile-parse-Parser-8.log
Tue May 28 11:30:27 2024    profile-parse-Parser-7.log
Tue May 28 11:30:28 2024    profile-parse-Parser-6.log
Tue May 28 11:30:41 2024    profile-parse-Parser-5.log
Tue May 28 11:30:26 2024    profile-parse-Parser-4.log
Tue May 28 11:30:29 2024    profile-parse-Parser-3.log

         172878550 function calls (163233372 primitive calls) in 256.298 seconds

   Ordered by: internal time

   ncalls  tottime  percall  cumtime  percall filename:lineno(function)
7489144/4036531   27.886    0.000  129.390    0.000 /home/elizaveta/poky/bitbake/lib/bb/data_smart.py:775(getVarFlag)
  1489153   15.404    0.000  102.845    0.000 /home/elizaveta/poky/bitbake/lib/bb/data.py:264(build_dependencies)
5377310/2874910   14.023    0.000  117.512    0.000 /home/elizaveta/poky/bitbake/lib/bb/data_smart.py:453(expandWithRefs)
   362913   13.284    0.000   13.284    0.000 {built-in method builtins.compile}
  5377310   12.357    0.000   12.357    0.000 /home/elizaveta/poky/bitbake/lib/bb/data_smart.py:98(__init__)

```
Описание содержимого: 
- `Tue May 28 11:30:26 2024    profile-parse-Parser-X.log` - время начала парсинга для потока X и
название файла с логами процесса парсинга для данного потока. В конечном счете все эти файлы объединяются в один -
`profile-parse.log.processed`.

- `172878550 function calls (163233372 primitive calls) in 256.298 seconds` - общее количество вызовов функций
- `Ordered by: internal time` - порядок сортировки, внутреннее время выполнения
- `ncalls` - количество вызовов функции, через знак '/' может быть указано количество вложенных вызовов
- `tottime` - общее время, затраченное на выполнение функции (без учета времени вложенных вызовов)
- `percall` - среднее время на один вызов функции (tottime/ncalls)
- `cumtime` - общее время, затраченное на выполнение данной функции и всех функций, которые она вызывает
- `percall` - cumtime/ncalls
- `filename:lineno(function)` - имя файла, номер строки и имя функции.
