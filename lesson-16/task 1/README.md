# OTUS Learning
# Урок 17 "Практика с SELinux"


## Задача 1
Запустить nginx на нестандартном порту 3-мя разными способами:
- переключатели setsebool;
- добавление нестандартного порта в имеющийся тип;
- формирование и установка модуля SELinux.

## Задача 2
Обеспечить работоспособность приложения при включенном selinux.
- Развернуть приложенный стенд
https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems
- Выяснить причину неработоспособности механизма обновления зоны (см. README);
- Предложить решение (или решения) для данной проблемы;
- Выбрать одно из решений для реализации, предварительно обосновав выбор;
- Реализовать выбранное решение и продемонстрировать его работоспособность.

# Решение:

## Задача 1 - Запустить nginx на нестандартном порту 3-мя разными способами

## Переключатели setsebool

В файле ```/etc/nginx/nginx.conf``` меняем параметр *listen* на нестандартный порт 12345. Пытаемся рестартовать nginx, получаем ошибку:
```
-- Unit nginx.service has begun starting up.
Dec 03 22:59:23 nginx nginx[3895]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Dec 03 22:59:23 nginx nginx[3895]: nginx: [emerg] bind() to 0.0.0.0:12345 failed (13: Permission denied)
Dec 03 22:59:23 nginx nginx[3895]: nginx: configuration file /etc/nginx/nginx.conf test failed
Dec 03 22:59:23 nginx systemd[1]: nginx.service: control process exited, code=exited status=1
Dec 03 22:59:23 nginx systemd[1]: Failed to start The nginx HTTP and reverse proxy server.
```
Делаем проверку с помощью *audit2why*:
```
~# audit2why < /var/log/audit/audit.log
type=AVC msg=audit(1607036363.386:1158): avc:  denied  { name_bind } for  pid=3895 comm="nginx" src=12345 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

        Was caused by:
        The boolean nis_enabled was set incorrectly.
        Description:
        Allow nis to enabled

        Allow access by executing:
        # setsebool -P nis_enabled 1
```
Используем подсказку системы, выдаём разрешение:
```
setsebool -P nis_enabled 1 && systemctl restart nginx
```
После проверки работоспособности nginx'а, возвращаем всё обратно, т.к. этот параметр больно много чего открывает, и следующие тесты просто не будут иметь смысла:
```
setsebool -P nis_enabled 0
```

## Добавление нестандартного порта в имеющийся тип

В ```/etc/nginx/nginx.conf``` поменяем порт прослушивания на 23456 - опять ничего не стартует. При помощи всё того же ```audit2why``` понимаем, что nginx работает в контексте типа *http_port_t*.
Пробуем добавить туда наш новый порт:
```
~# semanage port -a -t http_port_t -p tcp 23456 && systemctl restart nginx
```
Всё работает! Можно проверить - ```curl http://127.0.0.1:23456```

## Формирование и установка модуля SELinux

Делал по статья с Habr'а - https://habr.com/ru/post/320100/

Компиляция и установка модуля происходит при разворачивании стенда (см. [Vagrantfile](Vagrantfile))

Созданы файлы с [описанием базовых типов](nginx_custom.te) и [файл контекстов](nginx_custom.fc), из которых собирается наш модуль.

На родные файлы и каталоги nginx'а сделаны символьные ссылки, т.к. при установке нашего собственного модуля (```semodule -i nginx_custom.pp```) вылезает ошибка, что они используются в других местах в *selinux*:
```
/etc/selinux/final/targeted/contexts/files/file_contexts: Multiple different specifications for /etc/nginx(/.*)?  (system_u:object_r:nginx_custom_conf_t:s0 and system_u:object_r:httpd_config_t:s0).
/etc/selinux/final/targeted/contexts/files/file_contexts: Multiple different specifications for /var/log/nginx(/.*)?  (system_u:object_r:nginx_custom_log_t:s0 and system_u:object_r:httpd_log_t:s0).
...
/etc/selinux/final/targeted/contexts/files/file_contexts: Invalid argument
libsemanage.semanage_validate_and_compile_fcontexts: setfiles returned error code 1.
```
После разворотки стенда в файле ```/etc/nginx/nginx.conf``` меняем *listen_port* на 34567, делаем ```systemctl restart nginx```, и радуемся, что всё работает.

## Задача 2 - Обеспечить работоспособность приложения при включенном selinux

РЕШЕНИЕ
