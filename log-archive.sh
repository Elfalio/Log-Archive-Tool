#!/bin/bash

# =================================================================
# Название: log-archive.sh
# Описание: Утилита для архивации старых логов.
# Использование: ./log-archive.sh <директория_логов>
# =================================================================

# --- Переменные ---
LOG_DIR=$1
# Путь, где будут лежать архивы (создаем рядом со скриптом)
BASE_DIR=$(dirname "$(realpath "$0")")
ARCHIVE_DEST="$BASE_DIR/archived_logs"
INVENTORY_FILE="$BASE_DIR/archive_inventory.log"

# --- Проверки ---
# Проверка: передан ли аргумент
if [ -z "$LOG_DIR" ]; then
    echo "Ошибка: Не указана директория для архивации."
    echo "Пример: $0 /var/log/atlassian"
    exit 1
fi

# Проверка: существует ли папка
if [ ! -d "$LOG_DIR" ]; then
    echo "Ошибка: Директория '$LOG_DIR' не найдена."
    exit 1
fi

# --- Подготовка ---
mkdir -p "$ARCHIVE_DEST"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
# Берем только имя папки из пути для названия файла
DIR_NAME=$(basename "$LOG_DIR")
ARCHIVE_NAME="logs_${DIR_NAME}_${TIMESTAMP}.tar.gz"

# --- Процесс архивации ---
echo "--- Запуск архивации: $(date) ---"

# Создаем архив. 
# Мы используем -C, чтобы в архиве не было полных путей от корня системы
tar -czf "$ARCHIVE_DEST/$ARCHIVE_NAME" -C "$(dirname "$LOG_DIR")" "$DIR_NAME" 2>/dev/null

if [ $? -eq 0 ]; then
    # Считаем размер архива для лога
    SIZE=$(du -sh "$ARCHIVE_DEST/$ARCHIVE_NAME" | awk '{print $1}')
    
    # Записываем в файл инвентаризации
    echo "[$TIMESTAMP] Создан: $ARCHIVE_NAME | Размер: $SIZE | Источник: $LOG_DIR" >> "$INVENTORY_FILE"
    
    echo "Успех! Архив: $ARCHIVE_DEST/$ARCHIVE_NAME"
    echo "Размер: $SIZE"
else
    echo "Критическая ошибка при создании архива."
    exit 1
fi
