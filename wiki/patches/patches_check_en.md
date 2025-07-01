## SMTP Configuration and Patch Sending

1. You need to install dependencies:
```bash
sudo apt update
sudo apt install git-email
```

2. You need to set up an application password (App Passwords); you can create it in the settings of your Google/Yandex/etc. account.

3. You need to configure SMTP. In the `smtpServer` field, specify the mail provider you want to use, and in the `smtpUser` and `smtpPass` fields, enter your email address and the application password you created, respectively. Example:
```bash
git config --global sendemail.smtpServer smtp.google.com
git config --global sendemail.smtpUser yourname@google.com
git config --global sendemail.smtpPass "<your-app-password>"
git config --global sendemail.smtpServerPort 587
git config --global sendemail.smtpEncryption tls
```

4. Before sending a patch, you need to subscribe to the appropriate mailing list: https://docs.yoctoproject.org/dev/contributor-guide/submit-changes.html#subscribing-to-the-mailing-list

5. Then you can send the email. A simple example:
```bash
git send-email --to <mailing-list-address> *.patch
```
You can also CC someone using the `--cc` flag:
```bash
git send-email --cc=someone@example.com --cc=another@example.com --to <mailing-list-address> *.patch
```

6. Important: Note that the email may be blocked if the `From:` field in the email does not match the provider configured in your SMTP settings. By default, the `From:` field is filled from the commit author. To explicitly specify which email you want to send from, use the `--from` flag:
```bash
git send-email --from=<yourname@gmail.com> --to <recipient@gmail.com>
```

---

## Creating Patches According to the Required Yocto Format

1. Create a new branch from the main branch in the poky repository.

2. In the created branch, make changes for the patch.

3. Create a commit using the following command:
```bash
git commit -s -m "<shortlog>: <description>" -m "<commit body>"
```
OR
```bash
git commit -s -m $'<shortlog>:  <description>\n\n<commit body>'
```
Both commands are equivalent. Adding a commit body is mandatory to pass patch validation. Using the `-s` flag is necessary to add the line `Signed-off-by: <name> <<email>>` to the commit message—this is also a requirement for passing tests.

4. Then create a patch file using:
```bash
git format-patch --relative=<path> <ref-branch>
```
For correct setup of `--relative`, see the Mailing_lists section.

---

## Mailing_lists

Each patch must relate to a specific component of the project, namely:
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
These are the paths relative to which you should patch changes. For example, if the patch relates to bitbake, then when creating the patch, you should write:
```bash
git format-patch --relative=bitbake master
```

Then, when sending the patch, you must specify the correct mailing list:
```bash
git send-email --to <mailing-list-address> *.patch
```

Mailing lists for components:
- bitbake: `bitbake-devel@lists.openembedded.org`
- doc: `yocto@yoctoproject.org`
- poky: `poky@yoctoproject.org`
- oe: `openembedded-devel@lists.openembedded.org`

---

## Testing Patches Using Patchtest

Steps to test patches using the patchtest utility:

1. Patchtest preparation:
    1) Install dependencies:
    ```bash
    pip install -r meta/lib/patchtest/requirements.txt
    ```
    2) Set up the environment:
    ```bash
    source oe-init-build-env
    ```
    3) Add the layer:
    ```bash
    bitbake-layers add-layer ../meta-selftest
    ```

2. Running tests:
    1) To test a patch, run:
    ```bash
    patchtest --patch <patch_name>
    ```
    You can use the `--log-results` flag to log the test results to a file.

    2) To test a directory of patches:
    ```bash
    patchtest --directory <directory_name>
    ```

---

## Patchtest Result Table

