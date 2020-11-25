# OTUS Learning
# Урок 11 "Инициализация системы. Systemd."


# Задача 1
Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig)

# Решение:
По методичке создал четыре файла:
* [sysconfig-watchlog](sysconfig-watchlog) - файл с переменными для работы юнита
* [watchlog.service](watchlog.service) - описание юнита systemd
* [watchlog.sh](watchlog.sh) - рабочий скрипт, вызываемый юнитом (```ExecStart```)
* [watchlog.timer](watchlog.timer) - таймер для запуска нашего юнита (раписание событий)

Всё заработало почти сразу, исправил только ошибку в [watchlog.service](watchlog.service) - поправил путь до ```/etc/sysconfig```

# Задача 2
Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi)

# Решение:

По методичке родготовлены файлы [spawn-fcgi.service](spawn-fcgi.service) и [sysconfig-spawn-fcgi](sysconfig-spawn-fcgi). Всё запускается и работает:
```
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2020-11-25 12:04:27 EST; 6min ago
 Main PID: 2409 (php-cgi)
    Tasks: 33 (limit: 38559)
   Memory: 18.9M
   CGroup: /system.slice/spawn-fcgi.service
           ├─2409 /usr/bin/php-cgi
           ├─2410 /usr/bin/php-cgi
           ├─2411 /usr/bin/php-cgi
           ├─2412 /usr/bin/php-cgi
           ├─2413 /usr/bin/php-cgi
           ├─2414 /usr/bin/php-cgi
           ├─2415 /usr/bin/php-cgi
```

# Задача 3
Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами

# Решение
РЕШЕНИЕ

# Задача 4
Скачать демо-версию Atlassian Jira и переписать основной скрипт запуска на unit-файл

# Решение
РЕШЕНИЕ