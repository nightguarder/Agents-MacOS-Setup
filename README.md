# 📦 Safe-Agent-Sandbox (macOS Native)

A minimalist, storage-light method for running AI Coding Agents (OpenCode, Gemini CLI, etc.) on macOS without giving them access to your personal files.

## 🚀 Why this setup?
* **Zero Bloat:** Uses native macOS user boundaries. No Docker, no VMs.
* **Storage Light:** Agents share your host's binaries (Homebrew, Node, Python).
* **Secure:** Agents are physically blocked from your `Documents`, `Photos`, and `Keychain`.
* **Integrated:** Agents work directly on your `~/Developer` files via ACLs.

---

## 🏗 0. Create the Agent User
Before running any scripts, you need a dedicated standard user on your Mac.

### Option A: via macOS System Settings (GUI)
1. Go to **System Settings** > **Users & Groups**.
2. Click **Add User...** (you may need to enter your admin password).
3. Set New Account type to **Standard**.
4. Full Name: `AI Agent`.
5. Account Name: `agents` (This is the name used in scripts).
6. Password: Set a secure password (you'll need this for the `ai` bridge).

### Option B: via Terminal (CLI)
If you prefer the command line, run this from your **host** account:
```bash
sudo sysadminctl -addUser agents -fullName "AI Agent" -password "your_secure_password"
```

---

## 🛠 1. The Setup Script (`setup.sh`)
This script configures the permissions bridge between your host user and the agent.

```bash
#!/bin/bash

# Configuration
AGENT_USER="agents"
HOST_USER=$(whoami)
DEV_FOLDER="$HOME/Developer"

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
```

---

## 🏠 2. Host Configuration (Add to `~/.zshrc`)
This function is your bridge. It allows you to run any command as the agent while staying in your current terminal session.

```zsh
# --- AI Agent Sandbox Bridge ---
# Usage: ai <command> (e.g., ai gemini "explain this code")
ai() {
    # -i: Login shell (loads agent's .zshrc)
    # -u: Runs as the agent user
    sudo -i -u agents "$@"
}
```

---

## 🤖 3. Agent Configuration (`/Users/agents/.zshrc`)
A minimalist profile for the agent. It doesn't need plugins or themes—just paths to the host's tools.

```zsh
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
```

---

## 📜 4. Project Context (`AGENTS.md`)
Place this in your project root so the agent understands its boundaries.

```markdown
# Environment Context
- You are a sandboxed agent user on macOS.
- You have access ONLY to this Developer folder.
- Do not attempt to access /Users/ (except for this project).
- Use host-provided binaries in /opt/homebrew/bin.
- Be decisive; implement logical improvements without asking for permission.
```

---

## 📖 How to use
1.  **Create a standard user** named `agents` in macOS System Settings.
2.  **Run `setup.sh`** to build the permission bridge.
3.  **Use `ai gemini` or `ai opencode`** to start working.

---

## ⚡️ Storage Anorexia
This setup uses **0 MB** of extra disk space for the environment. No 4GB Docker images, no heavy VMs. It’s just macOS doing what it was built to do: manage users.

## 🛡 Safety: Why This Matters (The "Clawdbot" Risk)
As open-source AI agents (like `Clawdbot`, `OpenCode`, and `Aider`) become more autonomous, they increasingly require the ability to run shell commands, install dependencies, and modify your system. 

**Without a sandbox, you are one `npm install` away from a supply-chain attack on your personal data.**

### The Risks:
* **Exfiltration:** An untrusted script could scan your `~/Documents` or `~/.ssh` and upload your private keys to a remote server.
* **Keychain Access:** If an agent has your user's permissions, it can potentially access your macOS Keychain and saved passwords.
* **Persistent Malware:** An agent could modify your `.zshrc` or install a background service that persists even after the task is finished.

### How the Sandbox Protects You:
By using a dedicated `agents` user, you create a **hard boundary**. Even if an agent turns malicious or is compromised via a poisoned open-source package:
1. It **cannot see** your personal files (Photos, Documents, Desktop).
2. It **cannot access** your primary user's Keychain.
3. It **cannot modify** your host system configuration.

--- 

## 🤝 Troubleshooting
*   **Permission Denied on Developer folder:** Re-run the `chmod -R +a` command in `setup.sh`.
*   **Git errors:** Ensure the agent's `.zshrc` has the `git config` lines.
*   **Path issues:** Verify `/opt/homebrew/bin` is in the agent's PATH if you use Apple Silicon.
