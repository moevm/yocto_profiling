# Experiment: Whether Build System Cache on Remote Servers is Considered

## Results of Experiments with Go and CMake

After setting up a cache server and conducting experiments with the Go and CMake build systems, the following results were obtained:

1. Experiments with Go
    * A new dependency was added to the recipe. As a result, tasks related to the new dependency were included in the build.
    * A patch was also added. In this case, the `do_patch` task and subsequent tasks were executed again.
    * When a dependency was added to the Go scripts, tasks related to source code changes were triggered.
    * Deleting the `sstate-cache` did not have a noticeable impact on the build process.
    * Log files for the `do_compile` task in each case are located in the [logs](./logs) folder.  
      Analyzing them shows no references to the `sstate-cache`.

2. Experiments with CMake
    * For CMake, a way was found to use a cache file directly like a regular file.
    ```bitbake
    SUMMARY = "Simple Hello World CMake application"
    SECTION = "examples"
    LICENSE = "MIT"
    LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

    FILES:${PN} = "/mydir/bin/hellocmake"

    SRC_URI = "\
                file://CMakeLists.txt \
                file://hellocmake.cpp \
                http://localhost:8000/CMakeCache.txt;sha256sum=8855c6119660c614d285554e51769066e94fcb75ff215ccc2fa6b4838b18756b \
            "

    S = "${WORKDIR}/sources-unpack"

    inherit cmake

    do_configure() {
        mkdir -p ${B}
        cmake --install-prefix /mydir -C ${S}/CMakeCache.txt -S ${S} -B ${B}
    }
    ```

    * For this case, the results of the experiments were similar to those found for Go.
