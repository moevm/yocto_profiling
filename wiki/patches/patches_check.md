## Настройка smtp и отправка патчей
1. Необходимо установить зависимости:
```bash
sudo apt update
sudo apt install git-email
```
2. Необходимо настроить пароль приложения (App Passwords), вы можете создать его в настройках своего аккаунта google/яндекс и т.д.
3. Необходимо настроить конфигурацию smtp, в поле smtpServer указывайте почтовый провайдер, который вы хотите использовать, а в поля smtpUser и smtpPass соответствующие вашему провайдеру email-адрес и настроенный вами пароль приложения, пример:
```bash
git config --global sendemail.smtpServer smtp.google.com
git config --global sendemail.smtpUser yourname@google.com
git config --global sendemail.smtpPass "<your-app-password>"
git config --global sendemail.smtpServerPort 587
git config --global sendemail.smtpEncryption tls
```
3. Перед отправкой патча необходимо подписаться на соответствующий список рассылки: https://docs.yoctoproject.org/dev/contributor-guide/submit-changes.html#subscribing-to-the-mailing-list
4. Далее можно отправлять письмо, простейший пример: ` git send-email --to <mailing-list-address> *.patch `, также вы можете указать кого-то в копию письма при помощи флага ` --cc `: `  git send-email --cc=someone@example.com --cc=another@example.com --to <mailing-list-address> *.patch `
5. Важно: обратите внимание, что отправка письма может быть заблокирована, если при создании письма в поле `From: ` указана почта не того провайдера, который настроен в вашей конфигурации smtp. По умолчанию поле ` From: ` заполняется из автора коммита. Для явного обозначения, от какой почты вы хотите отправить письмо, вы можете указать флаг ` --from ` при отправке, пример: ` git send-email --from=<yourname@gmail.com> --to <recipient@gmail.com> `.


## Создание патчей в соответствии с требуемым в Yocto форматом
1. Необходимо создать новую ветку от основной в репозитории poky
2. В созданной ветке необходимо добавить изменения по патчу
3. Необходимо создать коммит следующим образом: `git commit -s -m "<shortlog>: <description>" -m "<commit body>"` ИЛИ `git commit -s -m $'<shortlog>:  <description>\n\n<commit body>'`. Данные две команды аналогичны.  Добавление тела коммита является обязательным для прохождения проверки патчей. Использование флага ` -s ` необходимо для добавления строки `Signed-off-by: <name> <<email>>` в сообщение коммита, это также обязательное требование для прохождения тестов.
4. Далее необходимо создать файл патча при помощи ` git format-patch --relative=<path> <ref-branch> `. Для правильной настройки `--relative` см. пункт Mailing_lists

 
##  Mailing_lists
Каждый патч должен относиться к определенному компоненту проекта, а именно:
```python
# base paths of main yocto project sub-projects
paths = {
    'oe-core': ['meta-selftest', 'meta-skeleton', 'meta', 'scripts'],
    'bitbake': ['bitbake'],
    'documentation': ['documentation'],
    'poky': ['meta-poky','meta-yocto-bsp'],
    'oe': ['meta-gpe', 'meta-gnome', 'meta-efl', 'meta-networking', 'meta-multimedia','meta-initramfs', 'meta-ruby', 'contrib', 'meta-xfce', 'meta-filesystems', 'meta-perl', 'meta-webserver', 'meta-systemd', 'meta-oe', 'meta-python']
    }
```
Здесь представлены пути, относительно которых можно и нужно патчить изменения. То есть, например, если патч относится к bitbake, то при создании патча необходимо написать следующее: ` git format-patch --relative=bitbake master `.

Затем, при отправке патча необхоидмо указать корректный mailing_list:
` git send-email --to <mailing-list-address> *.patch `

Mailing_lists для компонентов:
    - bitbake: 'bitbake-devel@lists.openembedded.org'
    - doc: 'yocto@yoctoproject.org'
    - poky: 'poky@yoctoproject.org'
    - oe: 'openembedded-devel@lists.openembedded.org'


## Тестирование патчей при помощи patchtest
Шаги по тестированию патчей при помощи утилиты patchtest:
1. Подготовка patchtest 
    1) Устанавливаем зависимости ` pip install -r meta/lib/patchtest/requirements.txt `
    2) Настраиваем среду ` source oe-init-build-env `
    3) Добавляем слой ` bitbake-layers add-layer ../meta-selftest `
2. Запуск тестов
    1) Чтобы протестировать патч, вводим команду ` patchtest --patch <patch_name> `, можно указать флаг ` --log-results `, чтобы результаты тестирования залоггировались в файл
    2) Если необходимо протестировать директорию с патчами, то можно использовать ` patchtest --directory <directory_name> `


## Результат проверки патчей при помощи patchtest

