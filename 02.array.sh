#!/bin/bash

daemons=("httpd" "mysqld" "vsftpd")
echo ${daemons[1]}
echo ${daemons[@]}
echo ${#daemons[@]}

filelist=($(ls))
echo ${filelist[*]}