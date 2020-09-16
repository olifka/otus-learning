# OTUS Learning
# Урок 8 "Практические навыки работы с ZFS"


# Задача:

1. Определить алгоритм с наилучшим сжатием
2. Определить настройки pool’a
3. Найти сообщение от преподавателей

# Решение:

Само решение в скрипте [zfs.sh](zfs.sh)

# 1. Определить алгоритм с наилучшим сжатием
Создаём 5 папок и pool'ов для каждого типа сжатия:
```
mkdir /mnt/gzip9
mkdir /mnt/lz4
mkdir /mnt/lzjb
mkdir /mnt/zle
mkdir /mnt/dedup
zfs create gzip9/data
zfs create lz4/data
zfs create lzjb/data
zfs create zle/data
zfs create dedup/data
```
Устанавливаем тип сжатия для каждой ppol'а:
```
zfs set compress=gzip-9 gzip9/data
zfs set compress=lz4 lz4/data
zfs set compress=lzjb lzjb/data
zfs set compress=zle zle/data
zfs set dedup=on dedup/data
```
Скачиваем "Войну и мир" и копируем её в наши каталоги:
```
wget -q -O War_and_Peace.txt http://www.gutenberg.org/ebooks/2600.txt.utf-8
xargs -n 1 cp War_and_Peace.txt<<<"/mnt/gzip9/ /mnt/lz4/ /mnt/lzjb/ /mnt/zle/ /mnt/dedup/"
```
Получаем размер папок с помощью du -hs:
```
1024	/mnt/dedup/
1024	/mnt/gzip9/
1024	/mnt/lz4/
1024	/mnt/lzjb/
1024	/mnt/zle/
```
Копируем содержимое каталога /usr/share/man, смотрим занятое место:
```
12346368	/mnt/zle/
13079552	/mnt/dedup/
13153792	/mnt/gzip9/
13172224	/mnt/lz4/
13261312	/mnt/lzjb/
```
Копируем содержимое каталога /usr/bin, смотрим занятое место:
```
40675328	/mnt/gzip9/
51025408	/mnt/lz4/
54110720	/mnt/lzjb/
70258688	/mnt/zle/
85270528	/mnt/dedup/
```
Создаём файл 10МБ, заполненный нулями:
```
dd if=/dev/zero of=/tmp/0dummy bs=1 count=10000000
```
Копируем его 1 раз в наши папки, смотрим размер:
```
40675840	/mnt/gzip9/
51026944	/mnt/lz4/
54112256	/mnt/lzjb/
70260224	/mnt/zle/
95706112	/mnt/dedup/
```
Копируем его 5 раз в наши папки и смотрим размер:
```
40679424	/mnt/gzip9/
51029504	/mnt/lz4/
54114816	/mnt/lzjb/
70262784	/mnt/zle/
146185728	/mnt/dedup/
```
# Вывод:

На большом количестве случайных данных лучше всех показал себя gzip-9, однако скорость чтения/записи с таким методом сжатия ниже, чем у других.

Почётное второе место достаётся lz4 - разница по объёму с gzip невелика, однако гораздо меньше нагрузка на процессор.

Как говорит интернет, LZJB — оригинальный алгоритм в ZFS. Он устарел и больше не должен использоваться, LZ4 превосходит его по всем показателям.

ZLE - т.к. у нас нету больших последовательностей нулей, преимуществ этого алгоритма мы не заметили. Хотя, после копирования man-файлов в наши папки, он показал себя лучше всех. *Всегда знал, что в man'ах много воды))

Механизм дедупликации отработал как-то непонятно для меня. Может он даёт выигрыш в хранении больших однотипных файлов (видео, графика), но в нашем тесте такого не было.

# 2. Определить настройки pool’a

Скачиваем и разахивируем архив с заданием:
```
wget -q --no-check-certificate 'https://docs.google.com/uc?export=download&id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg' -O zfs_task1.tar.gz
tar xf zfs_task1.tar.gz
```
Импортируем скачанный pool в нашу систему:
```
zpool import -d zpoolexport otus
```
Получаем размер pool'а:
```
zpool get size otus
# zpool get all otus|grep size
# NAME  PROPERTY  VALUE  SOURCE
# otus  size      480M   -
```
По истории работы с pool'ом определяем его параметры:
тип pool'а, метод сжатия и checksum
```
zpool history otus|grep create
# 2020-05-15.04:00:58 zpool create otus mirror /root/filea /root/fileb
zpool history otus|grep checksum
# 2020-05-15.04:05:55 zfs set checksum=sha256 otus
zpool history otus|grep compression
# 2020-05-15.04:11:05 zfs set compression=zle otus
```
# Ответ:

Размер - 480M

Тип - mirror

checksum - sha256

compression - zle

# 3. Найти сообщение от преподавателей
Скачиваем файл с заданием и монтируем его в нашу систему:
```
wget -q --no-check-certificate 'https://docs.google.com/uc?export=download&id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG' -O otus_task2.file
zfs create otus/storage-task2
zfs receive otus/storage-task2 < otus_task2.file -F
```
Ищём файл с секретным посланием и выводим его командой echo
(Проверял файл утилитой file и пробовал открыть на редактирование в vi - 
ничего, кроме ссылки на github не нашёл):
```
secret_message=`find /otus/storage-task2/ -name secret_message`
cat $secret_message
# https://github.com/sindresorhus/awesome
```
# Ответ:
https://github.com/sindresorhus/awesome
