@echo off
REM Windows X11 GUI runner for RF IQ Analyst
REM Make sure your X server (VcXsrv, Xming, etc.) is running first!

echo Starting RF IQ Analyst with GUI support on Windows...
echo.

REM Check if Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Docker is not running. Please start Docker Desktop.
    pause
    exit /b 1
)

REM Check if X server is accessible
echo Checking X server connection...
REM Try to connect to display
docker run --rm --network host -e DISPLAY=host.docker.internal:0.0 alpine:latest sh -c "apk add --no-cache xauth && xauth list" >nul 2>&1
if %errorlevel% neq 0 (
    echo Warning: Cannot detect X server. Make sure your X server is running and configured properly.
    echo.
    echo X Server Setup Instructions:
    echo 1. Install VcXsrv from: https://sourceforge.net/projects/vcxsrv/
    echo 2. Start VcXsrv with these settings:
    echo    - Display number: 0
    echo    - Start no client: checked
    echo    - Disable access control: checked
    echo    - Additional parameters: -ac -multiwindow
    echo.
    set /p continue="Continue anyway? (y/n): "
    if /i not "%continue%"=="y" exit /b 1
)

echo.
echo Starting RF IQ Analyst container...
echo Note: ALSA audio warnings are expected in containerized environment
echo.

REM Run the container with GUI support
docker run -it --rm ^
    --network host ^
    -e DISPLAY=host.docker.internal:0.0 ^
    -e QT_X11_NO_MITSHM=1 ^
    -e LIBGL_ALWAYS_INDIRECT=1 ^
    -e XDG_RUNTIME_DIR=/tmp/runtime-analyst ^
    -v "%cd%\data:/home/analyst/data" ^
    -v "C:\Users:/mnt/windows/Users" ^
    -v "C:\:/mnt/windows/C" ^
    -v "%USERPROFILE%\Documents:/mnt/windows/Documents" ^
    -v "%USERPROFILE%\Downloads:/mnt/windows/Downloads" ^
    -v "%USERPROFILE%\Desktop:/mnt/windows/Desktop" ^
    rf-iq-analyst:latest

echo.
echo Application closed.
pause
