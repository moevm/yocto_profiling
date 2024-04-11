### Bitbake tasksmap
![bitbake_tasks_map](https://github.com/moevm/os_profiling/assets/90711883/e7424583-01e5-42aa-b3a0-7dcb0ba26445)
### Описание
Для примера будут созданы 2 рецепта: 
`libhello` - рецепт, содержащий библиотеку
`sayhello` - рецепт использующий функционал `libhello`

### Описание компонент libhello
**LICENSE**: лицензия, связанная с этой библиотекой.

**Makefile**: файл сборки библиотеки.

**hellolib.c**: код библиотеки

**hellolib.h**: заголовок библиотеки.

### Описание компонент sayhello:
**LICENSE**: лицензия, связанная с этим проектом.  

**Makefile**: файл сборки проекта.  

**sayhello.c**: исходный файл проекта  

---

### Шаги подготовки

1) Создайте репозиторий Git для каждого проекта с соответствующими файлами.
2) Создайте рецепт для каждого проекта
3) Убедитесь, что `sayhello` рецепт имеет DEPENDS от `libhello` (это зависимость для сборки)
4) Убедитесь, что `sayhello` рецепт имеет R-DEPENDS от `libhello` (это зависимость для работы в runtime)
5) Добавьте `sayhello` в `IMAGE_INSTALL` , чтобы интегрировать его в корневую файловую систему.


### Содержание libhello/Makefile
```Bash
LIB=libhello.so

all: $(LIB)

$(LIB): hellolib.o
   $(CC) $< -Wl,-soname,$(LIB).1 -fPIC $(LDFLAGS) -shared -o $(LIB).1.0

%.o: %.c
   $(CC) -c $<

clean:
   rm -rf *.o *.so*
```

### Содержание libhello/hellolib.h:
```Bash
#ifndef HELLOLIB_H
#define HELLOLIB_H

void Hello();

#endif
```
### Содержание libhello/hellolib.c:
```Bash
#include <stdio.h>

void Hello(){
   puts("Hello from a Yocto demo \n");
}
```
### Содержание sayhello/Makefile:
```Bash
EXEC=sayhello
LDFLAGS += -lhello

all: $(EXEC)

$(EXEC): sayhello.c
   $(CC) $< $(LDFLAGS) $(CFLAGS) -o $(EXEC)

clean:
   rm -rf $(EXEC) *.o
```
### Содержание sayhello/sayhello.c:
```Bash
#include <hellolib.h>

int main(){
   Hello();
   return 0;
}
```
### Содержание libhello_0.1.bb:
```Bash
SUMMARY = "Hello demo library"
DESCRIPTION = "Hello shared library used in Yocto demo"

# NOTE: Set the License according to the LICENSE file of your project
#       and then add LIC_FILES_CHKSUM accordingly
LICENSE = "CLOSED"

# Assuming the branch is main
# Change <username> accordingly
SRC_URI = "git://github.com/<username>/libhello;branch=main;protocol=https"

S = "${WORKDIR}/git"

do_install(){
   install -d ${D}${includedir}
   install -d ${D}${libdir}

   install hellolib.h ${D}${includedir}
   oe_soinstall ${PN}.so.${PV} ${D}${libdir}
}
```
### Содержание sayhello_0.1.bb:
```Bash
SUMMARY = "SayHello demo"
DESCRIPTION = "SayHello project used in Yocto demo"

# NOTE: Set the License according to the LICENSE file of your project
#       and then add LIC_FILES_CHKSUM accordingly
LICENSE = "CLOSED"

# Assuming the branch is main
# Change <username> accordingly
SRC_URI = "git://github.com/<username>/sayhello;branch=main;protocol=https"

DEPENDS += "libhello"
RDEPENDS:${PN} += "libhello"

S = "${WORKDIR}/git"

do_install(){
   install -d ${D}/usr/bin
   install -m 0700 sayhello ${D}/usr/bin
}
```

### Запуск сборки
Для запуска сборки новой системы необходимо выполнить команду: `bitbake sayhello`
