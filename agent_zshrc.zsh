# --- AI Agent Environment (/Users/agents/.zshrc) ---

# 1. Paths & Tools
# Force clean path to prevent leakage from master user
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# 2. Sandboxed Tool Wrappers
# Note: When running inside the 'ai' bridge, the sandbox is already active.
# These aliases are for when running directly in the 'agents' shell.
alias sb='sandbox-exec -f ~/.config/sandboxes/agent-profile.sb -D PROJECT_DIR=$PWD'

# 3. Environment Redirects
export HOME=/Users/agents
export TMPDIR=/tmp

# 4. Docker/Colima Bridge
# Points to host's Colima socket (bridged via ACLs in setup)
export DOCKER_HOST=unix:///Users/cyrils/.colima/default/docker.sock

# 5. Docker Plugin Discovery
# Enable Homebrew-installed Docker plugins
export DOCKER_CONFIG="$HOME/.docker"

# 6. Quality of Life
alias cls='clear'
alias ll='ls -la'
autoload -Uz compinit && compinit -u

# 7. Git Identity
git config --global user.name "AI-Agent"
git config --global user.email "agent@local.sandbox"

# 8. Workspace
# Navigate to Developer folder on login if accessible
if [ -d "/Users/cyrils/Developer" ]; then
    cd "/Users/cyrils/Developer"
else
    cd ~
fi
