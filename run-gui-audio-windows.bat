@echo off
REM Windows X11 + Audio GUI runner for RF IQ Analyst
REM Make sure your X server (VcXsrv) and PulseAudio server are running first!

echo Starting RF IQ Analyst with GUI and Audio support on Windows...
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

REM Check for PulseAudio on Windows (optional)
echo Checking for PulseAudio server...
netstat -an | findstr ":4713" >nul 2>&1
if %errorlevel% neq 0 (
    echo Warning: PulseAudio server not detected on port 4713.
    echo.
    echo Audio Setup Instructions ^(Optional^):
    echo 1. Install PulseAudio for Windows from: https://www.freedesktop.org/wiki/Software/PulseAudio/Ports/Windows/Support/
    echo 2. Configure PulseAudio to accept network connections
    echo 3. Or use WSL2 with PulseAudio for better audio support
    echo.
    echo Note: Application will run without audio if not configured.
    echo.
)

echo.
echo Starting RF IQ Analyst container with audio support...
echo.

REM Run the container with GUI support (simplified audio setup)
docker run -it --rm ^
    --network host ^
    -e DISPLAY=host.docker.internal:0.0 ^
    -e QT_X11_NO_MITSHM=1 ^
    -e LIBGL_ALWAYS_INDIRECT=1 ^
    -e XDG_RUNTIME_DIR=/tmp/runtime-analyst ^
    -e PULSE_SERVER=host.docker.internal:4713 ^
    -v "%cd%\data:/home/analyst/data" ^
    rf-iq-analyst:latest

REM Check if the command succeeded
if %errorlevel% neq 0 (
    echo.
    echo Audio setup failed, trying basic GUI-only mode...
    docker run -it --rm ^
        --network host ^
        -e DISPLAY=host.docker.internal:0.0 ^
        -e QT_X11_NO_MITSHM=1 ^
        -e LIBGL_ALWAYS_INDIRECT=1 ^
        -e XDG_RUNTIME_DIR=/tmp/runtime-analyst ^
        -v "%cd%\data:/home/analyst/data" ^
        rf-iq-analyst:latest
)

echo.
echo Application closed.
pause
