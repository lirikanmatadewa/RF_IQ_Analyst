@echo off
REM Test audio functionality in RF IQ Analyst container

echo Testing Audio Configuration for RF IQ Analyst...
echo.

echo Checking Docker...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Docker is not running.
    pause
    exit /b 1
)

echo Checking for PulseAudio server...
netstat -an | findstr ":4713" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ PulseAudio server detected on port 4713
    set AUDIO_MODE=pulseaudio
) else (
    echo ⚠ PulseAudio server not detected
    set AUDIO_MODE=basic
)

echo.
echo Checking WSLg audio support...
if exist "\\wsl$\Ubuntu\mnt\wslg" (
    echo ✓ WSLg detected - advanced audio support available
    set WSLG_AVAILABLE=yes
) else (
    echo ⚠ WSLg not detected - basic audio mode only
    set WSLG_AVAILABLE=no
)

echo.
echo Testing container audio configuration...

if "%AUDIO_MODE%"=="pulseaudio" (
    echo Testing with PulseAudio support...
    docker run --rm --network host ^
        -e PULSE_SERVER=host.docker.internal:4713 ^
        -e XDG_RUNTIME_DIR=/tmp/runtime-analyst ^
        ubuntu:22.04 bash -c "apt-get update && apt-get install -y pulseaudio-utils && pulseaudio --check -v"
) else (
    echo Testing basic audio libraries...
    docker run --rm ubuntu:22.04 bash -c "apt-get update && apt-get install -y alsa-utils && aplay -l"
)

echo.
echo Audio Test Summary:
echo ==================
if "%AUDIO_MODE%"=="pulseaudio" (
    echo Audio Mode: PulseAudio Network
    echo Recommendation: Use run-gui-audio-windows.bat
) else (
    echo Audio Mode: Basic ALSA (warnings expected)
    echo Recommendation: Use run-gui-windows.bat (audio warnings are normal)
)

if "%WSLG_AVAILABLE%"=="yes" (
    echo WSLg Support: Available
    echo Advanced Option: docker-compose up rf-iq-analyst-wslg
)

echo.
echo Note: RF IQ Analyst works perfectly for signal processing without audio.
echo Audio warnings in the console can be safely ignored.
echo.
pause
