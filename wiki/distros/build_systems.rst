.. list-table:: Embedded linux build systems

   * - Name
     - Docs
     - Sources
     - Used by
   * - `Yocto project <https://www.yoctoproject.org>`_
     - https://elbe-rfs.org/docs/sphinx/index.html
     - https://git.yoctoproject.org
     - - https://github.com/openbmc/openbmc
       - https://github.com/riscv/meta-riscv
   * - `Buildroot <https://buildroot.org>`_
     - https://docs.yoctoproject.org/
     - https://git.busybox.net/buildroot
     - https://github.com/openwrt/openwrt
   * - `ELBE <https://elbe-rfs.org>`_
     - https://github.com/openwrt/openwrt
     - https://github.com/Linutronix/elbe
     -
   * - `PTXdist <https://www.ptxdist.org>`_
     - https://www.ptxdist.org/doc
     - https://git.pengutronix.de/cgit/ptxdist
     -
   * - `Isar <http://www.ilbers.de/en/isar.html>`_
     - https://github.com/ilbers/isar/blob/master/doc/user_manual.md
     - https://github.com/ilbers/isar
     -
   * - Android build system
     - - https://source.android.com/docs/setup/build/building
       - https://elinux.org/Android_Build_System
     - https://source.android.com
     - https://source.android.com
   * - `Open Build Service <https://openbuildservice.org>`_
       (builds RPM packages and creates repositories, doesn't generate images)
     - https://openbuildservice.org/help/manuals/obs-user-guide
     - https://github.com/openSUSE/open-build-service
     - - https://build.sailfishos.org
       - https://build.opensuse.org
   * - mic (image generator, used with Open Build Service)
     - - https://docs.tizen.org/platform/developing/creating
       - https://docs.tizen.org/platform/reference/mic/mic-overview
     - - https://github.com/intel/mic
       - https://github.com/sailfishos/mic
       - https://git.launchpad.net/tizen-mic
     - https://github.com/mer-hybris
   * - `osbuild <https://osbuild.org>`_
     (image generator for RPM-based distributions, doesn't build packages)
     - https://osbuild.org/docs/user-guide/introduction
     - https://github.com/osbuild/osbuild
     - - https://sigs.centos.org/automotive/building/
       - https://fedoraproject.org/wiki/Changes/FedoraWorkstationImageBuilder
