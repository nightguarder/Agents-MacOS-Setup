# --- AI Agent Environment (/Users/agents/.zshrc) ---

# 1. Paths & Tools
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# 2. Sandboxed Tool Wrappers
# Note: These aliases are for when running directly in the 'agents' shell.
# They require ADMIN_USER to be set or will default to a placeholder.
alias sb='sandbox-exec -f ~/.config/sandboxes/agent-profile.sb -D PROJECT_DIR=$PWD -D ADMIN_USER=${USER_ADMIN:-admin}'

# 3. Environment Redirects
export HOME=/Users/agents
export TMPDIR=/tmp

# 4. Docker/Colima Bridge
# DOCKER_HOST is set dynamically in the bridge function if possible
# Here we use a generic path that relies on the ADMIN_USER variable logic
# export DOCKER_HOST=unix:///Users/${USER_ADMIN:-admin}/.colima/default/docker.sock

# 5. Docker Plugin Discovery
export DOCKER_CONFIG="$HOME/.docker"

# 6. Quality of Life
alias cls='clear'
alias ll='ls -la'
autoload -Uz compinit && compinit -u

# 7. Git Identity
git config --global user.name "AI-Agent"
git config --global user.email "agent@local.sandbox"

# 8. Workspace Discovery
# Finds the first developer folder in /Users that isn't agents or shared
HOST_DEV=$(ls -d /Users/*/Developer 2>/dev/null | grep -v "shared\|agents\|Guest" | head -n 1)
if [ -d "$HOST_DEV" ]; then
    cd "$HOST_DEV"
else
    cd ~
fi
