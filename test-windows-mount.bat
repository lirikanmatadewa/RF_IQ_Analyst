@echo off
REM Test script to verify Windows directory mounting in RF IQ Analyst container

echo === Testing Windows Directory Mounting ===
echo.

REM Check if Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Docker is not running. Please start Docker Desktop.
    pause
    exit /b 1
)

echo Testing Windows directory access in container...
echo.

REM Run a test container to check directory mounts
docker run --rm ^
    -v "C:\Users:/mnt/windows/Users" ^
    -v "C:\:/mnt/windows/C" ^
    -v "%USERPROFILE%\Documents:/mnt/windows/Documents" ^
    -v "%USERPROFILE%\Downloads:/mnt/windows/Downloads" ^
    -v "%USERPROFILE%\Desktop:/mnt/windows/Desktop" ^
    alpine:latest sh -c "
        echo 'Checking mounted Windows directories:'
        echo '=================================='
        echo 'Windows C: drive contents (first 10 items):'
        ls -la /mnt/windows/C/ 2>/dev/null | head -10
        echo ''
        echo 'Windows Users directory:'
        ls -la /mnt/windows/Users/ 2>/dev/null | head -5
        echo ''
        echo 'Your Documents directory:'
        ls -la /mnt/windows/Documents/ 2>/dev/null | head -5
        echo ''
        echo 'Your Downloads directory:'
        ls -la /mnt/windows/Downloads/ 2>/dev/null | head -5
        echo ''
        echo 'Your Desktop directory:'
        ls -la /mnt/windows/Desktop/ 2>/dev/null | head -5
        echo ''
        echo 'Directory mounting test completed!'
        echo 'If you see directory contents above, Windows mounting is working.'
    "

echo.
echo Test completed. If you see Windows directory contents above,
echo the RF IQ Analyst application will be able to access your Windows files.
echo.
echo To use the application with Windows file access, run:
echo   run-gui-windows.bat
echo or
echo   docker-compose up rf-iq-analyst
echo.
pause
