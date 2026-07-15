#!/bin/bash

BACKUP_FILE="$HOME/backups/config-$(date +%F).tar.gz"
SOURCE_DIR="/srv/dostavka-eda"

sudo tar -czf "$BACKUP_FILE" \
    -C "$SOURCE_DIR" \
    config/