@echo off
title GroundProbe Monitoring System Setup

echo.
echo ==========================================================
echo        GroundProbe Monitoring System Setup
echo        Windows Version
echo        PT GroundProbe Indonesia
echo ==========================================================
echo.

REM Check Docker is running
docker info > nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not running.
    echo         Please start Docker Desktop and try again.
    pause
    exit /b 1
)
echo [OK] Docker is running
echo.

REM Start all containers smartly
echo [INFO] Starting all services...
docker compose up -d

if %errorlevel% neq 0 (
    echo [ERROR] Failed to start services.
    pause
    exit /b 1
)

echo.
echo [INFO] Waiting for database schema initialization (60 seconds)...
timeout /t 60 /nobreak

REM Inject Liquid Glass CSS
echo.
echo [INFO] Applying GroundProbe Liquid Glass theme...

if exist "zabbix-liquid-glass.css" (
    type zabbix-liquid-glass.css | docker exec -u root -i groundprobe-zabbix-web sh -c "cat >> /usr/share/zabbix/assets/styles/blue-theme.css"
    echo [OK] Theme applied successfully
) else (
    echo [WARNING] CSS file not found - theme not applied
)

echo.
echo ==========================================================
echo                   Setup Complete!
echo.
echo   Open your browser and go to:
echo   http://localhost:8080
echo.
echo   Default Login:
echo   Username : Admin
echo   Password : zabbix
echo.
echo   Support  : support@groundprobe.com
echo ==========================================================
echo.
pause