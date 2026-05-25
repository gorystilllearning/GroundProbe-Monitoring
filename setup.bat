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

REM ══════════════════════════════════════════════════════════
REM   EMBEDDED LOGO (base64)
REM
REM   Untuk mengganti logo:
REM   1. Siapkan logo.png (PNG transparan, 220x60px disarankan)
REM   2. Encode: certutil -encode logo.png logo.b64
REM      lalu copy isi logo.b64 (tanpa baris BEGIN/END) ke LOGO_BASE64
REM   3. Paste ke variabel di bawah ini
set "LOGO_BASE64="
REM ══════════════════════════════════════════════════════════

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
echo   Target  : Zabbix 6.4 + Liquid Glass Theme + Company Branding
echo   Access  : http://localhost:8080
echo.

REM ── PRE-FLIGHT CHECKS ────────────────────────────────────
echo %BOLD%%BLUE%[1/5]%NC% Pre-flight checks
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
  echo   %RED%[X]%NC% Docker Compose not found ^(requires Docker Desktop v2+^)
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

REM CSS theme file
if exist "zabbix-liquid-glass.css" (
  echo   %GREEN%[OK]%NC% Theme CSS found
) else (
  echo   %YELLOW%[!]%NC%  zabbix-liquid-glass.css not found — theme will not be applied
)
echo.

REM ── START SERVICES ───────────────────────────────────────
echo %BOLD%%BLUE%[2/5]%NC% Starting Docker services
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
echo %BOLD%%BLUE%[3/5]%NC% Waiting for database initialization
echo.
echo|set /p="  ->  Please wait 60 seconds "
for /L %%i in (1,1,60) do (
  timeout /t 1 /nobreak > nul
  echo|set /p="."
)
echo   %GREEN%[OK]%NC% Database should be ready
echo.

REM ── APPLY THEME ──────────────────────────────────────────
echo %BOLD%%BLUE%[4/5]%NC% Applying Liquid Glass theme
echo.
if exist "zabbix-liquid-glass.css" (
  type zabbix-liquid-glass.css | docker exec -u root -i groundprobe-zabbix-web sh -c "cat >> /usr/share/zabbix/assets/styles/blue-theme.css"
  if %errorlevel% equ 0 (
    echo   %GREEN%[OK]%NC% Theme injected successfully
  ) else (
    echo   %RED%[X]%NC% Theme injection failed — retry manually after containers are healthy
  )
) else (
  echo   %YELLOW%[!]%NC%  Skipped — CSS file missing
)
echo.

REM ── APPLY LOGO ───────────────────────────────────────────
echo %BOLD%%BLUE%[5/5]%NC% Applying company branding ^(logo^)
echo.

set "LOGO_APPLIED=false"

REM Priority 1: embedded base64 logo
if not "!LOGO_BASE64!"=="" (
  echo -----BEGIN CERTIFICATE----- > "%TEMP%\logo.b64"
  echo !LOGO_BASE64! >> "%TEMP%\logo.b64"
  echo -----END CERTIFICATE----- >> "%TEMP%\logo.b64"
  certutil -decode "%TEMP%\logo.b64" "%TEMP%\company-logo.png" > nul 2>&1
  if !errorlevel! equ 0 (
    docker cp "%TEMP%\company-logo.png" groundprobe-zabbix-web:/usr/share/zabbix/assets/img/company-logo.png
    del "%TEMP%\logo.b64" "%TEMP%\company-logo.png" > nul 2>&1
    echo   %GREEN%[OK]%NC% Logo applied ^(embedded^)
    set "LOGO_APPLIED=true"
  ) else (
    echo   %YELLOW%[!]%NC%  Failed to decode embedded logo — check LOGO_BASE64 value
  )
)

REM Priority 2: logo.png file in repo folder
if "!LOGO_APPLIED!"=="false" if exist "logo.png" (
  docker cp logo.png groundprobe-zabbix-web:/usr/share/zabbix/assets/img/company-logo.png
  echo   %GREEN%[OK]%NC% Logo applied ^(from logo.png file^)
  set "LOGO_APPLIED=true"
)

if "!LOGO_APPLIED!"=="false" (
  echo   %YELLOW%[!]%NC%  No logo found — Zabbix default logo will be shown
  echo   %CYAN%→%NC%  To add later: docker cp logo.png groundprobe-zabbix-web:/usr/share/zabbix/assets/img/company-logo.png
)
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
