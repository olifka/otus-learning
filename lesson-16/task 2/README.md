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
echo -e "server 192.168.50.10\nzone ddns.lab\nupdate add www.ddns.lab. 60 A 192.168.50.15\nsend"|nsupdate -k /etc/named.zonetransfer.key
```
Ловим ошибку на nameserver'е:
```
~# audit2why < /var/log/audit/audit.log
type=AVC msg=audit(1602508518.573:1963): avc:  denied  { create } for  pid=23809 comm="isc-worker0000" name="named.ddns.lab.view1.jnl" scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=0

      Was caused by:
               Missing type enforcement (TE) allow rule.

               You can use audit2allow to generate a loadable module to allow this access.

audit2allow -M selinux --debug < /var/log/audit/audit.log
```
Рубим с плеча - по совету бездушной машины создаём модуль SELinux (на машине *ns01*)
```
~# audit2allow -M allow-ddns --debug < /var/log/audit/audit.log
```
Ради интереса глянем сгенерённый для нас *allow-ddns.te*:
```
~# cat allow-ddns.te

module allow-ddns 1.0;

require {
        type etc_t;
        type named_t;
        class file create;
}

#============= named_t ==============

#!!!! WARNING: 'etc_t' is a base type.
allow named_t etc_t:file create;
```
Как я понял, нашему домену named_t надо работать через домен etc_t
Но мы продолжим махания топром:

```semodule -i selinux.pp && systemctl restart named``` на сервере
И повторная попытка обновления зоны на клиенте (опять с ошибкой).
Смотрим, в чём проблема:
~# audit2why < /var/log/audit/audit.log

type=AVC msg=audit(1602508518.573:1963): avc:  denied  { create } for  pid=23810 comm="isc-worker0000" name="named.ddns.lab.view1.jnl" scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=0

      Was caused by:
               Unknown - would be allowed by active policy
               Possible mismatch between this policy and the one under which the audit message was generated.

               Possible mismatch between current in-memory boolean settings vs. permanent ones.
```

По-русски система говорит, что 