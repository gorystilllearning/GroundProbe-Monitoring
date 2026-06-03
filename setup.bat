@echo off
title GroundProbe Monitoring System - Installer v2.0
cls

echo +===========================================================+
echo ^|                                                           ^|
echo ^|       GroundProbe Monitoring System                       ^|
echo ^|       Automated Installer  v2.0                           ^|
echo ^|       PT GroundProbe Indonesia                            ^|
echo ^|                                                           ^|
echo +===========================================================+
echo.
echo Target  : Zabbix 6.4 + Liquid Glass Theme (Local Build)
echo Access  : http://localhost:8080
echo.

REM ── PRE-FLIGHT CHECKS ────────────────────────────────────
echo [1/3] Pre-flight checks
echo.

docker info > nul 2>&1
if %errorlevel% neq 0 (
  echo [X] Docker is not running
  echo --^> Please start Docker Desktop and re-run this installer.
  pause
  exit /b 1
)
echo [OK] Docker is running

docker compose version > nul 2>&1
if %errorlevel% neq 0 (
  echo [X] Docker Compose not found
  pause
  exit /b 1
)
echo [OK] Docker Compose available

if not exist "docker-compose.yml" (
  echo [X] docker-compose.yml not found
  echo --^> Run this script from the repo root folder
  pause
  exit /b 1
)
echo [OK] docker-compose.yml found
echo.

REM ── START SERVICES ───────────────────────────────────────
echo [2/3] Building image and starting Docker services
echo.
docker compose up -d --build
if %errorlevel% neq 0 (
  echo.
  echo [X] Failed to start services - check docker-compose.yml
  pause
  exit /b 1
)
echo.
echo [OK] All containers started

REM ── WAIT WITH COUNTDOWN ──────────────────────────────────
echo.
echo [3/3] Waiting for database initialization
echo.
echo^|set /p="--^> Please wait 30 seconds "
for /L %%i in (1,1,30) do (
  timeout /t 1 /nobreak > nul
  echo^|set /p="."
)
echo [OK] System is ready
echo.

REM ── DONE ─────────────────────────────────────────────────
echo +===========================================================+
echo ^|              Installation Complete!                       ^|
echo +===========================================================+
echo ^|  URL      :  http://localhost:8080                        ^|
echo ^|  Username :  Admin  (capital A)                           ^|
echo ^|  Password :  zabbix                                       ^|
echo ^|  Support  :  support@groundprobe.com                      ^|
echo +===========================================================+
echo.
pause
