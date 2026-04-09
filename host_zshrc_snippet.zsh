# --- AI Agent Sandbox Bridge ---
# Usage: ai <command> (e.g., ai gemini "explain this code")
ai() {
    # -i: Login shell (loads agent's .zshrc)
    # -u: Runs as the agent user
    sudo -i -u agents "$@"
}
