#!/bin/bash

# Function to prompt the user for input
prompt_for_input() {
  read -p "$1 [$2]: " input
  echo "${input:-$2}"
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
REFRESH_TOKEN=$(prompt_for_input "Enter your Spotify Refresh Token" "your-refresh-token")

# Write the .env file
cat <<EOF > .env
SPOTIPY_CLIENT_ID="$CLIENT_ID"
SPOTIPY_CLIENT_SECRET="$CLIENT_SECRET"
SPOTIPY_REFRESH_TOKEN="$REFRESH_TOKEN"
EOF

echo ".env file created successfully!"

# Ensure generateToken.py in the python folder is executable
echo "Setting executable permissions for generateToken.py..."
chmod +x python/generateToken.py

# Generate the Spotify token using the virtual environment's Python
echo "Generating Spotify token..."
python3 python/generateToken.py

# Build and start the production version of the application
echo "Building and starting the production version..."
pnpm build
pnpm start

echo "Setup is complete. The app is now running."

# Inform the user to activate the virtual environment when needed
echo "To activate the virtual environment later, run 'source venv/bin/activate'"
