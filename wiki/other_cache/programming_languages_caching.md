Языки:
1. [Golang](#golang)
2. [Node.js](#nodejs)

# Golang
Команда `go` кэширует выходные данные сборки (build output) для повторного использования в будущих сборках. Расположение по умолчанию для данных кэша - это подкаталог `go-build` в стандартном каталоге кэша пользователя для текущей операционной системы (можно изменять с помощью переменных среды). Кэш сборки содержит скомпилированные пакеты и другие артефакты сборки.
Также команда периодически удаляет кэшированные данные, которые недавно не использовались.
## Формирование
Если изучить, от чего зависит результат компиляции отдельного пакета в Golang, то мы увидим, как минимум:
- тэги сборки;
- значение `GCO_ENABLED`;
- значение `GOOS` и `GOARCH`;
- то, какой пакет мы в данный момент собираем.

В целом на результат (значения `cache key` и `check sum`) влияют любые входные данные, начиная от пути по которому находится пакет, заканчивая содержимым.
## Алгоритм компиляции с кэшированием
Для удобства контроля зависимостями используются файлы `go.mod` и `go.sum`.
В 1-ом хранятся версии используемых пакетов и пути к ним. Во 2-ом хэш-суммы пакетов и их `.mod` файлов. На основе этих файлов выполняются следующие шаги компиляции: 
1. Построение графа зависимостей пакетов
2. Расчёт значений `cache key` и `check sum`

	Данный процесс начинается от пакетов у которых либо нет зависимостей, либо они базовые. То есть при попытке собрать пакет `PKG2`, который зависит от `PKG1`, а `PKG1` в свою очередь не имеет каких-то зависимостей, то расчёт начинается с пакета `PKG1`. 
	Значения `check sum` для конечного пакета сильно зависит от этих же значений используемых пакетов.
3. Поиск в `go-build` по рассчитанному значению

	В случае если по значению `check sum` не найден результат, то данные пакет скомпилируется и данные будут закэшированы.
	Стоит отметить для 1 скомпилированного пакета существуют сразу 2 места хранения кэша. Допустим у нас есть посчитанное значение `check sum` для данных из [предыдущего заголовка](#Формирование). Тогда в директории `go-build` находятся:
	- `/<2 первых символа из check sum>/<check sum>-a`
	
		action file со значениями соответствия двух значений, уже рассчитанной `check sum` (для входных данных) и `check sum2` (для выходного или объектного файла пакета)
	- `/<2 первых символа из check sum2>/<check sum2>-d`
	
		Файл который скомпилировался. В данном файле также учитываются значения `check sum` пакетов от которых зависит текущий, но используются они в формате `base64`.
4. Использование полученных данных
5. Повторение пунктов 2-4 пока все пакеты не будут скомпилированы или найдены в кэше.

Инструкция по добавлению рецептов с пакетами на данном языке отличается от других только тем, что указывается путь `GOBIN_FINAL`, по которому находятся все объектные файлы, далее происходит поиск по  `cache key` или `check sum`. В случае, если объектный файл не найден запускается сборка пакета. 
## Yocto и кэширование Golang
Go создает свой кэш в папке `.cache` в рабочей директории рецепта (`${B}/.cache`). Этот же кэш сохраняется в `sstate cache` и затем используется при повторной сборке.

Был проведен эксперимент: для рецепта [go-helloworld](https://git.yoctoproject.org/poky/plain/meta/recipes-extended/go-examples/go-helloworld_0.1.bb) была запущена сборка с помощью команды
```shell
bitbake go-helloworld
```
Затем в рабочей директории рецепта была удалена папка `.cache`. Далее снова была выполнена предыдущая команда. Было выведено сообщение о том, что данные были восстановлены из sstate cache:
```text
Initialising tasks: 100% |#######################################| Time: 0:00:00
Sstate summary: Wanted 5 Local 5 Mirrors 0 Missed 0 Current 279 (100% match, 100% complete)
NOTE: Executing Tasks
NOTE: Tasks Summary: Attempted 858 tasks of which 858 didn't need to be rerun and all succeeded.
```
Затем рецепт был изменен (добавлена строка `echo "hello"`) и запущена пересборка. Результат:
```text
Initialising tasks: 100% |#######################################| Time: 0:00:00
Sstate summary: Wanted 12 Local 5 Mirrors 0 Missed 7 Current 272 (41% match, 97% complete)
Removing 6 stale sstate objects for arch core2-64: 100% |########| Time: 0:00:00
Removing 1 stale sstate objects for arch qemux86_64: 100% |######| Time: 0:00:00
NOTE: Executing Tasks
NOTE: Tasks Summary: Attempted 858 tasks of which 854 didn't need to be rerun and all succeeded.
```
По итогу заново было выполнено всего 4 задачи.
# Node.js
Аналогично языку [Golang](#golang) в Node.js используются файлы для контроля зависимостей, такие как `package.json` и `package-lock.json`. В 1-ом хранятся названия зависимостей и метаданные проекта. Второй файл регулируется автоматически при исполнении команд с `npm`, он содержит в себе подзависимости, контроль версий и пути для установки.
Язык интерпретируемый, поэтому кэш (данные зависимостей) хранятся в директории `node_modules` и идентифицируется с помощью `check sum` файла `package.json`.

Аналогично языку [Golang](#golang) в Node.js используется переменная `NPM_SHRINKWRAP`, для указания пути до `npm-shrinkwrap.json` пакета. Дальнейшие действия аналогичны.

## Yocto и кэширование Node.js
Был проведен эксперимент: по [инструкции](https://docs.yoctoproject.org/dev/dev-manual/packages.html#creating-node-package-manager-npm-packages) был создан рецепт. Далее была запущена сборка с помощью команды
```shell
devtool build cute-files
```
Затем из рабочей директории были удалены папки `npm_cache` и `node_modules`. Была запущена пересборка. Полученный результат:
```
Initialising tasks: 100% |#################################################| Time: 0:00:00
Sstate summary: Wanted 5 Local 5 Mirrors 0 Missed 0 Current 249 (100% match, 100% complete)
NOTE: Executing Tasks
NOTE: Tasks Summary: Attempted 818 tasks of which 818 didn't need to be rerun and all succeeded.

Summary: There was 1 WARNING message.
```
Как видим, данные были восстановлены из кэша.

Затем рецепт был изменен (добавлена строка `echo "hello"`) и запущена пересборка. Результат:
```text
Initialising tasks: 100% |#######################################| Time: 0:00:00
Sstate summary: Wanted 8 Local 5 Mirrors 0 Missed 3 Current 246 (62% match, 98% complete)
Removing 1 stale sstate objects for arch qemux86_64: 100% |######| Time: 0:00:00
Removing 2 stale sstate objects for arch core2-64: 100% |########| Time: 0:00:00
NOTE: Executing Tasks
NOTE: cute-files: compiling from external source tree /home/user/poky/build/workspace/sources/cute-files
NOTE: Tasks Summary: Attempted 818 tasks of which 813 didn't need to be rerun and all succeeded.
```
По итогу заново было выполнено всего 5 задачи.

## Источники
1. https://git.openembedded.org/openembedded-core/tree/meta/classes/go.bbclass?h=pyro
2. https://blog.gopheracademy.com/advent-2015/go-in-a-yocto-project/

# Список поддерживаемых (поддержка кэша) систем сборок в Yocto
* Go - класс `go.bbclass`, слой [openembedded-core](https://layers.openembedded.org/layerindex/branch/master/layer/openembedded-core/)
* Node.js - рецепт `nodejs`, слой [meta-oe](https://layers.openembedded.org/layerindex/branch/jethro/layer/meta-oe/)
* CMake - класс `cmake.bbclass`, слой [openembedded-core](https://layers.openembedded.org/layerindex/branch/master/layer/openembedded-core/)
* Apache Maven - рецепт `maven`, слой [meta-iot-cloud](https://layers.openembedded.org/layerindex/branch/gatesgarth/layer/meta-iot-cloud/)
* Bazel - класс `bazel.bbclass` , слой [meta-tensorflow](https://layers.openembedded.org/layerindex/branch/master/layer/meta-tensorflow/)
* Apache Ant - рецепт `ant-native`, слой [meta-java](https://layers.openembedded.org/layerindex/branch/warrior/layer/meta-java/)
* Grunt - класс `grunt.bbclass`, слой [meta-nodejs-contrib](https://github.com/imyller/meta-nodejs-contrib)
* Gulp - класс `gulp.bbclass`, слой [meta-nodejs-contrib](https://github.com/imyller/meta-nodejs-contrib)
* MSBuild - рецепт `msbuild`, слой [meta-mono](https://layers.openembedded.org/layerindex/branch/scarthgap/layer/meta-mono/)
* Ninja - рецепт `ninja`, слой [openembedded-core](https://layers.openembedded.org/layerindex/branch/master/layer/openembedded-core/)
* Rack - рецепт `rack`, слой [meta-openstack](https://layers.openembedded.org/layerindex/branch/thud/layer/meta-openstack/)
* SCons - класс `scons.bbclass`, слой [openembedded-core](https://layers.openembedded.org/layerindex/branch/master/layer/openembedded-core/)
