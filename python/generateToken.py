import sys
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

    # Define the scope for the permissions needed
    scope = 'user-read-currently-playing,user-modify-playback-state,playlist-read-private,playlist-read-collaborative'

    # Set up Spotify OAuth with the defined scope and headless flow
    sp_oauth = SpotifyOAuth(client_id=client_id, client_secret=client_secret, redirect_uri=redirect_uri, scope=scope, open_browser=False)

    # Print the authorization URL to the terminal
    auth_url = sp_oauth.get_authorize_url()
    print(f"Please visit this URL to authorize access: {auth_url}")

    # Prompt the user for the authorization code from Spotify
    auth_code = input("Enter the authorization code here: ")

    # Exchange the authorization code for an access token and refresh token
    token_info = sp_oauth.get_access_token(auth_code)
    refresh_token = token_info['refresh_token']

    # Store the refresh token in the .env file
    env_file = ".env"
    set_key(env_file, "SPOTIPY_REFRESH_TOKEN", refresh_token)

    print("Refresh token generated and saved to .env file")

if __name__ == "__main__":
    generate_token()
