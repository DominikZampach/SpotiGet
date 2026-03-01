# Co je potřeba vždy zapnout?
## API (Backend)
(Vše ve složce /backend/)
    1. a 2. krok se musí dělat ve venv ('.\venv\Scripts\Activate.ps1')
1. 'python main.py'
2. 'python -m celery -A tasks worker --loglevel=info --pool=solo'
3. v bin/Redis zapnout redis-server.exe

## Flutter (Frontend)
1. Zapnout webovou aplikaci (ve složce /frontend/ command 'flutter run')