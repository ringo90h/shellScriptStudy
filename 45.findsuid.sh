#!/bin/bash
#모든 SUID 파일을 점검해 쓰기 가능한지 확인한후 출력한다.

#시간 기준
mtime="7"
#출력모드 
verbose=0

#-v 옵션 작성 시 출력 
if [ "$1" = "-v" ] ; then
	vervose=1
fi

#-type f :파일만 검색 -perm /4000 : 권한 4000이상만 검색 -print0 한줄로 출력
#read -d: -r:'\'를 문자 그대로 해석match:변수명
find / -type f -perm /4000 -print0 | while read -d '' -r match
do
	#검색된 결과가 실행 가능할 경우
	if [ -x "$match" ] ; then
		#소유자명 변수에 입력
		owner="$(ls -ld $match | awk '{print $3}')"
		#권한 변수에 입력(w포함한 경우만)
		perms="$(ls -ld $match | cut -c5-10 | grep 'w')"

		#권한이 있을 경우(w가포함되어 있을 경우)
		if [ ! -z $perms ] ; then
			echo "**** $match (writeable and setuid $owner)"
		#권한이 없고 최근 수정된 흔적이 있을 경우
		elif [ ! -z $(find $match -mtime -$mtime -print) ] ; then
			echo "**** $match (modified within $mtime days and setuid $owner)"
		#상세 모드가 켜있으면 수정 기록 출력 
		elif [ $verbose -eq 1 ] ; then
			lastmod="$(ls -ld $match | awk '{print $6, $7, $8}')"
			echo "	$match (setuid $owner, last modified $lastmod)"
		fi
	fi
done

exit 0
