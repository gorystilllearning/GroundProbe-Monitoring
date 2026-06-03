@echo off
setlocal EnableDelayedExpansion
title GroundProbe Monitoring System — Installer v2.0

REM ── Enable ANSI colors (Windows 10+) ──────────────────────
reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f > nul 2>&1

REM ── ANSI Color codes ──────────────────────────────────────
set "GREEN="
set "RED="
set "YELLOW="
set "CYAN="
set "BLUE="
set "BOLD="
set "NC="

cls
echo %BOLD%%BLUE%
echo   +===========================================================+
echo   ^|                                                           ^|
echo   ^|       GroundProbe Monitoring System                       ^|
echo   ^|       Automated Installer  v2.0                           ^|
echo   ^|       PT GroundProbe Indonesia                            ^|
echo   ^|                                                           ^|
echo   +===========================================================+
echo %NC%
echo   Target  : Zabbix 6.4 + Liquid Glass Theme (ghcr.io Image)
echo   Access  : http://localhost:8080
echo.

REM ── PRE-FLIGHT CHECKS ────────────────────────────────────
echo %BOLD%%BLUE%[1/4]%NC% Pre-flight checks
echo.

REM Docker daemon
docker info > nul 2>&1
if %errorlevel% neq 0 (
  echo   %RED%[X]%NC% Docker is not running
  echo.
  echo   %YELLOW%→ Please start Docker Desktop and re-run this installer.%NC%
  pause
  exit /b 1
)
echo   %GREEN%[OK]%NC% Docker is running

REM Docker Compose
docker compose version > nul 2>&1
if %errorlevel% neq 0 (
  echo   %RED%[X]%NC% Docker Compose not found
  pause
  exit /b 1
)
echo   %GREEN%[OK]%NC% Docker Compose available

REM docker-compose.yml
if not exist "docker-compose.yml" (
  echo   %RED%[X]%NC% docker-compose.yml not found
  echo   %YELLOW%→ Run this script from the repo root folder%NC%
  pause
  exit /b 1
)
echo   %GREEN%[OK]%NC% docker-compose.yml found
echo.

REM ── START SERVICES ───────────────────────────────────────
echo %BOLD%%BLUE%[2/3]%NC% Starting Docker services
echo.
docker compose up -d
if %errorlevel% neq 0 (
  echo.
  echo   %RED%[X]%NC% Failed to start services — check docker-compose.yml
  pause
  exit /b 1
)
echo.
echo   %GREEN%[OK]%NC% All containers started

REM ── WAIT WITH COUNTDOWN ──────────────────────────────────
echo.
echo %BOLD%%BLUE%[3/3]%NC% Waiting for database initialization
echo.
echo|set /p="  ->  Please wait 30 seconds "
for /L %%i in (1,1,30) do (
  timeout /t 1 /nobreak > nul
  echo|set /p="."
)
echo   %GREEN%[OK]%NC% System is ready
echo.

REM ── DONE ─────────────────────────────────────────────────
echo %BOLD%%GREEN%
echo   +===========================================================+
echo   ^|              Installation Complete!                       ^|
echo   +===========================================================+
echo   ^|  URL      :  http://localhost:8080                        ^|
echo   ^|  Username :  Admin  ^(capital A^)                           ^|
echo   ^|  Password :  zabbix                                       ^|
echo   ^|  Support  :  support@groundprobe.com                      ^|
echo   +===========================================================+
echo %NC%
pause
