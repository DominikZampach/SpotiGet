import os
import shutil
from celery_app import celery
from services.spotify_client import SpotifyClient
from services.youtube_service import YouTubeService
from services.download_service import DownloadService
from dotenv import load_dotenv
import re

load_dotenv()

#? Inicializujeme služby uvnitř workeru
sp = SpotifyClient(os.getenv("CLIENT_ID"), os.getenv("CLIENT_SECRET"))
yt = YouTubeService()
dl = DownloadService()

def simplify_filename(name):
    """Odstraní znaky, které v názvu souboru nesmí být (/, \, :, *, ?, ", <, >, |)"""
    return re.sub(r'[\\/*?:"<>|]', "", name)

@celery.task(bind=True)
def download_playlist_task(self, spotify_url):
    """Hlavní úkol pro stažení celého playlistu/alba"""
    
    self.update_state(state='PROGRESS', meta={'current': 0,
            'total': 1, 'status': 'Načítám Spotify...', 'song_photo': '',
            'album_playlist_name': ''})
    tracks = sp.get_tracks(spotify_url)
    total = len(tracks)
    
    #? Vytvoříme unikátní ID pro složku (použijeme task_id Celery)
    folder_id = self.request.id
    
    #? Získám informace jako je název alba/playlistu, ...
    albumPlaylistInfo = sp.get_info(spotify_url)
    
    for i, song in enumerate(tracks):
        #? Aktualizace stavu pro Flutter
        self.update_state(state='PROGRESS', meta={
            'current': i + 1,
            'total': total,
            'status': f'Downloading {song.name}...',
            'song_photo': f'{song.photo}',
            'album_playlist_name': f"{albumPlaylistInfo['name']}",
        })
        
        yt_url = yt.get_video_url(song.search_query)
        if yt_url:
            dl.download_song(yt_url, folder_id, song)

    #? Po stažení všech písní začínáme zipovat
    self.update_state(state='PROGRESS', meta={'current': total, 'total': total, 'status': 'Creating ZIP...', 'song_photo': "", 'album_playlist_name': ""})
    
    base_path = os.path.join('downloads', folder_id)
    
    clean_name = simplify_filename(albumPlaylistInfo['name'])
    zip_filename = f"{clean_name}.zip"
    zip_full_path = os.path.join('downloads', zip_filename)
    
    shutil.make_archive(os.path.join('downloads', clean_name), 'zip', base_path)
    
    #? Smažeme původní složku s písničkami, už máme ZIP
    shutil.rmtree(base_path)
    
    #? Naplánuje smazání za 300 sekund (5 minut)
    cleanup_files.apply_async(args=[zip_filename], countdown=300)
    
    return {'state': "COMPLETED", 'info': {'status': 'Completed', 'zip_url': f'/api/download/{zip_filename}', 'filename': zip_filename,}}

@celery.task
def cleanup_files(filename):
    """Smaže složku i ZIP soubor po uplynutí času"""
    base_path = os.path.join('downloads', filename)
    
    if os.path.exists(base_path):
        os.remove(base_path)
    print(f"Cleanup hotov pro: {filename}")