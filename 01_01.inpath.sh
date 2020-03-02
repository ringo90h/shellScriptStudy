#!/bin/bash
#inpath--특정 프로그램이 유효한지, PATH 디렉터리 목록에서 찾을 수 있는지 확인한다.

in_path()
{
	cmd=$1
	outpath=$2
	result=1
	for directory in "$outpath"
	do
		if [ -x $directory/$cmd ] ; then
			result=0
		fi
	done

	return $result
}

checkForCmdInPath()
{
	var=$1
	
	if [ "$var" != "" ] ; then
		#인자의 첫글자가 "/"일 경우
		if [ "${var:0:1}" = "/" ] ; then
			#인자가 실행 불가능할 경우
			if [ ! -x $var ] ; then
				return 1
			fi
		#$PATH 변수 안에 파일이 없는 경우
		elif ! in_path $var "$PATH" ; then
			return 2
		fi
	fi
}


if [ $# -ne 1 ] ; then
	echo "Usage: $0 command" >&2
	exit 1
fi

checkForCmdInPath "$1"
case $? in
	0) echo "$1 found in PATH";;
	1) echo "$1 not found or not executable";;
	2) echo "$1 not found in PATH" ;;
esac

exit 0
