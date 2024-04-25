### Task list
- [x] 1) Установка необходимых пакетов
- [x] 2) Описание perf
- [X] 3) Описание perf stat 
- [X] 4) Описание perf mem
- [x] 5) Описание iostat
- [x] 6) Описание perf ftrace и perf trace
- [x] 7) Описание lsof
- [x] 8) Интересные программы
- [x] 9) psutil - это lsof для python [Link](https://psutil.readthedocs.io/en/release-3.0.1/index.html?highlight=open%20files#psutil.Process.open_files)
- [x] 10) Strace подробное описание

#### Установим необходимые пакеты
Команда для **Ubuntu** 
```Bash
$ sudo apt install linux-tools-common
```
* При установке может появиться ошибка зависимостей и конфликта пакетов - в этом случае **следуем советам из терминала** и в случае острой необходимости можно удалять конфликтные пакеты. 


#### Краткое описание команд утилиты **perf**
1) **buildid-cache** Управление кэшем идентификаторов сборки.
2) **daemon** Запуск сеансов записи в фоновом режиме
4) **ftrace** простая оболочка для функциональности ядра ftrace
5) **inject** фильтр, чтобы дополнить (или урезать) поток событий дополнительной информацией
6) **iostat** Показать показатели производительности ввода-вывода
7)  **kallsyms** Ищет символы в работающем ядре
8)  **kmem** Инструмент для отслеживания/измерения свойств памяти ядра
9)  **kvm** для отслеживания/измерения гостевой ОС KVM
10) **list** Список всех типов символических событий
11) **lock** Анализ событий блокировки
12) **mem** Доступ к памяти профиля
13) **stat** Запустите команду и соберите статистику счетчика производительности
14) **trace** Инструмент трассировки

Мне кажется, что полезными будут команды `stat, iostat, mem, lock, ftrace, trace`

#### sudo perf stat
1) -С <num process> -- смотрит ресурсы процесса
2) -D, --delay <n> -- ms задержка перед началом измерения после запуска программы
3) -a, --all-cpus -- сморит ресурсы всех процессов вместе
4) -p, --pid <pid> -- смотрит ресурсы процесса. Пример `python tt.py & sudo perf stat -p $!` запускаем демон программу, вытягиваем pid и вызываем sudo perf stat -p.
5) -o, --output <file> -- имя выходного файла (удобно). Пример `python tt.py & sudo perf stat -p $! -o out.txt`
6) -v, --verbose -- расширенные логи (не очень расширенные). Пример `python tt.py & sudo perf stat -v -p $! -o output_v.txt`

Разницу между режимом v и без [Файле п.5](logs/output.txt)  и [Файле п.6](logs/output_v.txt)


#### sudo perf mem
Применяется sudo perf mem:
1) record  --  запись информации
2) report  --  представление информации

