@REM создание ограниченной папки через виртуальный диск
@REM make_folder.bat
@echo off
setlocal

set "IMAGE_SIZE=1024"
set "IMAGE_NAME=disk_image.vhd"
set "WORKING_DIR=%cd%"

set "IMAGE_PATH=%WORKING_DIR%\%IMAGE_NAME%"
set "VOLUME_NAME=MyDisk"
set "MOUNT_POINT=%WORKING_DIR%\%VOLUME_NAME%"

:: виртуальный диск %IMAGE_NAME% размером %IMAGE_SIZE% в директории %WORKING_DIR%
@REM diskpart /s "%temp%\create_vhd_script.txt" >nul 2>&1

:: текстовый файл с командой для diskpart
set "diskpart_script=%temp%\create_vhd_script.txt"
(
    echo create vdisk file="%IMAGE_PATH%" maximum=%IMAGE_SIZE%
    echo attach vdisk
    echo create partition primary
    echo format fs=ntfs label=%VOLUME_NAME% quick
    echo assign letter=%VOLUME_NAME%
) > "%diskpart_script%"


:: диск
diskpart /s "%diskpart_script%" >nul 2>&1

:: проверочка
if errorlevel 1 (
    echo ошибка при создании виртуального диска
    exit /b 1
)

mkdir "%MOUNT_POINT%\log"

:: очистка временного скрипта
del "%diskpart_script%"

endlocal