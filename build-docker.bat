@echo off
REM Build script for RF IQ Analyst Docker container (Windows)

echo Building RF IQ Analyst Docker container...

REM Build the Docker image
docker build -t rf-iq-analyst:latest .

echo.
echo Build completed successfully!
echo.
echo To run the application:
echo 1. For GUI mode (requires X server like VcXsrv):
echo    docker-compose up rf-iq-analyst
echo.
echo 2. For headless/development mode:
echo    docker-compose up -d rf-iq-analyst-headless
echo    docker exec -it rf-iq-analyst-headless /bin/bash
echo.
echo 3. Direct run with volume mount:
echo    docker run -it --rm -v %cd%/data:/home/analyst/data rf-iq-analyst:latest
echo.
echo Note: For GUI applications on Windows, install VcXsrv and set DISPLAY=host.docker.internal:0.0