При выполнении record с различными флагами формиурется файл **perf.data**
Чтобы его прочитать необходимо выполнить команду 2 `perf mem report`, появится окошко, в котором можно посмотреть вывод файла:
![image](https://github.com/moevm/os_profiling/assets/90711883/bfded735-c6f2-49be-9ec3-8c68049a7e77)

#### Описание iostat
Выполним команду, чтобу установить iostat `sudo apt install sysstat`
Программа имеет малый функционал, я придумал мини-скрипт, который раз в 0.3 секунды вызывает `iostat -t -x`:
```Bash
while [ 1 ]
do
   iostat -t -x 
   sleep .3
   clear
done
```
Результат работы скрипты: 
![image](https://github.com/moevm/os_profiling/assets/90711883/11f1208e-9da1-433a-8cb5-4b4e6e652a29)


Есть идея записывать изменнение выходных значений и какие-то графики, может быть, строить...




#### Описание perf ftrace и perf trace
1) `sudo perf trace` - ничего интересного, обычная как будто обертка, как в скриптах из [Простых скриптов ftrace](cpu_tracer.md)
2) `sudo perf trace` - генерирует тысячу миллионов строк, которые, такое чувство, что здраво анализировать сложно:
   ![image](https://github.com/moevm/os_profiling/assets/90711883/9d3cdf05-0f75-41c8-a9e3-618e15e00973)


#### Описание lsof
При вводе команды lsof вывод формируется по следующем принципу:
```
COMMAND     PID   TID TASKCMD               USER   FD      TYPE             DEVICE  SIZE/OFF       NODE NAME
chrome     3633                         oumuamua  208r      REG                8,2    126400    8260929 /home/oumuamua/.config/google-chrome/Safe Browsing/UrlUws.store.4_13352470830264015
chrome     3633                         oumuamua  209u     unix 0x0000000000000000       0t0     107082 type=STREAM
chrome     3633                         oumuamua  210u     sock                0,8       0t0      90556 protocol: UNIX-STREAM
```

В системе без нагрузки эта команда генерирует 180.000 строк -- при записи в файл получается файл на 30мб  
+ Опция -U позволяет вывести все файлы сокетов домена Unix.
+ Опция -c позволяет вывести сведения о файлах, которые держат открытыми процессы, выполняющие команды (например -с chrome)
+ Опция +d позволяет выяснить, какие папки и файлы открыты в некоей директории (но не в её поддиректориях) - принимает аргумент - абсолютный или относительный путь
+ Опция -p позволяет вывести все файлы, открытые процессом с указанным при вызове команды PID (например -p 1) 

Более полное описание:
```
Defaults in parentheses; comma-separated set (s) items; dash-separated ranges.
  -?|-h list help          -a AND selections (OR)     -b avoid kernel blocks
  -c c  cmd c ^c /c/[bix]  +c w  COMMAND width (9)    +d s  dir s files
  -d s  select by FD set   +D D  dir D tree *SLOW?*   +|-e s  exempt s *RISKY*
  -i select IPv[46] files  -K [i] list|(i)gn tasKs    -l list UID numbers
  -n no host names         -N select NFS files        -o list file offset
  -O no overhead *RISKY*   -P no port names           -R list paRent PID
  -s list file size        -t terse listing           -T disable TCP/TPI info
  -U select Unix socket    -v list version info       -V verbose search
  +|-w  Warnings (+)       -X skip TCP&UDP* files     -Z Z  context [Z]
  -- end option scan     
  -E display endpoint info              +E display endpoint info and files
  +f|-f  +filesystem or -file names     +|-f[gG] flaGs 
  -F [f] select fields; -F? for help  
  +|-L [l] list (+) suppress (-) link counts < l (0 = all; default = 0)
                                        +m [m] use|create mount supplement
  +|-M   portMap registration (-)       -o o   o 0t offset digits (8)
  -p s   exclude(^)|select PIDs         -S [t] t second stat timeout (15)
  -T qs TCP/TPI Q,St (s) info
  -g [s] exclude(^)|select and print process group IDs
  -i i   select by IPv[46] address: [46][proto][@host|addr][:svc_list|port_list]
  +|-r [t[m<fmt>]] repeat every t seconds (15);  + until no files, - forever.
       An optional suffix to t is m<fmt>; m must separate t from <fmt> and
      <fmt> is an strftime(3) format for the marker line.
  -s p:s  exclude(^)|select protocol (p = TCP|UDP) states by name(s).
  -u s   exclude(^)|select login|UID set s
  -x [fl] cross over +d|+D File systems or symbolic Links
  names  select named files or files on named file systems
```

#### Python psutil
Это Python библиотека, которая  реализует множество функций, предлагаемых инструментами командной строки, такими как: ps, top, lsof, netstat, ifconfig, who, df, kill, free, nice, ionice, iostat, iotop, uptime, pidof, tty, Taskset, pmap.  
В контексте задачи рассмотрим функции для **lsof**, для примеров использования библиотеки создан [файл](psutil_lsof.md), в котором рассмотрены аналоги следующих функций lsof:  
1) lsof -p <pid>
2) lsof -i
3) lsof -p <pid> | grep mem
4) lsof +d

#### Strace подробное описание
Конфигурация трассировки:
1. `-e trace=` : Позволяет выбрать, какие типы системных вызовов трассировать. Например:
   - `- trace=open` : трассировать только вызовы открытия файлов
   - `- trace=write` : трассировать только вызовы записи в файл
   - `- trace=all` : трассировать все системные вызовы
   
2. `-o filename` : Записывает вывод трассировки в указанный файл.

Основные флаги:  
1) **-p PID** - позволяет подключиться к уже выполняющемуся процессу по его PID
2) **-c** - выводит статистику использования системных вызовов в конце выполнения программы
3) **-f** - отслеживает системные вызовы для всех порожденных процессов\
4) **-s < size bites >** - ограничивает длину выводимых данных для каждого системного вызова

С помощью **strace** можно трассировать ram rom cpu net:
1) `strace -c ./program` - трассировка системных вызовов (cpu)
2) `strace -v -r -T ./program` - трассировка ram - флаги -v -r -T позволяют настроить вывод:  
       a) флаг v  позволяет выводить дополнительные подробности о системных вызовах, такие как значения аргументов и возвращаемые значения  
       b) флаг r  позволяет выводить время, проведенное в каждом системном вызове в формате относительного времени
       c) флаг T  позволяет отображать временные метки для каждого системного вызова, указывая время с начала работы программы в микросекундах
3) `strace -e trace=file,read,write` - тут тоже на выбор - чтение/запись
4) `strace -e trace=network ./program` - формирует строки выводы примерно так: socket, connect, sendto, recv 
#### Интересные программы
[python memory_profiler](https://github.com/pythonprofilers/memory_profiler)     
Вывод примерно такой `Line # Mem usage Increment Occurrences Line Contents`




  
