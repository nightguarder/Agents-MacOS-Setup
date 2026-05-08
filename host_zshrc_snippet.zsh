# --- AI Agent Sandbox Bridge ---
# All AI commands run under strict sandbox: deny home directory by default

# Sandbox wrappers (these scripts handle sandbox-exec internally)
OPENCODE_SANDBOX="$HOME/.config/sandboxes/opencode-sandbox"
GEMINI_SANDBOX="$HOME/.config/sandboxes/gemini-sandbox"

# Main bridge - runs any command under sandbox with params
ai() {
    if [ $# -eq 0 ]; then
        echo "Usage: ai <command> [args]"
        return 1
    fi

    local profile="$HOME/.config/sandboxes/agent-profile.sb"
    local project_dir=$(pwd)

    sudo -u agents -H \
        /usr/bin/sandbox-exec -f "$profile" \
        -D PROJECT_DIR="$project_dir" \
        /usr/bin/env HOME=/Users/agents PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" "$@"
}

# Direct aliases - use sandboxed wrappers if available
alias opencode="$OPENCODE_SANDBOX"
alias gemini="$GEMINI_SANDBOX"

# Fallback: run via ai() bridge with sandbox profile
alias ai-gemini='sudo -u agents -H /usr/bin/sandbox-exec -f $HOME/.config/sandboxes/agent-profile.sb -D PROJECT_DIR=$PWD'
alias ai-opencode='sudo -u agents -H /usr/bin/sandbox-exec -f $HOME/.config/sandboxes/agent-profile.sb -D PROJECT_DIR=$PWD'

# Docker/Colima helper
alias colimastart="colima start --vm-type vz --arch host --cpus 2 --memory 2 --disk 30 --mount-type virtiofs"