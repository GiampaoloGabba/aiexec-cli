#!/bin/bash
set -e

echo ""
echo -e "\033[38;5;48m         \033[38;5;48m   \033[38;5;214m _____ \033[38;5;208m__  __ \033[38;5;202m _____ \033[38;5;196m ____ \033[0m"
echo -e "\033[38;5;48m   /\\   \033[38;5;48m ░░ \033[38;5;214m| ____|\033[38;5;208m\\ \\/ / \033[38;5;202m| ____|\033[38;5;196m/ ___|\033[0m"
echo -e "\033[38;5;48m  /  \\  \033[38;5;48m ░░ \033[38;5;214m|  _|  \033[38;5;208m \\  /  \033[38;5;202m|  _|  \033[38;5;196m| |    \033[0m"
echo -e "\033[38;5;48m / /\\ \\ \033[38;5;48m ░░ \033[38;5;214m| |___ \033[38;5;208m /  \\  \033[38;5;202m| |___ \033[38;5;196m| |___ \033[0m"
echo -e "\033[38;5;48m/_/  \\_\\\\\033[38;5;48m ░░ \033[38;5;214m|_____|\033[38;5;208m/_/\\_\\ \033[38;5;202m|_____|\033[38;5;196m\\____|\033[0m"
echo ""
echo -e "         🤖 \033[1;32mAI\033[0m → 💻 \033[1;38;5;208mCommand Execution\033[0m  ⚡"
echo ""
echo "=== Installing AI Exec for Claude Code ==="
echo ""

# 1. Install Claude Code with binaries
echo "📦 Installing Claude Code (binaries)..."
if ! command -v claude &> /dev/null; then
    curl -fsSL https://claude.ai/install.sh | bash
    echo "✓ Claude Code installed"
else
    echo "✓ Claude Code already installed"
fi

# 2. Verify installation
echo ""
echo "🔍 Verifying installation..."
claude doctor || true

# 3. Create directory for scripts
mkdir -p ~/.local/bin

# 4. Download wrapper script
echo ""
echo "📝 Installing wrapper script..."

# If script is in the same directory
if [ -f "./aiexec" ]; then
    cp ./aiexec ~/.local/bin/aiexec
elif [ -f "/tmp/aiexec" ]; then
    cp /tmp/aiexec ~/.local/bin/aiexec
else
    echo "❌ Error: aiexec file not found" >&2
    echo "Make sure it's in the current directory or /tmp" >&2
    exit 1
fi

chmod +x ~/.local/bin/aiexec

# 4.5. Install configuration file
echo ""
echo "⚙️  Installing configuration..."
mkdir -p ~/.aiexec

# Only copy config if it doesn't exist (preserve user customizations)
if [ ! -f ~/.aiexec/config ]; then
    if [ -f "./config.template" ]; then
        cp ./config.template ~/.aiexec/config
        echo "✓ Configuration file created: ~/.aiexec/config"
    elif [ -f "/tmp/config.template" ]; then
        cp /tmp/config.template ~/.aiexec/config
        echo "✓ Configuration file created: ~/.aiexec/config"
    else
        echo "⚠️  Warning: config.template not found, using defaults" >&2
        echo "   You can create ~/.aiexec/config manually later" >&2
    fi
else
    echo "✓ Existing configuration preserved: ~/.aiexec/config"
fi

# 5. Create aliases
echo ""
echo "🔗 Creating aliases..."

# Determine shell config file
SHELL_RC=""
if [ -f ~/.zshrc ]; then
    SHELL_RC=~/.zshrc
elif [ -f ~/.bashrc ]; then
    SHELL_RC=~/.bashrc
else
    echo "⚠️  Warning: no .bashrc or .zshrc found"
    exit 1
fi

# Backup config file
cp "$SHELL_RC" "${SHELL_RC}.backup.$(date +%Y%m%d_%H%M%S)"

# Remove old aliases if they exist
if grep -q "# AI Exec aliases" "$SHELL_RC"; then
    echo "🔄 Removing old aliases..."
    # Remove from "# AI Exec aliases" line until next empty line
    sed -i.bak '/# AI Exec aliases/,/^$/d' "$SHELL_RC"
fi

# Add new aliases
cat >> "$SHELL_RC" << 'EOFALIAS'

# AI Exec aliases - Secure interface for Claude Code
export PATH="$HOME/.local/bin:$PATH"
alias ai='aiexec simple'
alias aix='aiexec exec'
alias aie='aiexec explore'
# Optional aliases with common flags
alias ait='aiexec simple --thinking'
alias aib='aiexec simple --balanced'
alias aixt='aiexec exec --thinking'
alias aiet='aiexec explore --thinking'

EOFALIAS
echo "✓ Aliases added to $SHELL_RC"

# 6. Final instructions
echo ""
echo "✅ Installation complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 AI EXEC - KEY FEATURES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🛡️  ENHANCED SECURITY:"
echo "   • Smart two-level blacklist"
echo "   • BLOCK: extremely dangerous commands"
echo "   • ASK: risky commands (requires confirmation)"
echo ""
echo "🧠 SMART THINKING MODE:"
echo "   • Auto-detects complex prompts in 'aie' mode"
echo "   • Interactive toggle: use Sonnet + thinking?"
echo "   • Default: NO (fast Haiku mode)"
echo "   • Supports Italian & English keywords"
echo ""
echo "🎯 FLAGS:"
echo "   -f, --force     Bypass blacklist (use with caution!)"
echo "   -r, --raw       Unclean output"
echo "   -t, --thinking  Extended thinking"
echo "   -b, --balanced  Use balanced tier (better performance)"
echo "   -p, --premium   Use premium tier (maximum capability)"
echo ""
echo "⚡ EXTRA QUICK ALIASES:"
echo "   ait   - ai with thinking"
echo "   aib   - ai with balanced"
echo "   aixt  - aix with thinking"
echo "   aiet  - aie with thinking"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 NEXT STEPS:"
echo ""
echo "1. Configure your API key:"
echo "   export ANTHROPIC_API_KEY='your-key-here'"
echo "   echo 'export ANTHROPIC_API_KEY=\"your-key-here\"' >> $SHELL_RC"
echo ""
echo "2. Reload shell:"
echo "   source $SHELL_RC"
echo ""
echo "3. Test the system:"
echo "   ai --help"
echo "   ai list files"
echo "   aix echo test"
echo ""
echo "⚙️  CONFIGURATION FILE:"
echo "   Location: ~/.aiexec/config"
echo ""
echo "   Customize:"
echo "   • AI models for each tier (fast/balanced/premium)"
echo "   • Default thinking mode and response language"
echo "   • Smart mode detection (keywords, thresholds)"
echo "   • Security blacklist patterns"
echo ""
echo "   Edit with: nano ~/.aiexec/config"
echo "   Or:        vim ~/.aiexec/config"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📖 For all flags and examples: ai --help"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
