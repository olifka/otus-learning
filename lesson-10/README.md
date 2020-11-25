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

По методичке подготовлены файлы [spawn-fcgi.service](spawn-fcgi.service) и [sysconfig-spawn-fcgi](sysconfig-spawn-fcgi). Всё запускается и работает:
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
Также по методичке - в дефолтовый юнит httpd добавлена опция ```EnvironmentFile=/etc/sysconfig/httpd-%I```

Конфигурационные файлы /etc/httpd?conf/first.conf и conf/second.conf являются копией основного конфига conf/httpd.conf, в них изменил только параметр ```ListenPort```, пути к логам и дополнительным конф.файлам (```/first-conf.d/*```, ```/second-conf.d/*```)

*systemctl status httpd@first:*
```
● httpd@first.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd@.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2020-11-25 12:48:50 EST; 1min 49s ago
     Docs: man:httpd@.service(8)
  Process: 27336 ExecStartPre=/bin/chown root.apache /run/httpd/instance-first (code=exited, status=0/SUCCESS)
  Process: 27334 ExecStartPre=/bin/mkdir -m 710 -p /run/httpd/instance-first (code=exited, status=0/SUCCESS)
 Main PID: 27338 (httpd)
   Status: "Running, listening on: port 8080"
    Tasks: 213 (limit: 38559)
   Memory: 24.8M
   CGroup: /system.slice/system-httpd.slice/httpd@first.service
           ├─27338 /usr/sbin/httpd -DFOREGROUND -f conf/first.conf
           ├─27339 /usr/sbin/httpd -DFOREGROUND -f conf/first.conf
           ├─27340 /usr/sbin/httpd -DFOREGROUND -f conf/first.conf
           ├─27341 /usr/sbin/httpd -DFOREGROUND -f conf/first.conf
           └─27342 /usr/sbin/httpd -DFOREGROUND -f conf/first.conf
```

# Задача 4
Скачать демо-версию Atlassian Jira и переписать основной скрипт запуска на unit-файл

# Решение
Так оказалось, что я являюсь действующим администратором JIRA. Запуск сервиса осуществялется с помощью следующего юнита:

```
# /usr/lib/systemd/system/jira.service
[Unit]
Description="JIRA Server"

[Service]
Type=forking

[Unit]
Description="JIRA Server"

[Service]
Type=forking
User=jira
Environment="JIRA_HOME=/var/atlassian/application-data/jira"
Environment="JRE_HOME=/opt/java/default"
ExecStart=/opt/atlassian/jira/bin/start-jira.sh
ExecStop=/opt/atlassian/jira/bin/stop-jira.sh
TimeoutSec=180
Restart=on-failure
UMask=0022

[Install]
WantedBy=multi-user.target
```
