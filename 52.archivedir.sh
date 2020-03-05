#!/bin/bash

#archivedir--지정된 디렉토리의 압축된 아카이브 생성

maxarchivedir=10
progname=$(basename $0)

if [ $# -eq 0 ]; then
    echo "Usage: $progname directory" >&2
    exit 1
fi

if [ ! -d $1 ] ; then
    echo "${progname}: can't find directory $1 to archive." >&2
    exit 1
fi

#
if [ "$(basename $1)" != "$1" -o "$1" = "."] ; then
    echo "${progname}: You must specify a subdirectory" >&2
    exit 1
fi

#현재 디렉토리에 쓰기 권한이 있는지 확인
if [ ! -w . ] ; then
    echo "${progname}: cannot write archive file to current directory." >&2
    exit 1
fi

#결과로 만들어진 아카이브의 크기가 위험 수준까지 커지는지 확인

dirsize="$(du -s $1 | awk '{print $1}')"

#아카이빙 폴더의 dir갯수 측정 후 경고 메세지 출력
if [ $dirsize -gt $maxarchivedir ] ; then
    /bin/echo -n "Warning: directory $1 is $dirsize blocks. Proceed? [y][n] "
    read answer
    answer="$(echo $answer | tr '[:upper:]' '[:lower:]' | cut -c1)"
    if [ "$answer" != "y" ] ; then
        echo "${progname}: archive of directory $1 canceled." >&2
        exit 0
    fi
fi

if tar -cvzf "$1.tar.gz" "$1" ; then
    echo "Directory $1 archived as $archivename"
else
    echo "Warning: tar encountered errors archiving $1"
fi

exit 0

