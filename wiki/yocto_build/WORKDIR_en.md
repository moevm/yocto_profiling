## Retrieving the WORKDIR Variable for a Recipe

You can get the `WORKDIR` variable for a recipe using the following command:  
`bitbake -e <recipe-name> | grep ^WORKDIR=`

Example:  
![image](https://github.com/moevm/os_profiling/assets/90854310/4b54dec9-a221-46b9-bf14-725dcafbbbd3)

## Why You Need the WORKDIR Variable

The `WORKDIR` variable defines the working directory for a recipe. It contains:
1) Log files and run files with task execution info, including PIDs for those tasks  
2) The `/WORKDIR/image`, `/WORKDIR/sysroot-destdir`, `/WORKDIR/package`, and `/WORKDIR/packages-split` folders contain output for the following tasks respectively:
   - `do_install`
   - `do_populate_sysroot`
   - `do_package` before splitting into individual packages
   - `do_package` after splitting into packages

Knowing the `WORKDIR` is necessary to properly access any of the data listed above, as `WORKDIR` can sometimes be defined in non-obvious ways, for example:  
![image](https://github.com/moevm/os_profiling/assets/90854310/ec23263a-1dc4-49e3-b0e5-35b58cd79112)

This directory `/work-shared/gcc-13.2.0-r0` is the working directory for the `gcc-source-13.2.0` recipe, even though the recipe name is not directly mentioned. Without knowing the actual `WORKDIR`, it would be unclear where to look for logs and output. Also, the name may cause confusion, as this directory could be mistaken for the working directory of `gcc`:  
![image](https://github.com/moevm/os_profiling/assets/90854310/40df4b3d-828c-4c01-ad7b-0426c58a911c)
