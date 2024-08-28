#!/bin/bash

echo -n "Finished,"
cd /var/www/html/TCM3/NetsimSite/log/
find *.log -cmin -30 | while read line
do 
	if [[ `tail -1 $line` == "-done-" ]]; 
	then 
		echo -n "$line,`head -2 $line | tail -1`,`head -3 $line | tail -1`,"
	fi
done

echo -n "Running,"
find *.log -mmin -200 | while read line
do
        if [[ `tail -1 $line` != "-done-" ]];
        then
                echo -n "$line,`head -2 $line | tail -1`,`head -3 $line | tail -1`,"
        fi
done
echo -n "done,"
