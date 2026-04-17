# --- AI Agent Sandbox Bridge ---
# All AI commands run as 'agents' user with kernel-level sandbox restrictions

# Main bridge function - wraps any command in sandbox
ai() {
    sudo -u agents -H /usr/bin/sandbox-exec \
        -f /Users/cyrils/.config/sandboxes/agent-profile.sb \
        -D PROJECT_DIR="$PWD" \
        "$@"
}

# Aliases using identical sandbox profile as ai()
# These ensure consistent security regardless of entry point
alias gemini='sudo -u agents -H /usr/bin/sandbox-exec -f /Users/cyrils/.config/sandboxes/agent-profile.sb -D PROJECT_DIR="$PWD" gemini'
alias opencode='sudo -u agents -H /usr/bin/sandbox-exec -f /Users/cyrils/.config/sandboxes/agent-profile.sb -D PROJECT_DIR="$PWD" opencode'
alias openclaw='sudo -u agents -H /usr/bin/sandbox-exec -f /Users/cyrils/.config/sandboxes/agent-profile.sb -D PROJECT_DIR="$PWD" openclaw'

# Docker/Colima helper
alias colimastart="colima start --vm-type=vz --vz-rosetta"