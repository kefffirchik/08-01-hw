#!/bin/bash

PORT=80
FILE=/var/www/html/index.html

# Проверка доступности порта

nc -z 127.0.0.1 $PORT
if [ $? -ne 0 ]; then
    exit 1
fi

# Проверка существования index.html

if [ ! -f $FILE ]; then
    exit 1
fi

exit 0
