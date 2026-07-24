#!/bin/bash

set -euo pipefail
usage=$(df -h / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')

disk_watch(){
    if [ "$usage" -gt 80 ]; then
        logger -p user.warning "Диск заполнен более чем 80%"
    fi
}

main() {
    disk_watch
}

main
