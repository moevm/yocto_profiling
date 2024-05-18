## Инструкция по добавлению слоев 
1. Склонировать папки слоев с официальных репозиториев:
   - [meta-openembedded](https://git.openembedded.org/meta-openembedded) - тут находится meta-oe, meta-python, meta-filesystems, meta-networking, meta-webserver
   - [meta-virtualization](https://git.yoctoproject.org/meta-virtualization)
   - [meta-clang](https://github.com/kraj/meta-clang)
   - [meta-erlang](https://github.com/meta-erlang/meta-erlang)
   - [meta-dpdk](https://git.yoctoproject.org/meta-dpdk)
   - [meta-cloud-services](https://git.yoctoproject.org/meta-cloud-services)
2. Переместить склонированные папки в poky/
3. В папке build выполнить команду
```shell
bitbake-layers add-layer ../meta-oe ../meta-python ../meta-networking ../meta-filesystems ../meta-virtualization ../meta-clang ../meta-webserver ../meta-erlang ../meta-dpdk ../meta-cloud-services
```