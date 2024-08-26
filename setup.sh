#!/bin/bash

# Function to prompt the user for input
prompt_for_input() {
  read -p "$1 [$2]: " input
  echo "${input:-$2}"
}

# Function to extract authorization code from URL
extract_code_from_url() {
  local url="$1"
  echo "${url##*code=}"
}

# Install necessary packages
echo "Installing necessary packages..."
sudo apt-get update || { echo "Failed to update package list"; exit 1; }
sudo apt-get install -y python3 python3-pip python3-venv git npm || { echo "Failed to install packages"; exit 1; }

# Install pnpm
echo "Installing pnpm..."
sudo npm install -g pnpm || { echo "Failed to install pnpm"; exit 1; }

# Clone the repository
echo "Cloning the repository..."
git clone https://github.com/Canterrain/spotify-diy-thing.git || { echo "Failed to clone repository"; exit 1; }
cd spotify-diy-thing || { echo "Failed to change directory to spotify-diy-thing"; exit 1; }

# Create and activate a Python virtual environment
echo "Creating Python virtual environment..."
python3 -m venv venv || { echo "Failed to create virtual environment"; exit 1; }
source venv/bin/activate || { echo "Failed to activate virtual environment"; exit 1; }

# Install Python dependencies inside the virtual environment
echo "Installing Python dependencies..."
pip install -r requirements.txt || { echo "Failed to install Python dependencies"; exit 1; }

# Install Node.js dependencies
echo "Installing Node.js dependencies..."
pnpm install || { echo "Failed to install Node.js dependencies"; exit 1; }

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

# Validate .env file creation
if [ ! -f .env ]; then
  echo ".env file was not created successfully"
  exit 1
fi
echo ".env file created successfully!"

# Ensure generateToken.py is executable
echo "Setting executable permissions for generateToken.py..."
chmod +x python/generateToken.py || { echo "Failed to set executable permissions for generateToken.py"; exit 1; }

# Generate the Spotify token
echo "Please visit the provided URL, authorize access, and then paste the full redirect URL here."
read -p "Enter the full redirect URL: " redirect_url

# Extract the authorization code from the URL
authorization_code=$(extract_code_from_url "$redirect_url")

# Pass the extracted code to generateToken.py
python3 python/generateToken.py "$authorization_code" || { echo "Failed to generate Spotify token"; exit 1; }

# Build and start the production version of the application
echo "Building and starting the production version..."
pnpm build || { echo "Failed to build the production version"; exit 1; }
pnpm start || { echo "Failed to start the production version"; exit 1; }

# Read the redirect URL from the .env file
REDIRECT_URI=$(grep -oP '(?<=SPOTIPY_REDIRECT_URI=).+' .env)

# Launch Chromium in full-screen mode with GPU acceleration disabled
echo "Launching Chromium in full-screen mode to $REDIRECT_URI..."
chromium-browser --kiosk "$REDIRECT_URI" --noerrdialogs --disable-infobars --disable-session-crashed-bubble --disable-gpu || { echo "Failed to launch Chromium"; exit 1; }

# Inform the user to activate the virtual environment when needed
echo "To activate the virtual environment later, run 'source venv/bin/activate'"
