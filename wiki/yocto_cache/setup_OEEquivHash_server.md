# Создание хэш сервера
Выполняем команду `. poky/oe-init-build-env` чтобы можно было использовать bitbake     


Где запускать сервер - не очень, как я понял, важно, но я создаю в отдельной папке `bitbake-hashserv -r -b <ip>:<port>`  --  флаг `-b` позваоляет указать порт и ip, если не заполнить поле <ip> и сделать `:<port>`, то сервер запустится на local host


В это время создается файл `hashserv.db` 
### Зачем он нужен?
По умолчанию работает локальный хэш сервер -- он производит сверку сигнатур и валидацию кэшей пакетов сборки из локльной папки sstate-cache. Эта валидация занимает некоторое время, потому в Bitbake предусмотрена возможность использования сторонних хэш серверов для валидации кэша.  
Однако, если мы используем зеркала кэша, то локальный (стандартный) хэш сервер bitbake не обрабатывает эти зеркала. Если мы подключим зеркала, но не зададим конфигурацию хэш сервера, появится предупреждение от сборщика:
> [!WARNING]
> "WARNING: You are using a local hash equivalence server but have configured an sstate mirror. This will likely mean no sstate will match from the mirror. You may wish to disable the hash equivalence use (BB_HASHSERVE), or use a hash equivalence server alongside the sstate mirror."  


Примерный перевод этого предупреждения:  
> [!WARNING]
> "ВНИМАНИЕ: вы используете локальный хэш сервер, но настроили зеркало sstate кэша. Скорее всего, это будет означать, что ни одно состояние не будет соответствовать зеркалу. Возможно, вы захотите отключить использование хеш-эквивалентности (BB_HASHSERVE) или использовать сервер хеш-эквивалентности рядом с зеркалом sstate."

В этом сообщение содержится два тезиса:
1) возможно мы не хотим сравнивать сигнатуры и получается делать сборку "с нуля"
2) возможно мы производим сборку на том же компьютере, где у нас размещен кэш, тогда можно указать локальный путь к этому кэшу.

> [!IMPORTANT]
> Вывод:
> Если мы настраиваем сервер кэша, который потенциально должен работать удаленно - мы должны создать и хэш сервер, который будет сравнивать сигнатуры кэшированных пакетов.

### Немного о том, какие есть обработчики сигнатур
В yocto поддерживаются следующие параметры `BB_SIGNATURE_HANDLER` : 
1. noop -- [SignatureGenerator(object)](https://github.com/yoctoproject/poky/blob/yocto-5.0.1/bitbake/lib/bb/siggen.py#L71) -- полупустой класс, который почти ничего не делает
2. basic -- [SignatureGeneratorBasic(SignatureGenerator)](https://github.com/yoctoproject/poky/blob/yocto-5.0.1/bitbake/lib/bb/siggen.py#L218) -- наследуется от `noop`; разработичики говорят, что медленный, но может использоваться для отладки
3. basichash -- [SignatureGeneratorBasicHash(SignatureGeneratorBasic)](https://github.com/yoctoproject/poky/blob/yocto-5.0.1/bitbake/lib/bb/siggen.py#L499) -- наследуется от `basic`; используется в качестве родителя для TestEquivHash, OEBasicHash, OEEquivHash
4. TestEquivHash -- [SignatureGeneratorTestEquivHash(SignatureGeneratorUniHashMixIn, SignatureGeneratorBasicHash)](https://github.com/yoctoproject/poky/blob/yocto-5.0.1/bitbake/lib/bb/siggen.py#L892) -- фиктивный класс для тестов
5. OEBasicHash -- [SignatureGeneratorOEBasicHash(SignatureGeneratorOEBasicHashMixIn, bb.siggen.SignatureGeneratorBasicHash)](https://github.com/yoctoproject/poky/blob/yocto-5.0.1/meta/lib/oe/sstatesig.py#L316) -- проверяет целостность пакетов
6. OEEquivHash -- [SignatureGeneratorOEEquivHash(SignatureGeneratorOEBasicHashMixIn, bb.siggen.SignatureGeneratorUniHashMixIn, bb.siggen.SignatureGeneratorBasicHash)](https://github.com/yoctoproject/poky/blob/yocto-5.0.1/meta/lib/oe/sstatesig.py#L319) -- проверяет целостность пакетов и обеспечивает, что эквивалентные пакеты дадут один и тот же хэш и не придется пересобирать эквивалетные пакеты. Подробнее про эквивалентность пакетов можно посмотреть [тут](https://docs.yoctoproject.org/5.0.4/overview-manual/concepts.html?highlight=oeequivhash#hash-equivalence).

Рекомендуется использовать `OEEquivHash`.

# Конфигурация удаленной сборки и сборка

### Конфигурация в Yocto (5.0)

> [!NOTE]
> Предлагаю поступить следущем образом -- стараемся делать файлы local.conf в сборке максимально похожим на ту сборку, из который выгружаем кэш -- в этом случае совспадение по сигнатурам будет высоким, а в конце файла, перед строкой `CONF_VERSION = "2"`  вписываем следующие конфигурации:

```sh
SOURCE_MIRROR_URL ?= "\
file://.* http://10.138.70.218:8888/downloads/PATH;downloadfilename=PATH"

SSTATE_MIRRORS ?= "\
file://.* http://10.138.70.218:8888/sstate-cache/PATH;downloadfilename=PATH"

BB_HASHSERVE = "auto"  
BB_HASHSERVE_UPSTREAM = "10.138.70.218:8686"  
BB_SIGNATURE_HANDLER = "OEEquivHash"  
```

Для упрощенной работы с файлами конфигураций, советую использовать написанный python скрипт, который удаляет комменатрии из файла конфигурации:    
```py
import os
def remove_comments(filename):
    temp_filename = filename + ".tmp"

    with open(filename, "r") as input_file, open(temp_filename, "w") as output_file:
        for line in input_file:
            if not line.startswith("#"):
                output_file.write(line)
                #print(line)
    os.rename(temp_filename, filename)

if __name__ == '__main__': 
    remove_comments("local.conf")
```

### Сборка
При настроенной конфигурации проблем со сборкой возникать не должно.    
Запускаем сборку `bitbake <target>`   
Логи:   
![Screenshot from 2024-05-24 14-12-26](https://github.com/moevm/os_profiling/assets/90711883/f77101b4-9400-4750-95a7-e95534bc27bb)

В строк `Sstate summary: Wanted 1867 Local 0 Mirrors 1863 Missed 4 Current 0 (99% match, 0% complete)` видно, что с зеркала загрузилось 99% задач. Приведем график потребления ресурсов при сборке образа с использованием кэш и хэш серверов:  

![image](https://github.com/moevm/os_profiling/assets/90711883/2f69ca45-eaa1-4dee-a150-5db4269a8953)

