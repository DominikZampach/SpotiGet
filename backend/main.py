import os
from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
from services.spotify_client import SpotifyClient
from dotenv import load_dotenv
from tasks import download_playlist_task #? Importujeme task
from celery.result import AsyncResult
from celery_app import celery

app = Flask(__name__)
CORS(app) #? Povolí požadavky z Flutter Webu

load_dotenv()

CLIENT_ID = os.getenv("CLIENT_ID")
CLIENT_SECRET = os.getenv("CLIENT_SECRET")

if not CLIENT_ID or not CLIENT_SECRET:
    raise ValueError("Chybí Spotify přihlašovací údaje v .env souboru!")

sp_client = SpotifyClient(CLIENT_ID, CLIENT_SECRET)

@app.route('/api/request', methods=['POST'])
def handle_request():
    '''
        Musí vždy dostat body s atributy url a want_numbered!
    '''
    data = request.json
    url = data.get('url')
    want_numbered = data.get('want_numbered')
    
    if not url:
        return jsonify({'error': 'No URL provided'}), 400
    
    task = download_playlist_task.delay(url, want_numbered)
    
    return jsonify({
        'status': 'Accepted',
        'task_id': task.id
    }), 202

@app.route('/api/status/<task_id>', methods=['GET'])
def get_status(task_id):
    """Endpoint pro Flutter, aby se mohl ptát na stav stahování"""
    task_result = AsyncResult(task_id, app=celery)
    
    info = task_result.info
    
    if isinstance(info, Exception):
        info = str(info)
    elif info is None:
        info = {}
    
    response = {
        'state': task_result.state,
        'info': info
    }
    
    return jsonify(response)

@app.route('/api/download/<filename>', methods=['GET'])
def download_file(filename):
    """Endpoint pro samotné stažení hotového ZIPu"""
    path = os.path.join('downloads', {filename})
    if os.path.exists(path):
        return send_file(path, as_attachment=True, download_name=filename)
    return jsonify({'error': 'File not found'}), 404

if __name__ == '__main__':
    app.run(debug=True, port=5050)