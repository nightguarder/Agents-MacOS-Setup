# --- AI Agent Sandbox Bridge ---
# All AI commands run as 'agents' user with kernel-level sandbox restrictions

# Main bridge function - wraps any command in sandbox
ai() {
    if [ $# -eq 0 ]; then
        echo "Usage: ai <command> [args]"
        return 1
    fi

    # Detect current user or set manually
    local admin_user=$(whoami)
    local profile="$HOME/.config/sandboxes/agent-profile.sb"
    local project_dir=$(pwd)

    sudo -u agents -H \
        /usr/bin/sandbox-exec -f "$profile" \
        -D PROJECT_DIR="$project_dir" \
        -D ADMIN_USER="$admin_user" \
        /usr/bin/env HOME=/Users/agents PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" "$@"
}

# Aliases using identical sandbox profile as ai()
alias gemini='ai gemini'
alias opencode='ai opencode'
alias openclaw='ai openclaw'

# Docker/Colima helper
alias colimastart="colima start --vm-type=vz --vz-rosetta"
