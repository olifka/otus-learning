# OTUS Learning
# Урок 16 "PAM"


# Задача
Запретить всем пользователям, кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников

# Решение:
Стенд поднимается автоматически из [Vagrantfile](Vagrantfile)

Для решения задачи в файл ```/etc/pam.d/sshd``` были добавлены строки:
```
...
account    sufficient   pam_listfile.so onerr=fail item=group sense=allow file=/etc/login.group.allowed
account    required     pam_time.so
...
```
Первая строка проверяет наличие группы в указанном файле и использует *control-flag* ```sufficient```, который позволяет пропустить следующие проверки. Опция *file=/etc/login.group.allowed* указывает файл, в котором перечислены группы, которым мы разрешаем доступ (*item=group sense=allow*). За счёт этого группам vagrant и admin разрешён доступ по ssh в любое время.

Следующая строка включает проверку доступа по времени и использует по-умолчанию для этого файл ```/etc/security/time.conf```. У меня в нём всего одна строка:
```
*;*;*;Wd # Разрешить всем доступ только по будням
```

Для проверки созданы пользователи test-user и test-admin + группа admin, в которую добавили одного из тестовых пользователей. Включена авторизация в ssh по паролю. Пароль у всех проверочных пользователей - 123

```
PS F:\OTUS\otus-learning\lesson-15> ssh -p 2222 test-admin@127.0.0.1
test-admin@127.0.0.1's password:
[test-admin@pamauth ~]$ logout # Подключение успешно, т.к. пользовательв группе admin
Connection to 127.0.0.1 closed.
PS F:\OTUS\otus-learning\lesson-15> ssh -p 2222 test-user@127.0.0.1
test-user@127.0.0.1's password:
Connection closed by 127.0.0.1 port 2222 # В консоль не пустило, подключение закрылось
```
