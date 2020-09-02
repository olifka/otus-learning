# OTUS Learning
# Урок 5 "Управление пакетами. Дистрибьюция софта"


# Задача:

Размещаем свой RPM в своем репозитории
1) создать свой RPM (можно взять свое приложение, либо собрать к примеру апач с определенными опциями)
2) создать свой репо и разместить там свой RPM
реализовать это все либо в вагранте, либо развернуть у себя через nginx и дать ссылку на репо 


# Решение:

Скрипты [repo_script.sh](repo_script.sh) и [client_script.sh](client_script.sh) выполняют первичную подготовку сервера-репозитория и клиента соответственно.

Также заранее подготовлены файлы:
* [nginx.spec](nginx.spec) - подготовленная спека для сборки кастомного nginx. Отличается от оригинальной строкой "--add-module=/root/nginx_upstream_check_module-master" (добавляет в нашу сборку пропатченный нами модуль upstream_check)
* [repos.conf](repos.conf) - настройки nginx для работы в качестве репозитория (включён автоиндекс на папку /var/www/html/repos)
* [local.repo](local.repo) - настройки клиента для использования нашего локального репозитория

Скрипт [repo_script.sh](repo_script.sh) скачивает исходники nginx, применяет к нему патч для модуля upstream_check и совершает сборку пакета. Далее кастомный пакет копируется в папку /var/www/html/repos, в которой инициализируется репозиторий. Папка "скармливается" nginx'у на автоиндекс.

Скрипт [client_script.sh](client_script.sh) включает на клиентской машине использование нашего репозитория по IP-адресу внутренней сети и производит установку nginx.

Подробнее путь выполнения описан в виде комментариев к скриптам [repo_script.sh](repo_script.sh) и [client_script.sh](client_script.sh)