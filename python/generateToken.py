import sys
import os
import spotipy
from spotipy.oauth2 import SpotifyOAuth
from dotenv import load_dotenv, set_key

def generate_token(auth_code):
    # Load environment variables from .env file
    load_dotenv()

    client_id = os.getenv("SPOTIPY_CLIENT_ID")
    client_secret = os.getenv("SPOTIPY_CLIENT_SECRET")
    redirect_uri = os.getenv("SPOTIPY_REDIRECT_URI")
    username = os.getenv("SPOTIPY_USERNAME")  # Load username from .env

    # Set up Spotify OAuth
    sp_oauth = SpotifyOAuth(client_id=client_id, client_secret=client_secret, redirect_uri=redirect_uri, scope="user-read-playback-state")

    # Exchange the authorization code for an access token and refresh token
    token_info = sp_oauth.get_access_token(auth_code)
    refresh_token = token_info['refresh_token']

    # Store the refresh token in the .env file
    env_file = ".env"
    set_key(env_file, "SPOTIPY_REFRESH_TOKEN", refresh_token)

    print(f"Refresh token generated and saved to .env file for user: {username}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        generate_token(sys.argv[1])
    else:
        print("Authorization code is missing.")
