#!/bin/bash
#모든 SUID 파일을 점검해 쓰기 가능한지 확인한후 출력한다.

mtime="7"
#시간 기준
verbose=0
#출력모드 

if [ "$1" = "-v" ] ; then
	vervose=1
fi
#-v 옵션 작성 시 출력 

find / -type f -perm /4000 -print0 | while read -d '' -r match
do
	if [ -x "$match" ] ; then
		owner="$(ls -ld $match | awk '{print $3}')"
		perms="$(ls -ld $match | cut -c5-10 | grep 'w')"

		if [ ! -z $perms ] ; then
			echo "**** $match (writeable and setuid $owner)"
		elif [ ! -z $(find $match -mtime -$mtime -print) ] ; then
			echo "**** $match (modified within $mtime days and setuid $owner)"
		elif [ $verbose -eq 1 ] ; then
			lastmod="$(ls -ld $match | awk '{print $6, $7, $8}')"
			echo "	$match (setuid $owner, last modified $lastmod)"
		fi
	fi
done

exit 0
