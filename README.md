# Server Handover Report

Учебный Linux-проект, который постепенно объединяет несколько миссий буткемпа:

- развёртывание приложения `DostavkaEda`;
- работа с конфигурацией, логами и отчётом для передачи смены;
- базовая подготовка, защита и мониторинг сервера.

Репозиторий будет дополняться следующими работами по мере прохождения буткемпа.

## Что выполнено

На сервере был создан отдельный пользователь `appuser`, подготовлена структура каталогов приложения и развёрнут релиз `v1.0`.

Приложение запускается через `systemd` от пользователя `appuser`. Активная версия определяется символьной ссылкой `current`.

Также были подготовлены:

- права доступа к конфигурационным файлам;
- swap-файл;
- резервное копирование конфигурации;
- архивация старых логов;
- анализ access-лога;
- отчёт о деплое;
- отчёт для передачи смены;
- пользователь `deploy` и базовый hardening сервера;
- мониторинг заполненности диска;
- общий crontab для выполненных скриптов.

## Структура репозитория

```text
server-handover-report/
├── configs/
│   ├── deploy-sudoers
│   └── jail.local
├── cron/
│   └── ops-jobs
├── scripts/
│   ├── archive-logs.sh
│   ├── backup-config.sh
│   ├── disk_watch.sh
│   └── generate-handover.sh
├── systemd/
│   └── dostavka.service
├── deploy-report-example.md
├── handover-example.md
├── server_setup.md
└── README.md
```

## Структура приложения

```text
/srv/dostavka-eda/
├── config/
├── current -> releases/v1.0/
├── logs/
└── releases/
    └── v1.0/
        ├── config/
        │   ├── app.yaml
        │   └── db.yaml
        ├── README.md
        ├── server.sh
        └── static/
            └── index.html
```

## Systemd-сервис

Unit-файл:

```text
/etc/systemd/system/dostavka.service
```

Содержимое unit-файла находится в репозитории:

```text
systemd/dostavka.service
```

Сервис запускает:

```text
/srv/dostavka-eda/current/server.sh
```

Пользователь сервиса:

```text
appuser
```

После запуска сервис имеет состояние:

```text
active
enabled
```

## Отчёт о деплое

Во время развёртывания был создан файл `~/deploy-report.md`.

Пример отчёта находится в файле:

```text
deploy-report-example.md
```

Отчёт содержит:

- имя сервера;
- дату деплоя;
- версию релиза;
- путь к релизу;
- размер релиза;
- состояние сервиса.

## Работа с конфигурацией и логами

В директории `scripts/` находятся Bash-скрипты:

```text
scripts/
├── archive-logs.sh
├── backup-config.sh
├── disk_watch.sh
└── generate-handover.sh
```

### backup-config.sh

Создаёт архив конфигурации приложения:

```text
~/backups/config-YYYY-MM-DD.tar.gz
```

### archive-logs.sh

Архивирует ротированные файлы:

```text
access.log.1 ... access.log.7
```

Архив сохраняется в:

```text
/srv/dostavka-eda/logs/archive/
```

### generate-handover.sh

Анализирует `access.log` и создаёт отчёт:

```text
~/handover.md
```

В отчёт входят:

- имя хоста;
- дата;
- количество запросов;
- пять URL с ошибками `500`;
- три самых активных IP;
- краткий итог.

Пример результата находится в файле:

```text
handover-example.md
```

### disk_watch.sh

Проверяет заполненность корневого раздела `/` и пишет warning в системный лог, если занято больше 80%.

## Автоматический запуск

Общий вариант crontab находится в файле:

```text
cron/ops-jobs
```

Для него скрипты размещаются в `/opt/ops/`.

Настроены следующие запуски:

- `disk_watch.sh` — каждые пять минут;
- `backup-config.sh` — каждый день в 02:00;
- `archive-logs.sh` — каждое воскресенье в 03:00;
- `generate-handover.sh` — каждый день в 08:00.

## Подготовка сервера

Создан пользователь `deploy`, настроены вход по SSH-ключу, `sudo` без пароля, UFW, `chrony`, swap, Fail2ban и мониторинг диска.

Итоговый отчёт:

```text
server_setup.md
```

Конфигурационные файлы:

```text
configs/deploy-sudoers
configs/jail.local
```
