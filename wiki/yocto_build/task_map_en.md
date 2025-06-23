### BitBake tasks map  
![bitbake_tasks_map](https://github.com/moevm/os_profiling/assets/90711883/e7424583-01e5-42aa-b3a0-7dcb0ba26445)

### Description

We’ll create two example recipes:  
- `libhello` – a recipe for a library  
- `sayhello` – a recipe that uses `libhello`

### `libhello` Components
- `LICENSE`: license file  
- `Makefile`: library build script  
- `hellolib.c`: source code  
- `hellolib.h`: header file  

### `sayhello` Components
- `LICENSE`: license file  
- `Makefile`: build script  
- `sayhello.c`: source code  

---

### Preparation Steps

1) Create a Git repo for each project with its files  
2) Create a BitBake recipe for each project  
3) Ensure `sayhello` has `DEPENDS` on `libhello` (build dependency)  
4) Ensure `sayhello` has `RDEPENDS` on `libhello` (runtime dependency)  
5) Add `sayhello` to `IMAGE_INSTALL` to include it in the rootfs  

### `libhello/Makefile`
```bash
LIB=libhello.so

all: $(LIB)

$(LIB): hellolib.o
	$(CC) $< -Wl,-soname,$(LIB).1 -fPIC $(LDFLAGS) -shared -o $(LIB).1.0

%.o: %.c
	$(CC) -c $<

clean:
	rm -rf *.o *.so*
```

### `libhello/hellolib.h`
```c
#ifndef HELLOLIB_H
#define HELLOLIB_H

void Hello();

#endif
```

### `libhello/hellolib.c`
```c
#include <stdio.h>

void Hello(){
	puts("Hello from a Yocto demo \n");
}
```

### `sayhello/Makefile`
```bash
EXEC=sayhello
LDFLAGS += -lhello

all: $(EXEC)

$(EXEC): sayhello.c
	$(CC) $< $(LDFLAGS) $(CFLAGS) -o $(EXEC)

clean:
	rm -rf $(EXEC) *.o
```

### `sayhello/sayhello.c`
```c
#include <hellolib.h>

int main(){
	Hello();
	return 0;
}
```

### `libhello_0.1.bb`
```bitbake
SUMMARY = "Hello demo library"
DESCRIPTION = "Hello shared library used in Yocto demo"
LICENSE = "CLOSED"
SRC_URI = "git://github.com/<username>/libhello;branch=main;protocol=https"
S = "${WORKDIR}/git"

do_install(){
	install -d ${D}${includedir}
	install -d ${D}${libdir}
	install hellolib.h ${D}${includedir}
	oe_soinstall ${PN}.so.${PV} ${D}${libdir}
}
```

### `sayhello_0.1.bb`
```bitbake
SUMMARY = "SayHello demo"
DESCRIPTION = "SayHello project used in Yocto demo"
LICENSE = "CLOSED"
SRC_URI = "git://github.com/<username>/sayhello;branch=main;protocol=https"
DEPENDS += "libhello"
RDEPENDS:${PN} += "libhello"
S = "${WORKDIR}/git"

do_install(){
	install -d ${D}/usr/bin
	install -m 0700 sayhello ${D}/usr/bin
}
```

### Build Command

To build the system with this new recipe, run:
```bash
bitbake sayhello
```
