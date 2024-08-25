import os
from dotenv import load_dotenv, set_key
import spotipy
from spotipy.oauth2 import SpotifyOAuth

def generate_token():
    # Load environment variables from .env file
    load_dotenv()

    client_id = os.getenv("SPOTIPY_CLIENT_ID")
    client_secret = os.getenv("SPOTIPY_CLIENT_SECRET")
    refresh_token = os.getenv("SPOTIPY_REFRESH_TOKEN")

    # Authenticate and get access token
    sp_oauth = SpotifyOAuth(client_id=client_id, client_secret=client_secret, redirect_uri="http://localhost:8888/callback", scope="user-read-playback-state")
    token_info = sp_oauth.refresh_access_token(refresh_token)

    # Get the access token from the token info
    access_token = token_info['access_token']

    # Store the access token in the .env file
    env_file = ".env"
    set_key(env_file, "SPOTIFY_ACCESS_TOKEN", access_token)

    print("Access token generated and saved to .env file")

if __name__ == "__main__":
    generate_token()
