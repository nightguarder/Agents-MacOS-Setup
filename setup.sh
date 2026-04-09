#!/bin/bash

# Configuration
AGENT_USER="agents"
HOST_USER=$(whoami)
DEV_FOLDER="$HOME/Developer"

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

# 3. Ensure the Agent owns its own home
sudo chown -R $AGENT_USER:staff /Users/$AGENT_USER

# 4. Grant Host User access to see Agent's folder in Finder
sudo chmod +a "user:$HOST_USER allow list,search,read,execute,file_inherit,directory_inherit" /Users/$AGENT_USER

echo "✅ Setup complete. Add the 'ai' function to your .zshrc next."