| Патч                          | pretest src uri left files | pretest pylint | test author valid | test bugzilla entry format | test commit message presence | test commit message user tags | test mbox format | test non-AUH upgrade | test series merge on head | test shortlog format | test shortlog length | test Signed-off-by presence | test target mailing list | test CVE check ignore | test lic files chksum modified not mentioned | test lic files chksum presence | test license presence | test max line length | test src uri left files | test summary presence | test CVE tag format | test Signed-off-by presence | test Upstream-Status presence | test pylint |
|-------------------------------|----------------------------|----------------|-------------------|----------------------------|------------------------------|------------------------------|----------------|-----------------------|--------------------------|----------------------|---------------------|-----------------------------|------------------------|-----------------------|---------------------------------------------|-------------------------------|-----------------------|-----------------------|----------------------------|----------------------|---------------------|-----------------------------|-------------------------------|-----------------------|
| runqueue.patch           | SKIP                       | PASS           | PASS              | SKIP                       | FAIL                         | PASS                         | PASS           | PASS                  | SKIP                       | PASS                   | PASS                 | PASS                        | FAIL                   | SKIP                  | SKIP                                        | SKIP                          | SKIP                  | PASS                  | SKIP                         | SKIP                   | SKIP                 | SKIP                        | SKIP                          | PASS           |
| poky_dir.patch                 | SKIP                       | PASS           | PASS              | SKIP                       | FAIL                         | PASS                         | PASS           | PASS                  | SKIP                       | PASS                   | PASS                 | PASS                        | FAIL                   | SKIP                  | SKIP                                        | SKIP                          | SKIP                  | PASS                  | SKIP                         | SKIP                   | SKIP                 | SKIP                        | SKIP                          | PASS           |
| add_nvme_support.patch             | SKIP                       | PASS           | PASS              | SKIP                       | FAIL                         | PASS                         | PASS           | PASS                  | SKIP                       | PASS                   | PASS                 | PASS                        | FAIL                   | SKIP                  | SKIP                                        | SKIP                          | SKIP                  | PASS                  | SKIP                         | SKIP                   | SKIP                 | SKIP                        | SKIP                          | PASS           |
| add_net_limit.patch                | SKIP                       | PASS           | PASS              | SKIP                       | FAIL                         | PASS                         | PASS           | PASS                  | SKIP                       | PASS                   | PASS                 | PASS                        | FAIL                   | SKIP                  | SKIP                                        | SKIP                          | SKIP                  | PASS                  | SKIP                         | SKIP                   | SKIP                 | SKIP                        | SKIP                          | PASS           |
| add_net_buildstats.patch           | SKIP                       | PASS           | PASS              | SKIP                       | FAIL                         | PASS                         | PASS           | PASS                  | SKIP                       | PASS                   | PASS                 | PASS                        | FAIL                   | SKIP                  | SKIP                                        | SKIP                          | SKIP                  | PASS                  | SKIP                         | SKIP                   | SKIP                 | SKIP                        | SKIP                          | PASS           |
| async_filter.patch             | SKIP                       | PASS           | PASS              | SKIP                       | FAIL                         | PASS                         | PASS           | PASS                  | SKIP                       | PASS                   | PASS                 | PASS                        | FAIL                   | SKIP                  | SKIP                                        | SKIP                          | SKIP                  | PASS                  | SKIP                         | SKIP                   | SKIP                 | SKIP                        | SKIP                          | PASS           |
| network_load_limitation.patch  | SKIP                       | PASS           | PASS              | SKIP                       | FAIL                         | PASS                         | PASS           | PASS                  | SKIP                       | PASS                   | PASS                 | PASS                        | FAIL                   | SKIP                  | SKIP                                        | SKIP                          | SKIP                  | PASS                  | SKIP                         | SKIP                   | SKIP                 | SKIP                        | SKIP                          | PASS           |
| add_net_statistic_charts.patch | SKIP                       | PASS           | PASS              | SKIP                       | FAIL                         | PASS                         | PASS           | PASS                  | SKIP                       | PASS                   | PASS                 | PASS                        | FAIL                   | SKIP                  | SKIP                                        | SKIP                          | SKIP                  | PASS                  | SKIP                         | SKIP                   | SKIP                 | SKIP                        | SKIP                          | PASS           |
| compose_indexfile.patch        | SKIP                       | PASS           | PASS              | SKIP                       | FAIL                         | PASS                         | PASS           | PASS                  | SKIP                       | PASS                   | PASS                 | PASS                        | FAIL                   | SKIP                  | SKIP                                        | SKIP                          | SKIP                  | PASS                  | SKIP                         | SKIP                   | SKIP                 | SKIP                        | SKIP                          | PASS           |
| add_task_children_to_weight.patch        | SKIP                       | PASS           | PASS              | SKIP                       | FAIL                         | PASS                         | PASS           | PASS                  | SKIP                       | PASS                   | PASS                 | PASS                        | FAIL                   | SKIP                  | SKIP                                        | SKIP                          | SKIP                  | PASS                  | SKIP                         | SKIP                   | SKIP                 | SKIP                        | SKIP                          | PASS           |
| cachefiles.patch         | SKIP                       | PASS           | PASS              | SKIP                       | FAIL                         | PASS                         | PASS           | PASS                  | SKIP                       | PASS                   | PASS                 | PASS                        | FAIL                   | SKIP                  | SKIP                                        | SKIP                          | SKIP                  | PASS                  | SKIP                         | SKIP                   | SKIP                 | SKIP                        | SKIP                          | PASS           |


## Описание тестов
Ссылка на страницу с полным описанием тестов: https://wiki.yoctoproject.org/wiki/Patchtest

