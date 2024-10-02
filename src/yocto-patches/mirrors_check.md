# Описания патча, удаляющего недоступные сервера
На этапе считывания переменных из `local.conf` происходит опрос содержимого переменной `SSTATE_MIRRORS` и перезапись ее только доступными серверами.
Применить изменеия можно с путем копирования файл `mirrors_cookerdata.patch` в директорию `./bitbake/lib/bb` [относительно корня poky] и выполнением команды:
```bash
git apply mirrors_cookerdata.patch
```
## Конфигурация эксперимента
Сервер работает только на порту `8868`.  
Для примера добавим такую локальную конфигурацию зеркал с кэшем:
```
SSTATE_MIRRORS ?= "file://.* http://0.0.0.0:8810/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8811/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8812/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8813/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8814/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8815/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8816/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8817/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8818/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8819/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8820/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8821/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8822/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8823/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8824/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8825/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8826/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8827/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8828/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8829/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8830/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8831/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8832/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8833/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8834/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8835/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8836/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8837/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8838/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8839/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8840/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8841/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8842/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8843/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8844/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8845/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8846/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8847/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8848/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8849/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8850/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8851/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8852/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8853/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8854/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8855/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8856/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8857/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8858/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8859/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8860/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8861/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8862/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8863/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8864/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8865/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8866/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8867/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8868/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8869/sstate-cache/PATH;downloadfilename=PATH \
file://.* http://0.0.0.0:8870/sstate-cache/PATH;downloadfilename=PATH"

BB_HASHSERVE = "auto"  
BB_HASHSERVE_UPSTREAM = "0.0.0.0:8886"  
BB_SIGNATURE_HANDLER = "OEEquivHash"  
CONF_VERSION = "2"
```

### Измерение сверки сигнатур после патча
Сверка заняла 29 секунд:  
![Screenshot from 2024-10-02 16-28-27](https://github.com/user-attachments/assets/7bd1dfbd-45db-4f47-a8b4-a916d11e1766)

### Измерение сверки сигнатур до патча
Сверка заняла 15 минут и 13 секунд:  
![Screenshot from 2024-10-02 16-45-41](https://github.com/user-attachments/assets/075c9fea-208c-4ed2-8a23-bec6b36c183f)


