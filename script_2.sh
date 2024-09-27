# тот же скрипт, но сортировка ручками :)
# bash script_2.sh log backup 30 5

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

current=$(df "$LOG_DIR" | tail -1 | awk '{print $5}' | sed 's/%//')

if ((current > THRESHOLD)); then
    echo "папка $LOG_DIR заполнена на $current%"

    # files_to_archive=$(find "$LOG_DIR" -type f -exec stat -f "%m %N" {} \; | sort -n | head -n $NUM_FILES | cut -d' ' -f2-)
    files_to_archive=()
    while IFS= read -r file; do
        timestamp=$(stat -f "%m" "$file")
        files_to_archive+=("$timestamp:$file")
    done < <(find "$LOG_DIR" -type f)

    # сортировка вставками
    for ((i = 1; i < ${#files_to_archive[@]}; i++)); do
        key=${files_to_archive[i]}
        j=$((i - 1))

        # тут была проблемка с меткой времени на макоси) помогите
        key_timestamp=${key%%:*} 

        while ((j >= 0)); do
            current_timestamp=${files_to_archive[j]%%:*}

            if ((current_timestamp <= key_timestamp)); then
                break
            fi

            files_to_archive[j + 1]="${files_to_archive[j]}"
            j=$((j - 1))
        done
        files_to_archive[j + 1]="$key"
    done

    # первые NUM_FILES файлов
    files_to_archive=("${files_to_archive[@]:0:NUM_FILES}")
    
    if [[ ${#files_to_archive[@]} -eq 0 ]]; then
        echo "нет файлов для архивации"
        exit 0
    fi

    # список файлов для архивирования
    list_files=()
    for it in "${files_to_archive[@]}"; do
        list_files+=("${it#*:}") 
    done

    # архивчик
    archive_name="$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    echo "архивируем файлы в $archive_name"
    
    tar -czf "$archive_name" "${list_files[@]}"
    
    if [[ $? -eq 0 ]]; then
        echo "$NUM_FILES файлов заархивированы"
        
        for file in "${list_files[@]}"; do
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
