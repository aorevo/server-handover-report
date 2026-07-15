# Анализ access-логов и резервное копирование

Небольшой Linux-проект, который имитирует задачу дежурного DevOps-инженера:

* резервное копирование конфигурации приложения;
* архивация ротированных логов;
* анализ HTTP-запросов;
* создание отчёта для передачи смены.

## Используемые инструменты

`tar`, `awk`, `sort`, `uniq`, `head`, `wc`, Bash-переменные и конвейеры.

## Исходные данные

```text
/srv/dostavka-eda/config/
/srv/dostavka-eda/logs/access.log
/srv/dostavka-eda/logs/access.log.1 ... access.log.7
```

В access-логе:

* `$1` — IP-адрес;
* `$7` — URL;
* `$9` — HTTP-код ответа.

## Резервное копирование конфигурации

Скрипт `backup-config.sh` создаёт gzip-архив директории `config` с текущей датой:

```bash
sudo tar -czf "$HOME/backups/config-$(date +%F).tar.gz" \
    -C /srv/dostavka-eda \
    config/
```

Результат:

```text
~/backups/config-YYYY-MM-DD.tar.gz
```

## Архивация старых логов

Скрипт `archive-logs.sh` архивирует файлы `access.log.1`–`access.log.7` и удаляет оригиналы после успешной архивации:

```bash
sudo tar -czf \
    "/srv/dostavka-eda/logs/archive/old-logs-$(date +%F).tar.gz" \
    --remove-files \
    -C /srv/dostavka-eda/logs \
    access.log.{1..7}
```

Текущий файл `access.log` не затрагивается.

## Анализ access-лога

Скрипт `generate-handover.sh` формирует файл `~/handover.md`, который содержит:

* имя хоста и дату;
* общее количество запросов;
* пять URL с наибольшим количеством ошибок `500`;
* три самых активных IP-адреса;
* краткий итог в разделе `TL;DR`.

Пример поиска URL с ошибками `500`:

```bash
awk '$9 == 500 {print $7}' "$LOG_FILE" \
    | sort \
    | uniq -c \
    | sort -nr \
    | head -5
```

Пример поиска самых активных IP:

```bash
awk '{print $1}' "$LOG_FILE" \
    | sort \
    | uniq -c \
    | sort -nr \
    | head -3
```

## Пример отчёта

```markdown
# Отчёт

**Хост:** `lab`

**Дата:** `2026-07-15`

**Всего запросов:** 830

## Топ URL по ошибкам 500

- `/api/checkout` — 308 запросов
- `/api/payment` — 21 запрос
- `/api/profile` — 12 запросов
- `/api/cart/add` — 10 запросов
- `/api/orders` — 9 запросов

## Топ-3 IP по запросам

- `185.220.101.1` — 308 запросов
- `45.33.32.156` — 153 запроса
- `203.0.113.5` — 72 запроса

## TL;DR

Атака с IP 185.220.101.1: 308 запросов, в основном 500 на URL /api/checkout.
```

Полный пример находится в файле `handover-example.md`.