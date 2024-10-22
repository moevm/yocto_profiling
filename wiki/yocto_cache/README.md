# Кэш Yocto
В данной папке находится информация, связанная с кэшированием в Yocto.

* [recomendations](./SSTATE_PRSERV_HashSERV.md) - рекомендации по ускорению сборки от разработчиков Yocto

## Расположение кэша
* [cache_description](./cache_description.md) - общие понятия о кэше в Yocto
* [yocto_cache](./yocto_cache.md) - общие сведения о Yocto/Bitbake кэшировании
* [cache_locate](./cache_locate.md) - описание расположения локального кэша в Yocto,
а также информация о том, как настроить его с помощью конфигурации
* [cache](./cache.md) - содержимое директории /poky/build/cache
* [local_cache_share](./local_cache_share.md) - описание общего использования локального кэша
* [parsing_cache](./parsing_cache.md) - кэширование парсинга рецептов в BitBake

## Запуск кэш-сервера
* [simple_http_cache_mirror](./simple_http_cache_mirror.md) - настройка зеркал кэша в Yocto
* [mirrors_check](./mirrors_check.md) - описание схемы проверки зеркал sstate-mirrors
* [setup_ftp_server](./setup_ftp_server.md) - инструкция создания ftp кэш-сервера
* [setup_http_server](./setup_http_server.md) - инструкция создания http кэш-сервера

## Запуск хэш-сервера

* [setup_OEEquivHash_server](./setup_OEEquivHash_server.md) - инструкция интеграция хэш сервера к удаленному кэш серверу и запуск сборки

## Кэш сторонних систем сборок во время сборки Yocto

* [ccache](./ccache.md) - использование кэша компилятора С/С++ в Yocto
* [programming_languages_caching](./programming_languages_caching.md) - использование в Yocto кэша от системы сборки Go и Node.js