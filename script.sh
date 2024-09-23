# bash script.sh log backup 30 5

LOG_DIR=$1 # путь к папке
BACKUP_DIR=$2 # путь к папке бэкапов
THRESHOLD=${3:-30} # порог заполнения (30)
NUM_FILES=${4:-5} # количество архивируемых файлов

# проверочки
if [[ ! -d "$LOG_DIR" ]]; then
    echo "папка $LOG_DIR не найдена"
    exit 1
fi
if [[ ! -d "$BACKUP_DIR" ]]; then
    echo "папка $BACKUP_DIR не найдена"
    exit 1
fi
# 

current=$(df "$LOG_DIR" | tail -1 | awk '{print $5}' | sed 's/%//')

if ((current > THRESHOLD )); then
    echo "папка $LOG_DIR заполнена на $current%"

    files_to_archive=$(find "$LOG_DIR" -type f -exec stat -f "%m %N" {} \; | sort -n | head -n $NUM_FILES | cut -d' ' -f2-)
    
    if [[ -z "$files_to_archive" ]]; then
        echo "нет файлов для архивации"
        exit 0
    fi

    # архивчик
    archive_name="$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    echo "архивируем файлы в $archive_name"
    
    tar -czf "$archive_name" $files_to_archive
    
    if [[ $? -eq 0 ]]; then
        echo "$NUM_FILES файлов заархивированы"
        
        for file in $files_to_archive; do
            rm -f "$file"
        done
        echo "файлы из $LOG_DIR удалены"
    else
        echo "ошибка при создании архива"
        exit 1
    fi
else
    echo "заполнение папки $LOG_DIR не превышает $THRESHOLD% ($current%)"
fi