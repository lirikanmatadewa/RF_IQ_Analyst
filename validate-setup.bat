@echo off
REM Validation script for RF IQ Analyst Docker setup (Windows)

echo === RF IQ Analyst Docker Setup Validation ===
echo.

REM Check if Docker is installed and running
echo 1. Checking Docker installation...
docker --version >nul 2>&1
if %errorlevel% == 0 (
    echo    ✓ Docker is installed
    docker info >nul 2>&1
    if %errorlevel% == 0 (
        echo    ✓ Docker daemon is running
        for /f "tokens=*" %%a in ('docker --version') do echo    Docker version: %%a
    ) else (
        echo    ✗ Docker daemon is not running
        echo    Please start Docker Desktop
        exit /b 1
    )
) else (
    echo    ✗ Docker is not installed
    echo    Please install Docker Desktop from https://www.docker.com/products/docker-desktop
    exit /b 1
)

echo.

REM Check if Docker Compose is available
echo 2. Checking Docker Compose...
docker-compose --version >nul 2>&1
if %errorlevel% == 0 (
    echo    ✓ Docker Compose is available
    for /f "tokens=*" %%a in ('docker-compose --version') do echo    Docker Compose version: %%a
) else (
    docker compose version >nul 2>&1
    if %errorlevel% == 0 (
        echo    ✓ Docker Compose (plugin) is available
        for /f "tokens=*" %%a in ('docker compose version') do echo    Docker Compose version: %%a
    ) else (
        echo    ✗ Docker Compose is not available
        echo    Please install Docker Compose
    )
)

echo.

REM Check project files
echo 3. Checking project files...
set files=Dockerfile docker-compose.yml .dockerignore analyst\Analyst.pro libsdrkit\libsdrkit.pro qvrt_lib\qvrt_util\qvrt_util.pro

for %%f in (%files%) do (
    if exist "%%f" (
        echo    ✓ %%f exists
    ) else (
        echo    ✗ %%f is missing
    )
)

echo.

REM Check for source files
echo 4. Checking critical source files...
if exist "libsdrkit\*.cpp" (
    echo    ✓ libsdrkit source files found
) else (
    echo    ✗ libsdrkit source files missing
)

if exist "analyst\Analyst\*.cpp" (
    echo    ✓ Analyst source files found
) else (
    echo    ✗ Analyst source files missing
)

if exist "qvrt_lib\qvrt_util\*.cpp" (
    echo    ✓ qvrt_util source files found
) else (
    echo    ✗ qvrt_util source files missing
)

echo.

REM Estimate build requirements
echo 5. Build requirements estimate...
echo    Estimated build time: 15-30 minutes
echo    Estimated disk space needed: 3-4 GB during build
echo    Final image size: ~1 GB
echo    Recommended RAM: 4 GB or more

echo.
echo === Validation Complete ===
echo.
echo If all checks passed, you can build the container with:
echo    build-docker.bat                              (Windows)
echo    docker build -t rf-iq-analyst:latest .        (Manual)
echo.
echo For GUI support on Windows, install VcXsrv X Server
