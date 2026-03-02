@echo off
title Launcher Projektu - Maturita
set PROJECT_ROOT=%~dp0

:: 1. REDIS SERVER (Předpokládám cestu z rootu: backend/bin/Redis)
echo [1/4] Spoustim Redis...
start "Redis Server" cmd /c "cd /d "%PROJECT_ROOT%backend\bin\Redis" && redis-server.exe"

:: 2. BACKEND API
echo [2/4] Spoustim Backend API...
:: Zde vlezeme do backend a voláme venv, který je uvnitř
start "Backend: API" cmd /k "cd /d "%PROJECT_ROOT%backend" && venv\Scripts\python.exe main.py"

:: 3. CELERY WORKER
echo [3/4] Spoustim Celery...
start "Backend: Celery" cmd /k "cd /d "%PROJECT_ROOT%backend" && venv\Scripts\python.exe -m celery -A tasks worker --loglevel=info --pool=solo"

:: 4. FLUTTER FRONTEND
echo [4/4] Spoustim Flutter Web...
start "Flutter Frontend" cmd /k "cd /d "%PROJECT_ROOT%frontend" && flutter run -d chrome"

echo ==========================================
echo Vsechny procesy byly nastartovany.
echo ==========================================