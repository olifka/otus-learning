#!/bin/bash

i=0
YEAR_TIME=(`awk -F " - - " '{print $2}' access-4560-644067.log|awk '{print $1}'|awk -F "/" '{print $1 " " $2 " " $3}'|awk '{print $3}'`)
DAY_MONTH=(`awk -F " - - " '{print $2}' access-4560-644067.log|awk '{print $1}'|awk -F "/" '{print $1 " " $2 " " $3}'|awk '{print $1 " " $2}'|sed -e 's/\[//g'|sed -e 's/ /-/g'|sed -e 's/Aug/08/g'`)
IP_ADDRESSES=(`awk '{print $1}' access-4560-644067.log`)
REQUEST_TYPES=(`awk '{print $6}' access-4560-644067.log|sed -e 's/\"//g'`)
# echo ${REQUEST_TYPES[*]}

# COUNTER=${#YEAR_TIME[*]}
# while [ "$i" -lt "$COUNTER" ]
# do
#        # echo $i
#        # echo $COUNTER
#        YEAR=(`echo ${YEAR_TIME[$i]}|awk -F ":" '{print $1}'`)
#        MONTH=(`echo ${DAY_MONTH[$i]}|awk -F "-" '{print $2}'`)
#        DAY=(`echo ${DAY_MONTH[$i]}|awk -F "-" '{print $1}'`)
#        HOUR=(`echo ${YEAR_TIME[$i]}|awk -F ":" '{print $2}'`)
#        MINUTE=(`echo ${YEAR_TIME[$i]}|awk -F ":" '{print $3}'`)
#        SECOND=(`echo ${YEAR_TIME[$i]}|awk -F ":" '{print $4}'`)
#        TIMESTRING="$YEAR-$MONTH-$DAY $HOUR:$MINUTE:$SECOND EDT"
#        TIMESTAMPS[$i]=`date -d "$TIMESTRING" +%s`
#        # echo ${TIMESTAMPS[$i]}
#        # echo ${TIMESTRING}
#        (( i++ ))
# done

# echo ${#TIMESTAMPS[*]}
# echo ${IP_ADDRESSES[*]}

TOP_IP=`(IFS=$'\n'; sort <<< "${IP_ADDRESSES[*]}") | uniq -c | awk '{print $1 " " $2}' | sort -nr`
# echo $TOP_IP|awk '{print $1 " " $2}'

COUNTER=10
i=0
j=1
while [ "$i" -ne "$COUNTER" ]
do
	echo "${TOP_IP[$i]} ${TOP_IP[$j]}"
	(( i++ ))
	(( j++ ))
	echo $i
done

exit 0
