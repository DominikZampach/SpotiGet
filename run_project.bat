@echo off
title SpotiGet Multi-Loader
set PROJECT_ROOT=%~dp0

:: Spustíme Windows Terminal s první záložkou (Redis)
:: Poté přidáme další záložky pomocí 'split-pane' nebo 'new-tab'

wt -w 0 nt --title "Redis" -d "%PROJECT_ROOT%backend\bin\Redis" cmd /k "redis-server.exe" ^
; nt --title "API" -d "%PROJECT_ROOT%backend" cmd /k "venv\Scripts\python.exe main.py" ^
; nt --title "Celery" -d "%PROJECT_ROOT%backend" cmd /k "venv\Scripts\python.exe -m celery -A tasks worker --loglevel=info --pool=solo" ^
; nt --title "Flutter" -d "%PROJECT_ROOT%frontend" cmd /k "flutter run -d chrome"

echo ---------------------------------------------------
echo Windows Terminal byl spusten se vsemi zalozkami.
echo ---------------------------------------------------
pause