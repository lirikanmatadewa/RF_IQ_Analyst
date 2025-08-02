@echo off
REM Quick start script for RF IQ Analyst with Windows X server

echo === RF IQ Analyst - Windows GUI Quick Start ===
echo.
echo Current build status: Check terminal for Docker build progress
echo.

REM Method 1: Using docker-compose (recommended)
echo Method 1: Using docker-compose (recommended)
echo   docker-compose up rf-iq-analyst
echo.

REM Method 2: Direct docker run
echo Method 2: Direct docker run
echo   docker run -it --rm --network host -e DISPLAY=host.docker.internal:0.0 -e QT_X11_NO_MITSHM=1 -e LIBGL_ALWAYS_INDIRECT=1 -v "%cd%\data:/home/analyst/data" rf-iq-analyst:latest
echo.

REM Method 3: Using the GUI runner script
echo Method 3: Using the GUI runner script
echo   run-gui-windows.bat
echo.

REM Method 4: Test X11 connection first
echo Method 4: Test X11 connection first
echo   test-x11-windows.bat
echo.

echo Choose your preferred method and make sure your X server is running!
echo.
echo X Server Quick Setup (VcXsrv):
echo 1. Download VcXsrv: https://sourceforge.net/projects/vcxsrv/
echo 2. Install and start XLaunch with settings:
echo    - Multiple windows mode
echo    - Display number: 0  
echo    - Start no client: CHECKED
echo    - Disable access control: CHECKED (IMPORTANT!)
echo    - Additional parameters: -ac -multiwindow
echo 3. Allow VcXsrv through Windows Firewall if prompted
echo.
echo Troubleshooting:
echo - If GUI doesn't appear, run test-x11-windows.bat first
echo - Make sure no other X servers are running
echo - Try restarting VcXsrv and rebuild if needed
echo.
pause
