# --- AI Agent Environment (/Users/agents/.zshrc) ---

# 1. Paths & Tools
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# 2. Sandboxed Tool Wrappers
# Run tools under strict sandbox profile (deny home directory by default)
alias sb='sandbox-exec -f ~/.config/sandboxes/agent-profile.sb -D PROJECT_DIR=$PWD'

# 3. Environment Redirects
export HOME=/Users/agents
export TMPDIR=/tmp

# 4. Docker/Colima Bridge
export DOCKER_HOST="unix:///Users/cyrils/.colima/default/docker.sock"
export DOCKER_CONFIG="$HOME/.docker"

# 5. Quality of Life
alias cls='clear'
alias ll='ls -la'
autoload -Uz compinit && compinit -u

# 6. Git Identity
git config --global user.name "AI-Agent"
git config --global user.email "agent@local.sandbox"

# 7. Workspace Discovery
# Find the developer folder in admin's home
HOST_DEV="/Users/cyrils/Developer"
if [ -d "$HOST_DEV" ]; then
    cd "$HOST_DEV"
else
    cd ~
fi