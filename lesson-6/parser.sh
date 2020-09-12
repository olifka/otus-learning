#!/bin/bash

i=0
filename='access.log'
ALL_IPS=(`awk '{print $1}' $filename`)
ALL_DATES=(`awk '{print  $4}' $filename|sed -e 's/\[//g'|sed -e 's/\//:/g'|date +"%d:Aug:%Y:%H:%M:%S" -f -`)
ALL_CODES=(`awk '{print  $9}' $filename`)
REQUEST_TYPES=(`awk '{print $6}' $filename|sed -e 's/\"//g'`)
# echo ${ALL_IPS[*]}
echo ${ALL_DATES[*]}
# echo ${REQUEST_TYPES[*]}
# echo ${ALL_CODES[*]}


exit 0
