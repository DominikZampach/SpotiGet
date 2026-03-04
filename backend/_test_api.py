import requests
import time

BASE_URL = "http://127.0.0.1:5050/api"

def test_full_flow(spotify_url):
    # 1. POSLÁNÍ REQUESTU
    print(f"1. Posílám požadavek na: {spotify_url}")
    response = requests.post(f"{BASE_URL}/request", json={"url": spotify_url})
    
    if response.status_code != 202:
        print("Chyba při startu úkolu:", response.text)
        return

    task_id = response.json().get('task_id')
    print(f"Úkol přijat! ID: {task_id}")

    # 2. POLLING (Dotazování na stav)
    print("2. Sleduji stav stahování...")
    while True:
        status_res = requests.get(f"{BASE_URL}/status/{task_id}")
        data = status_res.json()
        
        state = data.get('state')
        info = data.get('info', {})

        if state == 'PROGRESS':
            print(f"--- Progres: {info.get('current')}/{info.get('total')} - {info.get('status')}")
        elif state == 'SUCCESS':
            print("\n3. HOTOVO!")
            print(f"Odkaz ke stažení: http://127.0.0.1:5050{info.get('zip_url')}")
            break
        elif state == 'FAILURE':
            print("\n!!! Úkol selhal:", info)
            break
        
        time.sleep(2) # Počkej 2 sekundy před dalším dotazem

if __name__ == "__main__":
    test_full_flow("https://open.spotify.com/album/1TP95xOGiWqdVOu4hGbuug?si=pLi4oVvrSF-68TRsISsZ0w")