#!/bin/bash
#실행 가능한 명령어가 몇 개가 있는지 계산하는 스크립트

IFS=":"
count=0
nonex=0
for directory in $PATH ; do
	if [ -d "$directory" ] ; then
		for command in "$directory"/* ; do
			if [ -x "$command" ] ; then
				count="$(( $count + 1 ))"
			else
				nonex="$(( $nonex + 1 ))"
			fi
		done
	fi
done

echo "$count commands, and $nonex entries that weren't executable"

exit 0 
