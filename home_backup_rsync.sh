#!/bin/bash

SRC="$HOME/"
DST="/tmp/backup/"
TAG="home-backup"

mkdir -p "$DST"

rsync -a --delete --delete-excluded --checksum \
  --exclude='/.*/' --exclude='*/.*/' \
  "$SRC" "$DST"

# Сохраняем код завершения rsync
CODE=$?

if [ $CODE -eq 0 ]; then
  logger -t "$TAG" "Backup SUCCESS: $SRC -> $DST"
else
  logger -t "$TAG" "Backup FAIL (code=$CODE): $SRC -> $DST"
fi

exit $CODE
