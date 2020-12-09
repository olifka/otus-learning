# OTUS Learning
# Урок 17 "Практика с SELinux"


## Задача 2
Обеспечить работоспособность приложения при включенном selinux.
- Развернуть приложенный стенд
https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems
- Выяснить причину неработоспособности механизма обновления зоны (см. README);
- Предложить решение (или решения) для данной проблемы;
- Выбрать одно из решений для реализации, предварительно обосновав выбор;
- Реализовать выбранное решение и продемонстрировать его работоспособность.

# Решение:

После подъёма стенда на client'е делаем:
```
~$ echo -e "server 192.168.50.10\nzone ddns.lab\nupdate add www.ddns.lab. 60 A 192.168.50.15\nsend"|nsupdate -k /etc/named.zonetransfer.key
```
Ловим ошибку на nameserver'е
```
~# audit2why < /var/log/audit/audit.log

type=AVC msg=audit(1602508518.573:1963): avc:  denied  { create } for  pid=23809 comm="isc-worker0000" name="named.ddns.lab.view1.jnl" scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=0

      Was caused by:
               Missing type enforcement (TE) allow rule.

               You can use audit2allow to generate a loadable module to allow this access.
```

Создаём модуль SELinux, устанавливаем его и перезапускаем сервис
```
~# audit2allow -M allow-ddns --debug < /var/log/audit/audit.log
~# semodule -i selinux.pp && systemctl restart named
```
Повторная попытка обновления зоны на клиенте опять с ошибкой. Снова смотрим, в чём проблема
```
~# audit2why < /var/log/audit/audit.log

type=AVC msg=audit(1602508518.573:1963): avc:  denied  { create } for  pid=23810 comm="isc-worker0000" name="named.ddns.lab.view1.jnl" scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=0

      Was caused by:
               Unknown - would be allowed by active policy
               Possible mismatch between this policy and the one under which the audit message was generated.

               Possible mismatch between current in-memory boolean settings vs. permanent ones.
```

Cистема сообщает, что возможно расхождение, между переменными selinux, сохранёнными в памяти, и записанными в конфиг.
Смотрим тип контекста файлов:
```
~# ls -Z /etc/named/dynamic/
```
Меняем тип контекста файлов
```
~# chcon -R -t named_zone_t /etc/named/dynamic/
~# semanage fcontext -a -t named_zone_t /etc/named/dynamic/
```
Удаляем файл ```/etc/named/dynamic/named.ddns.lab.view1.jnl``` и презапускаем *named*
Проверяем на клиенте
```
~$ echo -e "server 192.168.50.10\nzone ddns.lab\nupdate add www.ddns.lab. 60 A 192.168.50.15\nsend"|nsupdate -k /etc/named.zonetransfer.key

~$ nslookup www.ddns.lab
Server:         192.168.50.15
Address:        192.168.50.15#53

Authoritative answer:
Name:   www.ddns.lab
Address: 192.168.50.10
```
