@echo off
REM Build script for creating RF IQ Analyst .deb package on Windows

echo === RF IQ Analyst .deb Package Builder ===
echo.

REM Check if Docker is available
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Docker is not installed or not running
    echo Please install Docker Desktop and make sure it's running
    pause
    exit /b 1
)

echo Building RF IQ Analyst .deb package...
echo.

REM Create dist directory if it doesn't exist
if not exist "dist" mkdir dist

REM Build the Docker image and extract the .deb package
echo Step 1: Building Docker image with .deb package...
docker build -f Dockerfile.deb -t rf-iq-analyst-deb-builder:latest .

if %errorlevel% neq 0 (
    echo Error: Docker build failed
    pause
    exit /b 1
)

echo.
echo Step 2: Extracting .deb package and artifacts...

REM Create a temporary container to extract files
for /f "tokens=*" %%i in ('docker create rf-iq-analyst-deb-builder:latest') do set CONTAINER_ID=%%i

REM Extract the dist directory contents
docker cp %CONTAINER_ID%:/dist/. ./dist/

REM Clean up the temporary container
docker rm %CONTAINER_ID% >nul

echo.
echo Step 3: Package build completed!
echo.
echo Generated files in .\dist\:
dir /b dist\

echo.
echo === Installation Instructions ===
echo.
echo To install the .deb package on Ubuntu/Debian:
echo   cd dist
echo   sudo ./install.sh
echo.
echo Or manually:
echo   cd dist
echo   sudo dpkg -i rf-iq-analyst-1.0.0.deb
echo   sudo apt-get install -f  # if dependencies are missing
echo.
echo To test the package:
echo   lintian dist/rf-iq-analyst-1.0.0.deb  # check package quality
echo.
echo Package build completed successfully!
echo.
pause
