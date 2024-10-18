@REM script.bat C:\path\to\log C:\path\to\backup 30 5
@REM script.bat log backup 30 5
@echo off
setlocal

:: путь к папке 
set "LOG_DIR=%~1" 
:: путь к папке бэкапов
set "BACKUP_DIR=%~2" 
:: порог заполнения 
set "THRESHOLD=%~3" 
:: количество архивируемых файлов
set "NUM_FILES=%~4" 

if "%THRESHOLD%"=="" set "THRESHOLD=30"
if "%NUM_FILES%"=="" set "NUM_FILES=5"

:: проверочки
if not exist "%LOG_DIR%" (
    set "LOG_DIR=%cd%\%LOG_DIR%"
)
if not exist "%BACKUP_DIR%" (
    set "BACKUP_DIR=%cd%\%BACKUP_DIR%"
)
if not exist "%LOG_DIR%" (
    echo папка %LOG_DIR% не найдена
    exit /b 1
)
if not exist "%BACKUP_DIR%" (
    echo папка %BACKUP_DIR% не найдена
    exit /b 1
)

for /f "tokens=5" %%A in ('dir /-C "%LOG_DIR%" 2^>nul ^| find "байт свободно"') do set "FREE_SPACE=%%A"
for /f "tokens=3" %%B in ('dir /-C "%LOG_DIR%" 2^>nul ^| find "байт всего"') do set "TOTAL_SPACE=%%B"

:: удаляем лишние символы из чисел
set "FREE_SPACE=%FREE_SPACE:,=%"
set "TOTAL_SPACE=%TOTAL_SPACE:,=%"

set /a current=100 - (FREE_SPACE * 100 / TOTAL_SPACE)

if %current% gtr %THRESHOLD% (
    echo папка %LOG_DIR% заполнена на %current%%

    :: N самых старых файлов
    for /f "tokens=*" %%F in ('dir /b /a-d /o-d "%LOG_DIR%" ^| sort /R') do (
        set /a count+=1
        if !count! leq %NUM_FILES% (
            echo добавляем в архив: %%F
            move "%LOG_DIR%\%%F" "%BACKUP_DIR%"
        )
    )

    :: архивчик
    set "archive_name=%BACKUP_DIR%\backup_%date:~6,4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%.tar.gz"
    echo архивируем файлы в %archive_name%
    :: ДА, ТОЧКА ТУТ ОКАЗЫВАЕТСЯ НУЖНА, ПОМОГИТЕ
    tar -czf "%archive_name%" -C "%BACKUP_DIR%" .

    if %errorlevel% equ 0 (
        echo %NUM_FILES% файлов успешно заархивированы
    ) else (
        echo ошибка при создании архива
        exit /b 1
    )
) else (
    echo заполнение папки %LOG_DIR% не превышает порог %THRESHOLD%% (%current%%)
)

endlocal