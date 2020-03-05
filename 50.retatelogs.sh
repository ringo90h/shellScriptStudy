#!/bin/bash
#rotatelogs-- /var/log에 있는 로그 파일들을 저장하기 위해 순환시키고 
#  크기를 조절한다. 
#  구성 파일은 logfilename = 기간 으로 되어 있는데, 기간의 단위는 '일'이다.
#  기간이 0으로 설정되면, 스크립트는 해당 로그 파일을 무시한다.

logdir="/var/log"
config="$logdir/rotatelogs.conf"
mv="/bin/mv"
default_duration=7
count=0

duration=$default_duration

#구성파일이 없으면 종료
if [ ! -f $config ]; then
    echo "$0: no config file found. Can't proceed." >&2
    exit 1
fi

#로그 디렉토리의 권한 확인 (실행,쓰기 권한이 있어야 파일 생성 가능)
if [ ! -w $logdir -o ! -x $logdir] ; then
    echo "$0: you don't have the appropriate permissions in $logdir" >&2
    exit 1
fi

#로그 디렉토리로 이동
cd $logdir

#로그 디렉토리 검색
# maxdepth:최대 디렉토리 깊이 1 // type:f(파일) // 사이즈 최대 0이상 // 이름에 숫자가 없는지 // .으로 시작하지 않는지 // conf로 끝나지 않는지 // 목록의 맨 앞 ./제거
for name in $(find . -maxdepth 1 -type f -size +0c ! -name '*[0-9]*' \
                ! -name '\.*' ! -name '*conf' -print | sed 's/^\.\///')
do

    count=$(( $count + 1 ))

    # 설정 파일에서 특정 로그 파일에 해당하는 항목을 찾는다.
    duration="$(grep "^${name}=" $config|cut -d= -f2)"

    if [ -z "$duration" ] ; then
        duration=$default_duration
    elif [ "$duration" = "0" ] ; then
        echo "Duration set to zero: skipping $name"
        continue
    fi

    #순환 파일 이름을 설정
    back1="${name}.1";
    back2="${name}.2";
    back3="${name}.3";
    back4="${name}.4";

    #백업파일이 존재하고 가장 최근 백업파일의 작성기간이 duration 이내일 경우
    if [ -f "$back1" ] ; then
        if [ -z "$(find \"$back1\" -mtime +$duration -print 2>/dev/null)" ]
        then
            /bin/echo -n "$name's most recent backup is more recent then $duration"
            echo "days: skipping" ; continue
        fi
    fi

    echo "Rotating log $name (using a $duration day schedule)"

    #가장 오래된 로그부터 순환
    # mv -f: 강제 덮어쓰기
    if [ -f "$back3" ] ; then
        echo "... $back3 -> $back4" ; $mv -f "$back3" "$back4"
    fi
    if [ -f "$back2" ] ; then
        echo "... $back2 -> $back3" ; $mv -f "$back2" "$back3"
    fi
    if [ -f "$back1" ] ; then
        echo "... $back1 -> $back2" ; $mv -f "$back1" "$back2"
    fi
    if [ -f "$name" ] ; then
        echo "... $name -> $back1" ; $mv -f "$name" "$back1"
    fi
    #로그파일 초기화
    touch "$name"
    chmod 0600 "$name"
done

if [ $count -eq 0 ] ; then
    echo "Nothing to do: no log files big enough or old enough to rotate"
fi

exit 0
