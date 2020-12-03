# OTUS Learning
# Урок 17 "Практика с SELinux"


# Задача 1
Запустить nginx на нестандартном порту 3-мя разными способами:
- переключатели setsebool;
- добавление нестандартного порта в имеющийся тип;
- формирование и установка модуля SELinux.

# Задача 2
Обеспечить работоспособность приложения при включенном selinux.
- Развернуть приложенный стенд
https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems
- Выяснить причину неработоспособности механизма обновления зоны (см. README);
- Предложить решение (или решения) для данной проблемы;
- Выбрать одно из решений для реализации, предварительно обосновав выбор;
- Реализовать выбранное решение и продемонстрировать его работоспособность.

# Решение:

## Задача 1

### Переключатели setsebool

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
[root@nginx ~]# audit2why < /var/log/audit/audit.log
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
setsebool -P nis_enabled 1
```

### Добавление нестандартного порта в имеющийся тип

Поменяем порт прослушивания на 23456 и попробуем добавить его в имеющийся тип *http_port_t*:
```
semanage port -a -t http_port_t -p tcp 23456 && systemctl restart nginx
```
Всё работает! Можно проверить - ```curl http://127.0.0.1:23456```

### Формирование и установка модуля SELinux
