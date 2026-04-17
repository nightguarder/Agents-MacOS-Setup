#!/bin/bash

# Configuration
AGENT_USER="agents"
HOST_USER=$(whoami)
DEV_FOLDER="$HOME/Developer"
DOCKER_SOCKET="$HOME/.colima/default/docker.sock"

# 0. Check if Agent User exists
if ! id "$AGENT_USER" &>/dev/null; then
    echo "❌ Error: User '$AGENT_USER' not found."
    echo "   Please create the user first (see README.md Step 0)."
    exit 1
fi

echo "🔐 Setting up Native Sandbox for $AGENT_USER..."

# 1. Allow Agent to 'traverse' your home folder (but not read it)
# "The Hallway Rule": Let the agent walk down your hallway to get to the office, 
# without letting them peek into your bedroom (Documents).
chmod 711 /Users/$HOST_USER

# 2. Grant Agent full access to the Developer folder via ACLs
echo "📂 Bridging $DEV_FOLDER..."
chmod -R +a "user:$AGENT_USER allow read,write,delete,add_file,add_subdirectory,file_inherit,directory_inherit" "$DEV_FOLDER"

# 3. Docker/Colima Bridge
if [ -S "$DOCKER_SOCKET" ]; then
    echo "🐳 Bridging Docker Socket..."
    # Grant access via ACLs on the socket itself
    chmod +a "user:$AGENT_USER allow read,write" "$DOCKER_SOCKET"
else
    echo "⚠️ Warning: Colima Docker socket not found at $DOCKER_SOCKET."
fi

# 4. Deploy Sandbox Profile
echo "📜 Deploying Sandbox Profile..."
AGENT_CONFIG_DIR="/Users/$AGENT_USER/.config/sandboxes"
sudo mkdir -p "$AGENT_CONFIG_DIR"
sudo cp agent-profile.sb "$AGENT_CONFIG_DIR/agent-profile.sb"
sudo chown -R $AGENT_USER:staff "/Users/$AGENT_USER/.config"

# 5. Ensure the Agent owns its own home
echo "🏠 Ensuring Agent ownership of home folder..."
sudo chown -R $AGENT_USER:staff /Users/$AGENT_USER

# 6. Grant Host User access to see Agent's folder in Finder
sudo chmod +a "user:$HOST_USER allow list,search,read,execute,file_inherit,directory_inherit" /Users/$AGENT_USER

echo "✅ Setup complete. Use 'ai <command>' to bridge host commands."
