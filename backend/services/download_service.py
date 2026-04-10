import yt_dlp
import os

class DownloadService:
    def __init__(self, base_download_path='downloads'):
        self.base_download_path = base_download_path
        if not os.path.exists(self.base_download_path):
            os.makedirs(self.base_download_path)
        
    def download_song(self, youtube_url, folder_name, song, number=None):
        """
        Stáhne písničku z YouTube a uloží ji jako MP3 s metadaty.
        folder_name: název podsložky (ID playlistu/alba nebo UUID)
        song: instance třídy Song pro metadata
        number: číslo do názvu pokud je tak zadáno, pokud ne tak dostane None a nic se neudělá
        """
        download_dir = os.path.join(self.base_download_path, folder_name)
        
        # Dynamické určení cesty k ffmpeg uvnitř složky backend/bin
        # Použijeme absolutní cestu, aby yt-dlp neměl problém
        current_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.ffmpeg_path = os.path.join(current_dir, 'bin')
        
        if not os.path.exists(download_dir):
            os.makedirs(download_dir)
        
        if number is None:
            outtmpl = f'{download_dir}/{song.name}.%(ext)s'
        else:
            outtmpl = f'{download_dir}/{number}. {song.name}.%(ext)s'
        
        ydl_opts = {
            'format': 'bestaudio/best',
            'outtmpl': outtmpl,
            'ffmpeg_location': self.ffmpeg_path,
            'writethumbnail': True,
            'postprocessors': [
                {
                    'key': 'FFmpegExtractAudio',
                    'preferredcodec': 'mp3',
                    'preferredquality': '192',
                },
                {
                    'key': 'FFmpegMetadata',
                    'add_metadata': True,
                },
                {
                    'key': 'EmbedThumbnail',
                }
            ],
            'postprocessor_args': [
                '-metadata', f'title={song.name}',
                '-metadata', f'artist={song.artist}',
                '-metadata', f'album={song.album}',
            ],
            'quiet': True,
            'no_warnings': True,
        }
        
        try:
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                ydl.download([youtube_url])
            return True
        except Exception as e:
            print(f"Chyba při stahování {song.name}: {e}")
            return False