/*
  Příklady odkazů ze Spotify:
    Album: https://open.spotify.com/album/1Pi6O60mJM4AWNhjShvdvB?si=b85t0vrERa-40D7f46xiTw
    Veřejný playlist: https://open.spotify.com/playlist/6wmkXU3DOnipzbRgg3qFGh?si=b3f5dc5178414cc8
    Soukromý playlist: https://open.spotify.com/playlist/5dnFSUZi0fgsgVyNblb4KZ?si=056f81746fc4476f&pt=daa2663894096f2b6613a566e64d227b
*/

bool isSpotifyUrlValid(String url) {
  if ((url.contains("open.spotify.com/album/") ||
          url.contains("open.spotify.com/playlist/")) &&
      (url.contains("https://"))) {
    return true;
  } else {
    return false;
  }
}
