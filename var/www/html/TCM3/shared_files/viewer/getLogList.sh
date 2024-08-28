#!/bin/bash

echo -n "Finished,"
cd $1

recent_time=$2
if [[ $recent_time == "" ]]
then
	recent_time=30;
fi
find *.log -mmin -$recent_time | while read line
do 
	if [[ `head -1 $line` == "Started" && `tail -1 $line` == "-done-" ]]; 
	then 
		echo -n "$line,`head -2 $line | tail -1`,`head -3 $line | tail -1`,"
	fi
done

echo -n "Running,"
find *.log -mmin -1000 | while read line
do
        if [[ `head -1 $line` == "Started" && `tail -1 $line` != "-done-" ]];
        then
                echo -n "$line,`head -2 $line | tail -1`,`head -3 $line | tail -1`,"
        fi
done
echo -n "done,"
