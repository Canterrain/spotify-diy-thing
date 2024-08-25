#!/bin/bash

# Function to prompt the user for input
prompt_for_input() {
  read -p "$1 [$2]: " input
  echo "${input:-$2}"
}

# Function to extract the authorization code from the URL
extract_code_from_url() {
  local url="$1"
  echo "${url##*code=}"
}

# Install necessary packages
echo "Installing necessary packages..."
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv git npm

# Install pnpm
echo "Installing pnpm..."
sudo npm install -g pnpm

# Clone the repository
echo "Cloning the repository..."
git clone https://github.com/Canterrain/spotify-diy-thing.git
cd spotify-diy-thing || exit

# Create and activate a Python virtual environment
echo "Creating Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies inside the virtual environment
echo "Installing Python dependencies..."
pip install -r requirements.txt

# Install Node.js dependencies
echo "Installing Node.js dependencies..."
pnpm install

# Prompt the user for .env details
echo "Creating the .env file..."
CLIENT_ID=$(prompt_for_input "Enter your Spotify Client ID" "your-client-id")
CLIENT_SECRET=$(prompt_for_input "Enter your Spotify Client Secret" "your-client-secret")
SPOTIFY_USERNAME=$(prompt_for_input "Enter your Spotify Username" "your-username")
REDIRECT_URI=$(prompt_for_input "Enter your Spotify Redirect URI" "http://localhost/redirect")

# Write the .env file
cat <<EOF > .env
SPOTIPY_CLIENT_ID="$CLIENT_ID"
SPOTIPY_CLIENT_SECRET="$CLIENT_SECRET"
SPOTIPY_USERNAME="$SPOTIFY_USERNAME"
SPOTIPY_REDIRECT_URI="$REDIRECT_URI"
EOF

echo ".env file created successfully!"

# Ensure generateToken.py is executable
echo "Setting executable permissions for generateToken.py..."
chmod +x python/generateToken.py

# Generate the Spotify token
echo "Please visit the provided URL, authorize access, and then paste the full redirect URL here."
read -p "Enter the full redirect URL: " redirect_url

# Extract the authorization code from the URL
authorization_code=$(extract_code_from_url "$redirect_url")

# Pass the extracted code to generateToken.py
python3 python/generateToken.py "$authorization_code"

# Build and start the production version of the application
echo "Building and starting the production version..."
pnpm build
pnpm start &  # Run the app in the background

# Read the redirect URL from the .env file
REDIRECT_URI=$(grep -oP '(?<=SPOTIPY_REDIRECT_URI=).+' .env)

# Launch Chromium in full-screen mode with GPU acceleration disabled
echo "Launching Chromium in full-screen mode to $REDIRECT_URI..."
chromium-browser --kiosk "$REDIRECT_URI" --noerrdialogs --disable-infobars --disable-session-crashed-bubble --disable-gpu

# Inform the user to activate the virtual environment when needed
echo "To activate the virtual environment later, run 'source venv/bin/activate'"

