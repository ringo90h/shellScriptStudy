#!/bin/bash

# crontab 파일이 적절한 형식으로 만들어졌는지 확인한다.
# 표준 cron 표기법 min hr dom mon dow CMD
# 적정 값의 범위 min(0-59) hr(0-23) dom(1-31) mon(1-12) dow(0-7 또는 이름)
# 필드의 값은 범위형(0-0)과 콤마형(0,0,0) 또는 * 형태이다.


validNum(){
	# 주어진 값이 유효한 정수이면 0, 그렇지 않으면 1 리턴
	# 인자1: 값 // 인자2:최댓값
	num=$1	max=$2

	#값이 * 일 경우
	if [ "$num" = "X" ] ; then
		return 0
	#숫자 이외의 문자를 포함하고 있을 경우
	elif [ ! -z $(echo $num | sed 's/[[:digit:]]//g') ] ; then
		return 1
	#숫자가 최대값보다 클 경우
	elif [ $num -gt $max ] ; then
		return 1
	else
		return 0
	fi
}

validDay(){
	case $(echo $1 | tr '[:upper:]' '[:lower:]') in
		sun*|mon*|tue*|wed*|thu*|fri*|sat*) return 0 ;;
		X) return 0 ;;
		*) return 1
	esac
}

validMon(){
	#유효한 월 이름이 주어지면 0, 그렇지 않으면 1 리턴
	case $(echo $1 | tr '[:upper:]' '[:lower:]') in
		jan*|feb*|mar*|apr*}may|jun*|jul*|aug*) return 0 ;;
		sep*|oct*|nov*|dec*)	return 0 ;;
		X) return 0 ;;
		*) return 1 ;;
	esac
}

fixvars(){
	# 모든 '*'를 'X'로 변환해 셀 확장 문제를 피한다.
	#   오류 메시지를 위해 원래의 입력을 "sourceline"에 저장한다.

	sourceline="$min $hour $dom $mon $dow $command"
		min=$(echo "$min" | tr '*' 'X' )	#분
		hour=$(echo "$hour" | tr '*' 'X' )	#시
		dom=$(echo "$dom" | tr '*' 'X' )	#날짜
		mon=$(echo "$mon" | tr '*' 'X' )	#월
		dow=$(echo "$dow" | tr '*' 'X' )	#요일
}

if [$# -ne 1] || [ ! -r $1 ] ; then
	#파일 이름이 주어지지 않거나 파일을 읽을 수 없으면 실패
	echo "Usage: $0 usercrontabfile" >&2
	exit 1
fi

lines=0	entries=0	totalerrors=0

#crontab 파일을 한 줄씩 읽고 각각을 확인한다.

while read min hour dom mon dow command
do
	lines="$(( $lines + 1 ))"
	errors=0

	if [ -z "$min" -o "${min:0:1}}" = "#" ] ; then
		#빈 줄이거나 줄의 첫 글자가 #이면 건너뛴다.
		continue
	fi

	((entries++))

	fixvars

	#이 시점에서 현재 행의 모든 필드는 변수로 분해
	#모든 *는 X로 대치
	
	# 분 확인
	for minslice in $(echo "$min" | sed 's/[,-]/ /g'); do
		if ! validNum $minslice 60 ; then
			echo "Line ${lines}: Invalid minute value \"$minslice\""
			errors=1
		fi
	done

	# 시간 확인
	for hrslice in $(echo "$hour" | sed 's/[,-]/ / g'); do
		if ! validNum $hrslice 24 ; then
			echo "Line ${lines}: Invalid hour value \"$hrslice\""
			errors=1
		fi
	done

	#날짜 확인
	for domslice in $(echo $dom | sed 's/[,-]/ /g'); do
		if ! validNum $domslice 31 ; then
			echo "Line ${lines}: Invalid day of month value \"$domslice\""
			errors=1
		fi
	done

	#월 확인(이름or숫자)
	for monslice in $(echo "$mon" | sed 's/[,-]/ /g') ; do
		if ! validNum $monslice 12 ; then
			if ! validMon "$monslice" ; then
				echo "Line ${lines}: Invalid month value \"$monslice\""
				errors=1
			fi
		fi
	done

	#요일 확인(이름or숫자)
	for dowslice in $(echo "$dow" | sed 's/[,-]/ /g') ; do
		if ! validNum $dowslice 7 ; then
			if ! validDay $dowslice ; then
				echo "Line ${lines}: Invalid day of week value \"$dowslice\""
				errors=1
			fi
		fi
	done

	if [ $errors -gt 0 ] ; then
		echo ">>>> ${lines}: $sourceline"
		echo ""
		totalerrors="$(( $totalerrors + 1 ))"
	fi
done < $1
