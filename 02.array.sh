#!/bin/bash

daemons=("httpd" "mysqld" "vsftpd")
#배열 선언
echo ${daemons[1]}
#배열 출력
echo ${daemons[@]}
#배열 전체 출력
echo ${#daemons[@]}
#(#)<-배열의 갯수 출력

echo $(ls)
#명령어 실행 및 출력
filelist=($(ls))
#명령어 배열로 저장
echo ${filelist[*]}

echo $$
# $$ 프로세스 번호
echo $0
# $0 스크립트 이름
echo $1
# $1~$9 명령준 인수
echo $*
# 모든 명령줄 인수 리스트
echo $#
# 모든 인수의 개수