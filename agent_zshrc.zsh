# Minimalist Agent Shell
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Auto-completion
autoload -Uz compinit && compinit

# Identity (prevents git commit errors)
git config --global user.name "AI-Agent"
git config --global user.email "agent@local.sandbox"

# Workspace
# Try to find the host's Developer folder
HOST_DEV=$(ls -d /Users/*/Developer 2>/dev/null | grep -v "shared\|agents\|Guest" | head -n 1)
if [ -d "$HOST_DEV" ]; then
    cd "$HOST_DEV"
else
    cd ~
fi

# API Keys (Placeholders)
# export GEMINI_API_KEY="your-key-here"
