#!/bin/bash

#docron--

if [ $# -ne 1 ] ; then
    echo "Usage: $0 [daily|weekly|monthly]" >&2
    exit 1
fi

# 관리자만 실행 가능한 스크립트
if [ "$(id -u)" -ne 0 ] ; then
    echo "$0: Command must be run as 'root'" >&2
    exit 1
fi

job="$(awk "NF > 6 && /$1/ { for (i=7;i<=NF;i++) print \$i 0 $rootcron}"

if [ -z "$job" ]; then
    echo "$0: Error: no $1 job found in $rootcron" >&2
    exit 1
fi

SHELL=$(which sh)

eval $job

