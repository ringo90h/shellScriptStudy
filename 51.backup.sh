#!/bin/bash

#backup--pax 명령 에러

compress="bzip2"
inclist="/tmp/backup.inclist.$(date +%d%m%y)"
output="/tmp/backup.$(date +%d%m%y).bz2"
tsfile="$HOME/.backup.timestamp"
btype="incremental"
noinc=0

#EXIT 이벤트가 호출될 때 inclist 모두 삭제
trap "/bin/rm -f $inclist" EXIT

usageQuit()
{
    cat << "EOF" >&2
Usage: $0 [-o output] [-i|-f] [-n]
    -o : 백업 위치
    -i : 점진적 백업
    -f : 전체 백업
    -n : 타임스탬프 보존
EOF
    exit 1
}

#o옵션만 필수옵션
while getopts "o:ifn" arg; do
    case "$opt" in
        o ) output="$OPTARG";       ;;
        i ) btype="incremental";    ;;
        f ) btype="full";           ;;
        n ) noinc=1;                ;;
        ? ) usageQuit               ;;
    esac
done

#옵션인자 제거
shift $(( $OPTIND - 1 ))

echo "Doing $btype backup, saving output to $output"

#date에서 월,일,시간,분을 가져온다.
timestamp="$(date + '%m%d%I%M')"

#점진적 백업일 경우
if [ "$btype" = "incremental" ]; then
    #timestamp파일이 존재하지 않으면 에러
    if [ ! -f $tsfile ]; then  
        echo "Error: can't do an incremental backup: no timestamp file" >&2
        exit 1
    fi
    #-depth:하위디렉토리부터 처리한다. -newer:$tsfile보다 최근에 작성된 파일만 검색한다.
    #pax -w 파일 write -x 압축 형식 지정
    #pax는 지정된 아카이브 형식을 사용하여 파일 피연산자가 포함된 아카이브를 표준 출력에 기록합니다
    find $HOME -depth -type f -newer $tsfile -user ${USER:-LOGNAME} | \
    pax -w -x tar | $compress > $output
    failure="$?"
#풀 백업일 경우
else
    find $HOME -depth -type f -user ${USER:-LOGNAME} | \
    pax -w -x tar | $compress > $output
    failure="$?"
fi

if [ "$noinc" = "0" -a "$failure" = "0" ]; then
    touch -t $timestamp $tsfile
fi

exit 0
