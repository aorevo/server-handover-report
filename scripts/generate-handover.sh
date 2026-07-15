#!/bin/bash

LOG_FILE="/srv/dostavka-eda/logs/access.log"
REPORT="$HOME/handover.md"

RESULT=$(
    awk '$9 == 500 {print $1}' "$LOG_FILE" \
        | sort \
        | uniq -c \
        | sort -nr \
        | head -1
)

read -r N X <<< "$RESULT"

Y=$(
    awk -v ip="$X" '$9 == 500 && $1 == ip {print $7}' "$LOG_FILE" \
        | sort \
        | uniq -c \
        | sort -nr \
        | head -1 \
        | awk '{print $2}'
)

{
    echo "# Отчёт"
    echo
    echo "**Хост:** \`$(hostname)\`"
    echo
    echo "**Дата:** \`$(date +%F)\`"
    echo
    echo "**Всего запросов:** $(wc -l < "$LOG_FILE")"
    echo
    echo "## Топ URL по ошибкам 500"
    echo

    awk '$9 == 500 {print $7}' "$LOG_FILE" \
        | sort \
        | uniq -c \
        | sort -nr \
        | head -5 \
        | awk '{printf "- `%s` — %s запросов\n", $2, $1}'

    echo
    echo "## Топ-3 IP по запросам"
    echo

    awk '{print $1}' "$LOG_FILE" \
        | sort \
        | uniq -c \
        | sort -nr \
        | head -3 \
        | awk '{printf "- `%s` — %s запросов\n", $2, $1}'

    echo
    echo "## TL;DR"
    echo
    echo "Атака с IP $X: $N запросов, в основном 500 на URL $Y."
} > "$REPORT"