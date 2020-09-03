#!/bin/bash

i=0
YEAR_TIME=(`awk -F " - - " '{print $2}' access-4560-644067.log|awk '{print $1}'|awk -F "/" '{print $1 " " $2 " " $3}'|awk '{print $3}'`)
DAY_MONTH=(`awk -F " - - " '{print $2}' access-4560-644067.log|awk '{print $1}'|awk -F "/" '{print $1 " " $2 " " $3}'|awk '{print $1 " " $2}'|sed -e 's/\[//g'|sed -e 's/ /-/g'|sed -e 's/Aug/08/g'`)
COUNTER=${#YEAR_TIME[*]}

while [ "$i" -lt "$COUNTER" ]
do
        #echo $i
        #echo $COUNTER
        YEAR=(`echo ${YEAR_TIME[$i]}|awk -F ":" '{print $1}'`)
        MONTH=(`echo ${DAY_MONTH[$i]}|awk -F "-" '{print $2}'`)
        DAY=(`echo ${DAY_MONTH[$i]}|awk -F "-" '{print $1}'`)
        HOUR=(`echo ${YEAR_TIME[$i]}|awk -F ":" '{print $2}'`)
        MINUTE=(`echo ${YEAR_TIME[$i]}|awk -F ":" '{print $3}'`)
        SECOND=(`echo ${YEAR_TIME[$i]}|awk -F ":" '{print $4}'`)
        TIMESTRING="$YEAR-$MONTH-$DAY $HOUR:$MINUTE:$SECOND EDT"
        TIMESTAMPS[$i]=`date -d "$TIMESTRING" +%s`
        #echo ${TIMESTAMPS[$i]}
        #echo ${TIMESTRING}
        (( i++ ))
done

#echo ${#TIMESTAMPS[*]}

exit 0