| Patch                          | pretest src uri left files | pretest pylint | test author valid | test bugzilla entry format | test commit message presence | test commit message user tags | test mbox format | test non-AUH upgrade | test series merge on head | test shortlog format | test shortlog length | test Signed-off-by presence | test target mailing list | test CVE check ignore | test lic files chksum modified not mentioned | test lic files chksum presence | test license presence | test max line length | test src uri left files | test summary presence | test CVE tag format | test Signed-off-by presence | test Upstream-Status presence | test pylint |
|-------------------------------|----------------------------|----------------|-------------------|----------------------------|------------------------------|------------------------------|----------------|-----------------------|--------------------------|----------------------|---------------------|-----------------------------|------------------------|-----------------------|---------------------------------------------|-------------------------------|-----------------------|-----------------------|----------------------------|----------------------|---------------------|-----------------------------|-------------------------------|-----------------------|
| runqueue.patch                | SKIP                       | PASS           | PASS              | SKIP                       | FAIL                         | PASS                         | PASS           | PASS                  | SKIP                     | PASS                 | PASS               | PASS                        | FAIL                   | SKIP                  | SKIP                                        | SKIP                          | SKIP                  | PASS                  | SKIP                         | SKIP                   | SKIP                 | SKIP                        | SKIP                          | PASS           |
| poky_dir.patch                | SKIP                       | PASS           | PASS              | SKIP                       | FAIL                         | PASS                         | PASS           | PASS                  | SKIP                     | PASS                 | PASS               | PASS                        | FAIL                   | SKIP                  | SKIP                                        | SKIP                          | SKIP                  | PASS                  | SKIP                         | SKIP                   | SKIP                 | SKIP                        | SKIP                          | PASS           |
| add_nvme_support.patch        | SKIP                       | PASS           | PASS              | SKIP                       | FAIL                         | PASS                         | PASS           | PASS                  | SKIP                     | PASS                 | PASS               | PASS                        | FAIL                   | SKIP                  | SKIP                                        | SKIP                          | SKIP                  | PASS                  | SKIP                         | SKIP                   | SKIP                 | SKIP                        | SKIP                          | PASS           |
| add_net_limit.patch           | SKIP                       | PASS           | PASS              | SKIP                       | FAIL                         | PASS                         | PASS           | PASS                  | SKIP                     | PASS                 | PASS               | PASS                        | FAIL                   | SKIP                  | SKIP                                        | SKIP                          | SKIP                  | PASS                  | SKIP                         | SKIP                   | SKIP                 | SKIP                        | SKIP                          | PASS           |
| add_net_buildstats.patch      | SKIP                       | PASS           | PASS              | SKIP                       | FAIL                         | PASS                         | PASS           | PASS                  | SKIP                     | PASS                 | PASS               | PASS                        | FAIL                   | SKIP                  | SKIP                                        | SKIP                          | SKIP                  | PASS                  | SKIP                         | SKIP                   | SKIP                 | SKIP                        | SKIP                          | PASS           |
| async_filter.patch            | SKIP                       | PASS           | PASS              | SKIP                       | FAIL                         | PASS                         | PASS           | PASS                  | SKIP                     | PASS                 | PASS               | PASS                        | FAIL                   | SKIP                  | SKIP                                        | SKIP                          | SKIP                  | PASS                  | SKIP                         | SKIP                   | SKIP                 | SKIP                        | SKIP                          | PASS           |
| network_load_limitation.patch | SKIP                       | PASS           | PASS              | SKIP                       | FAIL                         | PASS                         | PASS           | PASS                  | SKIP                     | PASS                 | PASS               | PASS                        | FAIL                   | SKIP                  | SKIP                                        | SKIP                          | SKIP                  | PASS                  | SKIP                         | SKIP                   | SKIP                 | SKIP                        | SKIP                          | PASS           |
| add_net_statistic_charts.patch| SKIP                       | PASS           | PASS              | SKIP                       | FAIL                         | PASS                         | PASS           | PASS                  | SKIP                     | PASS                 | PASS               | PASS                        | FAIL                   | SKIP                  | SKIP                                        | SKIP                          | SKIP                  | PASS                  | SKIP                         | SKIP                   | SKIP                 | SKIP                        | SKIP                          | PASS           |
| compose_indexfile.patch       | SKIP                       | PASS           | PASS              | SKIP                       | FAIL                         | PASS                         | PASS           | PASS                  | SKIP                     | PASS                 | PASS               | PASS                        | FAIL                   | SKIP                  | SKIP                                        | SKIP                          | SKIP                  | PASS                  | SKIP                         | SKIP                   | SKIP                 | SKIP                        | SKIP                          | PASS           |
| add_task_children_to_weight.patch| SKIP                    | PASS           | PASS              | SKIP                       | FAIL                         | PASS                         | PASS           | PASS                  | SKIP                     | PASS                 | PASS               | PASS                        | FAIL                   | SKIP                  | SKIP                                        | SKIP                          | SKIP                  | PASS                  | SKIP                         | SKIP                   | SKIP                 | SKIP                        | SKIP                          | PASS           |
| cachefiles.patch              | SKIP                       | PASS           | PASS              | SKIP                       | FAIL                         | PASS                         | PASS           | PASS                  | SKIP                     | PASS                 | PASS               | PASS                        | FAIL                   | SKIP                  | SKIP                                        | SKIP                          | SKIP                  | PASS                  | SKIP                         | SKIP                   | SKIP                 | SKIP                        | SKIP                          | PASS           |

---

## Description of Tests

Full test description: https://wiki.yoctoproject.org/wiki/Patchtest
