@echo off
color 0B
echo ========================================================
echo       GroundProbe Monitoring - Setup Script
echo ========================================================
echo.

docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not installed or not running.
    echo Please install Docker Desktop and start it first.
    pause
    exit /b 1
)

echo [INFO] Docker is running.
echo.
echo Because the image is hosted privately, please enter your
echo GitHub Personal Access Token (PAT) to authenticate.
set /p GH_TOKEN="GitHub PAT: "

if "%GH_TOKEN%"=="" (
    echo [ERROR] Token cannot be empty!
    pause
    exit /b 1
)

echo.
echo [INFO] Logging into GitHub Container Registry...
echo %GH_TOKEN% | docker login ghcr.io -u gorystilllearning --password-stdin

if %errorlevel% neq 0 (
    echo [ERROR] Login failed. Please check your token.
    pause
    exit /b 1
)

echo.
echo [INFO] Starting GroundProbe Monitoring containers...
docker compose up -d

echo.
echo ========================================================
echo       Setup Complete!
echo ========================================================
echo You can now access the dashboard at:
echo ========================================================
echo 👉 http://localhost:8080
echo.
echo Default Credentials:
echo Username: Admin
echo Password: zabbix
echo ========================================================
echo.
pause
