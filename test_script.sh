# тестирование bash
# bash test_script.sh 
LOG_DIR="log"
BACKUP_DIR="backup"
# SCRIPT_NAME = "script.sh" 
# SCRIPT_NAME = "script_2.sh" 

mkdir -p $LOG_DIR
mkdir -p $BACKUP_DIR

# генерим файлы // 20 файлов по 50М занимают 36% //
generate_files() {
    echo "генерация файлов"
    for i in {1..20}; do
        dd if=/dev/zero of="$LOG_DIR/testfile_$i.log" bs=50M count=1
        # sleep 0.5 # можно менять параметр, добавлен чтобы норм работала сортировка по времени
        # touch "$LOG_DIR/testfile_$i.log"  
        # echo "создан файл testfile_$i.log" # проверочка
    done
}

# очистка
cleanup() {
    echo "очистка"
    rm -rf $LOG_DIR/*
    rm -rf $BACKUP_DIR/*
}

# папка не превышает порог
case_1() {
    echo "тест 1"
    cleanup
    generate_files
    bash script.sh $LOG_DIR $BACKUP_DIR 90 5
    echo "ожидается: заполнение папки log не превышает 90% "
    ls $BACKUP_DIR
}

# архивирование всех (20) файлов при превышении порога
case_2() {
    echo "тест 2"
    cleanup
    generate_files
    bash script.sh $LOG_DIR $BACKUP_DIR 30 20
    echo "ожидается: 20 файлов заархивированы"
    ls $BACKUP_DIR
}

# архивирование части файлов 
case_3() {
    echo "тест 3"
    cleanup
    generate_files
    bash script.sh $LOG_DIR $BACKUP_DIR 30 12
    echo "ожидается: 12 файлов заархивированы"
    ls $BACKUP_DIR
}

# пустая папка
case_4() {
    echo "тест 4"
    cleanup
    bash script.sh $LOG_DIR $BACKUP_DIR 30 5
    echo "ожидается: нет файлов для архивации"
    ls $BACKUP_DIR
}

run_tests() {
    case_1
    case_2
    case_3
    case_4
}

run_tests
# generate_files