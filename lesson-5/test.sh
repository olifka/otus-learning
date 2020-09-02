#!/bin/bash
exec 0<>/dev/console 1<>/dev/console 2<>/dev/console
echo -e "\nLoading my test module...\n"
sleep 10
echo -e "\n continuing....\n"
exit 0
