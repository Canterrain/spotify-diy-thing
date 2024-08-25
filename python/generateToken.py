import os
import spotipy
from spotipy.oauth2 import SpotifyOAuth
from dotenv import load_dotenv, set_key

def generate_token():
    # Load environment variables from .env file
    load_dotenv()

    client_id = os.getenv("SPOTIPY_CLIENT_ID")
    client_secret = os.getenv("SPOTIPY_CLIENT_SECRET")
    redirect_uri = os.getenv("SPOTIPY_REDIRECT_URI")

    # Set up Spotify OAuth
    sp_oauth = SpotifyOAuth(client_id=client_id, client_secret=client_secret, redirect_uri=redirect_uri, scope="user-read-playback-state")

    # Get the authorization URL and ask the user to authenticate
    auth_url = sp_oauth.get_authorize_url()
    print(f"Please go to this URL and authorize access: {auth_url}")

    # Prompt user for the authorization code from Spotify
    response = input("Paste the authorization code here: ")

    # Exchange the authorization code for an access token and refresh token
    token_info = sp_oauth.get_access_token(response)
    refresh_token = token_info['refresh_token']

    # Store the refresh token in the .env file
    env_file = ".env"
    set_key(env_file, "SPOTIPY_REFRESH_TOKEN", refresh_token)

    print("Refresh token generated and saved to .env file")

if __name__ == "__main__":
    generate_token()
