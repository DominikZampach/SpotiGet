import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
from .song import Song

class SpotifyClient:
    def __init__(self, client_id, client_secret):
        auth_manager = SpotifyClientCredentials(client_id=client_id, client_secret=client_secret)
        self.sp = spotipy.Spotify(auth_manager=auth_manager)
    
    def get_info(self, url):
        """Zjistí typ URL a základní info (název, obrázek)"""
        if 'playlist' in url:
            data = self.sp.playlist(url, fields="name,images,id")
            return {'type': 'playlist', 'name': data['name'], 'id': data['id']}
        elif 'album' in url:
            data = self.sp.album(url)
            return {'type': 'album', 'name': data['name'], 'id': data['id']}
        elif 'track' in url:
            data = self.sp.track(url)
            return {'type': 'track', 'name': data['name'], 'id': data['id']}
        return None #? Když ani jedno = uživatel zadal invalidní adresu
    
    def get_tracks(self, url):
        """Získá seznam všech skladeb (včetně metadat)"""
        tracks = []
        info = self.get_info(url)
        
        if info['type'] == 'playlist':
            results = self.sp.playlist_items(url)
            tracks.extend(self._extract_tracks(results['items'], 'playlist'))
            #? Stránkování, pokud je v playlistu více než 100 skladeb
            while results['next']:
                results = self.sp.next(results)
                tracks.extend(self._extract_tracks(results['items'], 'playlist'))
                
        elif info['type'] == 'album':
            results = self.sp.album_tracks(url)
            tracks.extend(self._extract_tracks(results['items'], 'album', album_name=info['name'], album_cover=info['images'][0][url]))
            #? Stránkování, pokud je v albu více než 100 skladeb (dost nepravděpodobné, ale radši xd)
            while results['next']:
                results = self.sp.next(results)
                tracks.extend(self._extract_tracks(results['items'], 'album', album_name=info['name'], album_cover=info['images'][0][url]))
        
        elif info['type'] == 'track':
            track_data = self.sp.track(url)
            tracks.append(self._format_track(track_data, track_data['album']['images'][0]['url'], track_data['album']['name']))

        return tracks
    
    def _extract_tracks(self, items, type, album_name=None, album_cover=None):
        extracted = []
        for item in items:
            #? Playlisty mají track vnořený, alba ho mají přímo
            track_data = item['track'] if type == 'playlist' else item
            if track_data: #? Ošetření pro smazané skladby v playlistu
                current_cover = None
                if type == 'playlist':
                    #? V playlistu má každý track své album a své obrázky
                    images = track_data.get('album', {}).get('images', [])
                    if images:
                        current_cover = images[0]['url']
                else:
                    current_cover = album_cover
                extracted.append(self._format_track(track_data, current_cover, album_name))
        return extracted
    
    def _format_track(self, t, cover ,album_name=None):
        return Song(
            t['name'],
            t['artists'],
            cover,
            album_name if album_name else t.get('album', {}).get('name', 'Unknown')
        )
