#!/bin/bash

# Configuration
AGENT_USER="agents"
HOST_USER="cyrils"
DEV_FOLDER="$HOME/Developer"
DOCKER_SOCKET="$HOME/.colima/default/docker.sock"
SANDBOX_DIR="$HOME/.config/sandboxes"

echo "🔐 Setting up Native Sandbox V2 for $AGENT_USER..."

# 0. Check if Agent User exists
if ! id "$AGENT_USER" &>/dev/null; then
    echo "❌ Error: User '$AGENT_USER' not found."
    echo "   Please create the user first (see README.md Step 0)."
    exit 1
fi

# 1. Allow Agent to 'traverse' admin's home folder (but not read it)
echo "🚪 Setting up traversal permissions..."
chmod 711 /Users/$HOST_USER

# 2. Grant Agent full access to the Developer folder via ACLs
echo "📂 Bridging $DEV_FOLDER..."
chmod -R +a "user:$AGENT_USER allow read,write,delete,add_file,add_subdirectory,file_inherit,directory_inherit" "$DEV_FOLDER"

# 3. Docker/Colima Bridge
if [ -S "$DOCKER_SOCKET" ]; then
    echo "🐳 Bridging Docker Socket..."
    chmod +a "user:$AGENT_USER allow read,write" "$DOCKER_SOCKET"
else
    echo "⚠️ Warning: Colima Docker socket not found at $DOCKER_SOCKET."
fi

# 4. Deploy Sandbox Profiles
echo "📜 Deploying Sandbox Profiles..."

# Create sandbox config directory
mkdir -p "$SANDBOX_DIR"

# Copy sandbox profiles
cp agent-profile.sb "$SANDBOX_DIR/"
cp opencode-sandbox "$SANDBOX_DIR/"
cp gemini-sandbox "$SANDBOX_DIR/"

# Set ownership
chown -R $AGENT_USER:staff "$SANDBOX_DIR"

# Make wrappers executable
chmod +x "$SANDBOX_DIR/opencode-sandbox"
chmod +x "$SANDBOX_DIR/gemini-sandbox"

# 5. Deploy OpenCode Config
echo "⚙️ Deploying OpenCode Config..."
OPENCODE_CONFIG_DIR="/Users/$AGENT_USER/.config/opencode"
mkdir -p "$OPENCODE_CONFIG_DIR"
cp opencode-config.json "$OPENCODE_CONFIG_DIR/opencode.json"
chown -R $AGENT_USER:staff "$OPENCODE_CONFIG_DIR"

# 6. Ensure the Agent owns its own home
echo "🏠 Ensuring Agent ownership of home folder..."
chown -R $AGENT_USER:staff /Users/$AGENT_USER

# 7. Grant Host User access to see Agent's folder in Finder
chmod +a "user:$HOST_USER allow list,search,read,execute,file_inherit,directory_inherit" /Users/$AGENT_USER

echo ""
echo "✅ Setup complete!"
echo ""
echo "Usage:"
echo "  source ~/Developer/GitHub/Agents-MacOS-Setup/host_zshrc_snippet.zsh"
echo "  opencode 'fix this bug'"
echo "  gemini 'explain this code'"
echo ""
echo "Or use the ai() bridge:"
echo "  ai opencode 'fix this bug'"