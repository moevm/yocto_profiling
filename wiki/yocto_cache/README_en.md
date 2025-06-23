# Yocto Cache
This folder contains information related to caching in Yocto.

* [recomendations](./SSTATE_PRSERV_HashSERV.md) - recommendations for speeding up the build from Yocto developers

## Cache Location
* [cache_description](./cache_description.md) - general concepts of caching in Yocto
* [yocto_cache](./yocto_cache.md) - general information about Yocto/BitBake caching
* [cache_locate](./cache_locate.md) - description of the local cache location in Yocto,  
  as well as how to configure it via settings
* [cache](./cache.md) - contents of the /poky/build/cache directory
* [local_cache_share](./local_cache_share.md) - description of shared use of local cache
* [parsing_cache](./parsing_cache.md) - caching of recipe parsing in BitBake

## Running a Cache Server
* [simple_http_cache_mirror](./simple_http_cache_mirror.md) - setting up cache mirrors in Yocto
* [mirrors_check](./mirrors_check.md) - description of the sstate-mirror validation scheme
* [setup_ftp_server](./setup_ftp_server.md) - instructions for creating an FTP cache server
* [setup_http_server](./setup_http_server.md) - instructions for creating an HTTP cache server

## Running a Hash Server

* [setup_OEEquivHash_server](./setup_OEEquivHash_server.md) - instructions for integrating a hash server with a remote cache server and launching the build

## Caching of External Build Systems During Yocto Builds

* [ccache](./ccache.md) - using the C/C++ compiler cache in Yocto
* [programming_languages_caching](./programming_languages_caching.md) - using build system caches for Go and Node.js in Yocto
