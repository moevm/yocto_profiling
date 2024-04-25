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