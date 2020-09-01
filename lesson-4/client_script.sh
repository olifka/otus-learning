#!/bin/bash
# Копируем подготовленный файл с прописанным локальным репозиторием
# в папку настроек yum
cp /vagrant/local.repo /etc/yum.repos.d/local.repo
# Устанавливаем пакет
yum -y install nginx
echo -e "\n"
# Проверяем, что установился наш кастомный nginx, в выоде должна быть следующая строка:
# module=/root/nginx_upstream_check_module
nginx -V 2>&1 | tr -- - '\n' | grep module
echo -e "\n"
# Запускаемся и проверяем
systemctl start nginx
echo -e "\n"
systemctl status nginx
echo -e "\n"
exit 0
