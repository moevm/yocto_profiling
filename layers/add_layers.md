## Попытка добавления слоев

1) meta-cgl (meta-cgl-common): зависит от filesystems-layer, networking-layer, openembedded-layer, perl-layer,
    security, selinux: 
    - filesystems-layer несовместим с базовым словем, совместим с styhead scarthgap
    - networking-layer несовместим с базовым словем, совместим с scarthgap styhead
    - oe-layer несовместим с базовым словем, совместим с scarthgap styhead
    - perl-layer несовместим с базовым словем, совместим с scarthgap styhead
2) meta-clang: всё добавилось
3) meta-cloud-services: слой несовместим с базовым слоем, даёт подсказку, что совместим с scarthgap, зависит от meta-virtualization
4) meta-dpdk: всё добавилось
5) meta-erlang: всё добавилось
6) meta-java: слой несовместим с базовым слоем, даёт подсказку, что совместим с scarthgap
7) meta-openembedded: репозиторий содержит в себе много слоев,  несовместим с базовым слоем, даёт подсказку, что совместим с scarthgap styhead
8) meta-qt5: слой несовместим с базовым слоем, даёт подсказку, что совместим с scarthgap
9) meta-rust: слой несовместим с базовым слоем, даёт подсказку, что совместим с kirkstone honister mickledore hardknott gatesgarth
10) meta-security: слой зависит от openembedded-layer
11) meta-selinux: слой несовместим с базовым слоем, даёт подсказку, что совместим с scarthgap
12) meta-sysrepo: слой несовместим с базовым слоем, даёт подсказку, что совместим с honister
13) meta-virtualization: зависит от filesystems-layer, meta-python, networking-layer, openembedded-layer
14) meta-xilinx: репозиторий содержит в себе много слоев, неясно какой из них нужен, но они все так же несовместимы с базовым слоем, даёт подсказку, что совместимы с scarthgap
15) meta-xilinx-tools: слой несовместим с базовым слоем, даёт подсказку, что совместим с scarthgap, зависит от meta-xilinx и meta-xilinx-standalone


## Попытка добавления слоев после смены базового слоя на scarthgap

Был изменен порядок добавления слоев, так как некоторые слои зависят от других:
Порядок добавления:
1) meta-oe: добавлен (первым т.к. от него зависят другие слои)
2) meta-python: добавлен т.к. от него зависят другие слои
3) meta-networking: добавлен т.к. от него зависят другие слои
4) meta-filesystems: добавлен т.к. от него зависят другие слои
5) meta-perl: добавлен т.к. от него зависят другие слои
6) meta-security: добавлен (в начале т.к. от него зависят другие слои)
7) meta-selinux: добавлен (в начале т.к. от него зависят другие слои)
8) meta-cgl (meta-cgl-common): добавлен (на данном этапе уже есть все слои, от которых он зависит)
9) meta-clang: добавлен
10) meta-virtualization: добавлен (в начале т.к. от него зависят другие слои)
11) meta-cloud-services: добавлен (на данном этапе уже есть слой meta-virtualization, от которого он зависит)
12) meta-dpdk: добавлен
13) meta-erlang: добавлен
14) meta-java: добавлен
15) meta-qt5: добавлен
16) meta-xilinx: были добавлены meta-xilinx-core и meta-xilinx-standalone, т.к. от них зависит слой meta-xilinx-tools
17) meta-xilinx-tools: добавлен

## Остались не добавлены:
1) meta-rust
2) meta-sysrepo

так как данные слои всё еще не совместимы со слоем scarthgap
