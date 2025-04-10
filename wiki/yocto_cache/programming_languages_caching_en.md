Languages:
1. [Golang](#golang)
2. [Node.js](#nodejs)

# Golang
The `go` command caches build output for reuse in future builds. By default, the cache is located in a `go-build` subdirectory of the user’s standard cache directory for the current operating system (this can be changed via environment variables). The build cache contains compiled packages and other build artifacts. The command also periodically removes cached data that has not been used recently.

## Formation
If we analyze what affects the compilation result of an individual Golang package, we see at least:
- build tags;
- the `GCO_ENABLED` value;
- the `GOOS` and `GOARCH` values;
- which package is being built at the moment.

In general, any input affects the result (the `cache key` and `check sum`) — starting from the package path to its contents.

## Compilation with Caching
To conveniently manage dependencies, `go.mod` and `go.sum` files are used.  
The former stores versions and paths of the used packages. The latter contains the hash values of the packages and their `.mod` files. Based on these files, the following compilation steps are performed:  
1. Build a dependency graph of the packages  
2. Calculate values for `cache key` and `check sum`

   This process starts from packages with no dependencies or only base ones. For example, when trying to build package `PKG2`, which depends on `PKG1`, and `PKG1` itself has no dependencies, the calculation begins from `PKG1`.  
   The `check sum` of the final package heavily depends on the checksums of the packages it uses.

3. Search `go-build` by the calculated value

   If the result is not found by the `check sum`, the package is compiled and the data is cached.  
   It’s important to note that there are 2 cache entries created for 1 compiled package. Let’s assume we have a computed `check sum` from the [section above](#formation). Then in the `go-build` directory, we have:
   - `/<first 2 characters of check sum>/<check sum>-a`

     An action file mapping the input `check sum` to `check sum2` (used for output or object file of the package)

   - `/<first 2 characters of check sum2>/<check sum2>-d`

     The compiled file. This file also includes `check sum` values (in base64 format) of the packages the current one depends on.

4. Use the resulting data  
5. Repeat steps 2–4 until all packages are either compiled or found in the cache

The instruction for adding recipes with packages in this language differs from others only in that the `GOBIN_FINAL` path is specified — where all object files are located. Then a lookup is performed using `cache key` or `check sum`. If the object file is not found, the package is compiled.

## Yocto and Golang Caching
Go creates its cache in the `.cache` folder inside the recipe’s working directory (`${B}/.cache`). This cache is stored in the `sstate cache` and then reused in subsequent builds.

An experiment was conducted: for the recipe [go-helloworld](https://git.yoctoproject.org/poky/plain/meta/recipes-extended/go-examples/go-helloworld_0.1.bb), a build was run using the command:
```shell
bitbake go-helloworld
```
Then the .cache folder was deleted from the recipe's working directory. The same command was run again. A message appeared stating that data was restored from the sstate cache:
```text
Initialising tasks: 100% |#######################################| Time: 0:00:00
Sstate summary: Wanted 5 Local 5 Mirrors 0 Missed 0 Current 279 (100% match, 100% complete)
NOTE: Executing Tasks
NOTE: Tasks Summary: Attempted 858 tasks of which 858 didn't need to be rerun and all succeeded.
```
Then the recipe was changed (added the line echo "hello") and rebuilt. The result:
```text
Initialising tasks: 100% |#######################################| Time: 0:00:00
Sstate summary: Wanted 12 Local 5 Mirrors 0 Missed 7 Current 272 (41% match, 97% complete)
Removing 6 stale sstate objects for arch core2-64: 100% |########| Time: 0:00:00
Removing 1 stale sstate objects for arch qemux86_64: 100% |######| Time: 0:00:00
NOTE: Executing Tasks
NOTE: Tasks Summary: Attempted 858 tasks of which 854 didn't need to be rerun and all succeeded.
```
In the end, only 4 tasks were re-executed.

# Node.js
Similar to [Golang](#golang), Node.js uses files to manage dependencies such as `package.json` and `package-lock.json`.
The former stores dependency names and project metadata. The second is automatically updated when running `npm` commands; it contains sub-dependencies, version locks, and installation paths.

Node.js is an interpreted language, so the cache (dependency data) is stored in the `node_modules` directory and identified using the `check sum` of the `package.json` file.

Just like in [Golang](#golang), the `NPM_SHRINKWRAP` variable is used in Node.js to specify the path to `npm-shrinkwrap.json`. The steps are the same.

## Yocto and Node.js Caching
An experiment was conducted: following [this guide](https://docs.yoctoproject.org/dev/dev-manual/packages.html#creating-node-package-manager-npm-packages), a recipe was created. Then a build was started using the command:
```shell
devtool build cute-files
```
Then the `npm_cache` and `node_modules` folders were deleted from the working directory. The build was restarted. The result:
```
Initialising tasks: 100% |#################################################| Time: 0:00:00
Sstate summary: Wanted 5 Local 5 Mirrors 0 Missed 0 Current 249 (100% match, 100% complete)
NOTE: Executing Tasks
NOTE: Tasks Summary: Attempted 818 tasks of which 818 didn't need to be rerun and all succeeded.

Summary: There was 1 WARNING message.
```
As we can see, the data was restored from the cache.

Then the recipe was modified (added the line `echo "hello"`) and rebuilt. The result:
```text
Initialising tasks: 100% |#######################################| Time: 0:00:00
Sstate summary: Wanted 8 Local 5 Mirrors 0 Missed 3 Current 246 (62% match, 98% complete)
Removing 1 stale sstate objects for arch qemux86_64: 100% |######| Time: 0:00:00
Removing 2 stale sstate objects for arch core2-64: 100% |########| Time: 0:00:00
NOTE: Executing Tasks
NOTE: cute-files: compiling from external source tree /home/user/poky/build/workspace/sources/cute-files
NOTE: Tasks Summary: Attempted 818 tasks of which 813 didn't need to be rerun and all succeeded.
```
In the end, only 5 tasks were re-executed.

## Sources
1. https://git.openembedded.org/openembedded-core/tree/meta/classes/go.bbclass?h=pyro  
2. https://blog.gopheracademy.com/advent-2015/go-in-a-yocto-project/

# Supported Build Systems in Yocto (with caching support)
* Go - `go.bbclass`, layer [openembedded-core](https://layers.openembedded.org/layerindex/branch/master/layer/openembedded-core/)
* Node.js - `nodejs` recipe, layer [meta-oe](https://layers.openembedded.org/layerindex/branch/jethro/layer/meta-oe/)
* CMake - `cmake.bbclass`, layer [openembedded-core](https://layers.openembedded.org/layerindex/branch/master/layer/openembedded-core/)
* Apache Maven - `maven` recipe, layer [meta-iot-cloud](https://layers.openembedded.org/layerindex/branch/gatesgarth/layer/meta-iot-cloud/)
* Bazel - `bazel.bbclass`, layer [meta-tensorflow](https://layers.openembedded.org/layerindex/branch/master/layer/meta-tensorflow/)
* Apache Ant - `ant-native` recipe, layer [meta-java](https://layers.openembedded.org/layerindex/branch/warrior/layer/meta-java/)
* Grunt - `grunt.bbclass`, layer [meta-nodejs-contrib](https://github.com/imyller/meta-nodejs-contrib)
* Gulp - `gulp.bbclass`, layer [meta-nodejs-contrib](https://github.com/imyller/meta-nodejs-contrib)
* MSBuild - `msbuild` recipe, layer [meta-mono](https://layers.openembedded.org/layerindex/branch/scarthgap/layer/meta-mono/)
* Ninja - `ninja` recipe, layer [openembedded-core](https://layers.openembedded.org/layerindex/branch/master/layer/openembedded-core/)
* Rack - `rack` recipe, layer [meta-openstack](https://layers.openembedded.org/layerindex/branch/thud/layer/meta-openstack/)
* SCons - `scons.bbclass`, layer [openembedded-core](https://layers.openembedded.org/layerindex/branch/master/layer/openembedded-core/)
