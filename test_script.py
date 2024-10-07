# тестирование pytest

import os
import subprocess
# import pytest 

LOG_DIR = "MyDisk/log"
BACKUP_DIR = "backup"

# @pytest.fixture(scope='module', autouse=True)
def setup_directories():
    os.makedirs(LOG_DIR, exist_ok=True)
    os.makedirs(BACKUP_DIR, exist_ok=True)
    yield
    cleanup()

def generate_files():
    print("генерация файлов")
    for i in range(1, 21):
        with open(f"{LOG_DIR}/testfile_{i}.log", "wb") as f:
            f.write(b'\0' * 30 * 1024 * 1024)  # 30MB

def cleanup():
    print("очистка")
    for dir in [LOG_DIR, BACKUP_DIR]:
        for file in os.listdir(dir):
            os.remove(os.path.join(dir, file))

def test_case_1():
    print("тест 1")
    cleanup()
    generate_files()
    subprocess.run(["bash", "script.sh", LOG_DIR, BACKUP_DIR, "90", "5"], check=True)
    assert len(os.listdir(BACKUP_DIR)) == 0  # проверка - нет файлов в BACKUP_DIR

def test_case_2():
    print("тест 2")
    cleanup()
    generate_files()
    subprocess.run(["bash", "script.sh", LOG_DIR, BACKUP_DIR, "30", "20"], check=True)
    assert (len(os.listdir(BACKUP_DIR)) == 1)and(len(os.listdir(LOG_DIR)) == 0)  # проверка - архив в BACKUP_DIR и пусто в LOG_DIR

def test_case_3():
    print("тест 3")
    cleanup()
    generate_files()
    subprocess.run(["bash", "script.sh", LOG_DIR, BACKUP_DIR, "30", "12"], check=True)
    assert (len(os.listdir(BACKUP_DIR)) == 1) and (len(os.listdir(LOG_DIR)) == 8)   # проверка - архив в BACKUP_DIR и осталось 8 в LOG_DIR

def test_case_4():
    print("тест 4")
    cleanup()
    subprocess.run(["bash", "script.sh", LOG_DIR, BACKUP_DIR, "30", "5"], check=True)
    assert len(os.listdir(BACKUP_DIR)) == 0  # проверка - нет файлов в BACKUP_DIR 
