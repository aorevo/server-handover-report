#!/bin/bash

LOG_DIR="/srv/dostavka-eda/logs"
ARCHIVE_FILE="$LOG_DIR/archive/old-logs-$(date +%F).tar.gz"

tar -czf "$ARCHIVE_FILE" \
    --remove-files \
    -C "$LOG_DIR" \
    access.log.{1..7}
