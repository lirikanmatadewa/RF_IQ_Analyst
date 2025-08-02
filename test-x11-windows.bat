@echo off
REM Test X server connection for Windows

echo Testing X server connection...
echo.

REM Test with a simple X11 application
echo Running X11 connection test...
docker run --rm --network host -e DISPLAY=host.docker.internal:0.0 alpine:latest sh -c "apk add --no-cache xeyes && timeout 5 xeyes" 2>nul

if %errorlevel% == 0 (
    echo ✓ X server connection successful!
    echo Your X server is properly configured.
) else (
    echo ✗ X server connection failed.
    echo.
    echo Troubleshooting steps:
    echo 1. Make sure VcXsrv is running
    echo 2. Check VcXsrv settings:
    echo    - Display number: 0
    echo    - Disable access control: CHECKED
    echo 3. Try restarting VcXsrv
    echo 4. Check Windows Firewall settings
)

echo.
echo If the test was successful, you can run the RF IQ Analyst GUI with:
echo   docker-compose up rf-iq-analyst
echo   OR
echo   run-gui-windows.bat

pause
