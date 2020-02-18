#!/bin/bash

echo -n "Enter your Filename : "
read File

if [ -d $FILE];then
    echo "It is a Directory "
elif [ -f $FILE];then
    echo "It is a regular file"
else
    echo "Not Found"
    exit 33
fi
