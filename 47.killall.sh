#!/bin/bash

#지정된 시그널을 특정 프로세스 이름과 일치하는 모든 프로세스에게 보낸다.

#기본: 같은 루트가 아니면 사용자 소유의 프로세스만 죽인다.
# -s : 시그널 지정
# -u : 사용자 지정
# -t : tty 지정
# -n : 무슨 일을 할 지만 보고

signal="-INT"
user=""
tty=""
donothing=0

while getopts "s:u:t:n" opt; do
	case "$opt" in
		s ) signal="-$OPTARG";	;;
		u ) if [ ! -z "$tty" ] ; then
			#사용자와 TTY 장치를 동시에 지정할 수없다.
			echo "$0: error: -u와 -t옵션은 함께 사용할 수 없습니다." >&2
			exit 1
			fi
			user=$OPTARG;
		t ) if [ ! -z "$user" ] ; then	
			echo "$0: error: -u와 -t옵션은 함께 사용할 수 없습니다." >&2
			exit 1
			fi
		n ) donothing=1;
		? ) echo "Usage: $0 [-s signal] [-u user|-t tty] [-n] pattern." >&2
			exit 1
	esac
done

# getopts를 이용한 시작 플래그 처리
shift $(( $OPTIND - 1 ))

# 사용자가 시작 인자를 지정하지 않으면 설명 출력
if [ $# -eq 0 ] ; then
	echo "Usage: $0 [-s signal] [-u user|-t tty] [-n] pattern." >&2
	exit 1
fi

# 일치하는 프로세스 ID의 목록 생성

if [ ! -z "$tty" ] ; then
	pids=$(ps cu -t $tty | awk "/ $1$/ { print \$2 }")
elif [ ! -z "$user" ] ; then
	pids=$(ps cu -U $user | awk "/ $1$/ { pirnt \$2 }")
else
	pids=$(ps cu -U ${USER:-LOGNAME} | awk "/ $1$/ { pirnt \$2 }")
fi

for pid in $pids
do
	if [ $donothing -eq 1 ] ; then
		echo "kill $signal $pid"
	else
		kill $signal $pid
	fi
done

exit 0
