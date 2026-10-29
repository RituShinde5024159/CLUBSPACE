@echo off
title ClubSpace Local Server
cd /d "%~dp0"

echo ====================================================
echo   Starting ClubSpace Web Server at http://localhost:8080
echo ====================================================
echo.

set "NODE_CMD="

REM 1. Check if node is in PATH
where node >nul 2>nul
if %ERRORLEVEL% equ 0 (
    set "NODE_CMD=node"
) else (
    REM Check default 64-bit installation path
    if exist "C:\Program Files\nodejs\node.exe" (
        set "NODE_CMD=C:\Program Files\nodejs\node.exe"
    )
)

if defined NODE_CMD (
    echo [OK] Launching server using Node.js...
    start "" "http://localhost:8080"
    "%NODE_CMD%" server.js
    pause
    exit /b
)

REM 2. Check Python
where python >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo [OK] Launching server using Python...
    start "" "http://localhost:8080"
    python -m http.server 8080 -d build\web
    pause
    exit /b
)

if exist "C:\Python313\python.exe" (
    echo [OK] Launching server using Python (C:\Python313)...
    start "" "http://localhost:8080"
    "C:\Python313\python.exe" -m http.server 8080 -d build\web
    pause
    exit /b
)

REM 3. Fallback: Windows PowerShell server (no install needed)
echo [OK] Launching server using Windows PowerShell...
start "" "http://localhost:8080"
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0serve.ps1"
pause
