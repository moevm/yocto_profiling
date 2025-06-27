### Auto Configuration File: `local.conf`

A file named `auto_compose_local_conf.py` has been developed. In its current version, it is expected to be executed from the `build` directory. Whether this is correct or not will be clarified later, during the orchestration stage of experimental builds.

For the script to function properly, it requires a configuration file `experiment.conf` to be placed in the same directory.

Example contents of `experiment.conf`:
```
[SSH]
cache_ip = 10.138.70.6
cache_usr = user
hash_ip = 10.138.70.23
hash_usr = user

[SERVERS]
cache_start_port = 9000
cache_num_port = 10
hash_port = 8686
```
Variable names must match exactly.

---

### Interface for Working with the Config File

The configuration file is formatted according to the `configparser` format from the Python standard library.  
It contains two sections: `SSH` and `SERVERS`.

- The **SSH** section defines parameters for SSH connections — usernames and IPs of the cache and hash servers.
- The **SERVERS** section contains parameters for the experiment itself — starting port and the number of ports on the cache server, as well as the hash server port (IP addresses are taken from the SSH section and not repeated here).

---

#### Working with the Config File in Python

The file `config_parser.py` provides three functions: one for reading a single variable, one for reading the entire config, and one for writing a variable.

1. `read_from_config(file_name, section_name, variable_name)`  
   Returns the value of the specified variable from the given file and section as a string.

2. `print_config(file_name)`  
   Prints the full contents of the specified config file to the console.

3. `write_to_config(file_name, section_name, variable_name, variable_value)`  
   Writes the specified value to the specified variable in the given section and config file.

---

#### Working with the Config File in Bash

In the file `read_config.sh`, a function `process_config` is implemented, which reads variables from a config file and applies them via `source`.

Since `configparser`-style config files require section headers (`[SECTION]`) and typically include spaces around `=`, the function creates a temporary copy of the config, reformats it into a style suitable for `source`, sources it, and deletes the temporary file afterward.

A demonstration script `example_using_read_config.sh` is also provided, which imports the function and makes use of the variables from the config file.
