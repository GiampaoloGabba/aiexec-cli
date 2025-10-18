<div align="center">
  <img src="assets/aiexec-logo-full.svg" alt="AI Exec CLI Logo" width="600">

  <h3>Fast, secure CLI wrapper for Claude Code</h3>
  <p>Intelligent command generation and execution with built-in safety features</p>
</div>

---

## 🚀 Quick Install

One-liner installation:

```bash
curl -fsSL https://raw.githubusercontent.com/GiampaoloGabba/aiexec-cli/master/install.sh | bash
```

Or manual installation:

```bash
# 1. Download and make executable
git clone https://github.com/GiampaoloGabba/aiexec-cli.git
cd aiexec-cli
chmod +x install.sh aiexec

# 2. Run installation
./install.sh

# 3. Configure API key
export ANTHROPIC_API_KEY='sk-ant-xxx'
echo 'export ANTHROPIC_API_KEY="sk-ant-xxx"' >> ~/.bashrc  # or ~/.zshrc

# 4. Reload shell
source ~/.bashrc  # or ~/.zshrc
```

## 📖 Available Commands

### `ai` - Command output only (SAFE)
Generates the command but DOES NOT execute it. You verify and press enter.
**Auto-copies to clipboard** for quick pasting!

```bash
# Examples
ai list files
ai find python files
ai show disk usage
ai backup database
```

💡 **Tip**: Command is automatically copied to clipboard. Just press `Ctrl+V` and `Enter` to execute!

### `aix` - Auto-execute
Generates AND executes the command immediately (with blacklist protection).

```bash
# Examples
aix create logs directory
aix install htop package
aix restart nginx
```

⚠️ **Warning**: command is executed immediately (with safety checks)!

### `aie` - Execute + Intelligent Report
Executes the command AND asks the model to analyze the result.

```bash
# Examples
aie analyze error logs
aie check active services
aie verify network connections
aie find large files
```

### `aic` - Chat mode (NEW!)
Ask questions directly to the AI without generating commands.

```bash
# Examples
aic explain what is a symbolic link
aic how do I use awk to parse logs
aic what is the difference between TCP and UDP
aic explain bash arrays
```

💡 **Tip**: Perfect for learning, explanations, and general AI assistance!

## 🎛️ Optional Flags

### `-t, --thinking` - Extended Thinking
Use extended reasoning for complex problems.

```bash
ai -t debug complex bash script
aie -t analyze database performance
```

### `-b, --balanced` - Balanced Tier Model
More powerful model for difficult tasks (moderate cost).

```bash
ai -b optimize complex SQL query
aie -b analyze system architecture
```

### `-p, --premium` - Premium Tier Model
Maximum capability for very complex tasks (highest cost).

```bash
ai -p complete code refactoring
aie -p in-depth security analysis
```

### `-f, --force` - Force Bypass Blacklist
Bypass safety checks (use with extreme caution).

```bash
aix --force risky operation  # NOT RECOMMENDED
```

### `-r, --raw` - Raw Output
Don't clean Claude's output.

```bash
ai --raw show complex data
```

### `--no-clipboard` - Disable Clipboard Copy
Disable automatic clipboard copy in `ai` mode.

```bash
ai --no-clipboard list files  # Won't copy to clipboard
```

### `-h, --help` - Help
```bash
ai --help
```

## 🛡️ Security Features

### Two-Level Blacklist System

#### 🔴 BLOCK - Completely Blocked
- `rm -rf /` and variants
- Fork bombs
- Disk formatting
- Overwriting /etc/passwd
- `curl | bash`
- Firewall disable
- Immediate shutdowns

#### 🟡 ASK - Requires Confirmation
- `find / -delete`
- Recursive `chmod` on /
- SSH modifications
- `reboot` / `shutdown`
- `killall -9`
- `chmod 777 -R`

### Custom Blacklist
Extend the blacklist with your own patterns:

```bash
# In your .bashrc/.zshrc
export AI_BLACKLIST_EXTRA="pattern1|pattern2"

# Examples:
export AI_BLACKLIST_EXTRA="systemctl.*stop.*nginx|docker.*rm.*-f"
export AI_BLACKLIST_EXTRA="git.*push.*--force|npm.*publish"
```

## 🧠 Smart Mode Auto-Detection

The `aie` (explore) command automatically detects complex prompts and offers to use Sonnet + thinking mode for better analysis.

### Control auto-detection:
```bash
# Enable (default)
export AI_AIE_AUTO_SMART=true

# Disable
export AI_AIE_AUTO_SMART=false
```

When enabled, you'll see an interactive prompt for complex requests:
```bash
$ aie analyze the logs to find errors
🧠 Complexity detected. Use thinking mode (Sonnet + thinking)?
   [ ] YES    [●] NO    (Spacebar: toggle | Enter: confirm)
```

**Note**: Manual model/thinking flags (`-s`, `-o`, `-m`, `-t`) always override auto-detection.

## 💡 Practical Examples

### Typical workflow (SAFE mode)
```bash
# 1. Ask for the command
$ ai list all log files

# Output:
find . -name "*.log"

# 2. Verify it's correct
# 3. Execute it manually
$ find . -name "*.log"
```

### Quick execution (trust Claude)
```bash
# Create backup in one shot
$ aix create backup of /var/www in /backup
🤖 Command: tar -czf /backup/www-backup-2025-10-18.tar.gz /var/www
⚙️ Executing...
```

### Intelligent analysis
```bash
$ aie show CPU and memory usage
🤖 Command: top -b -n 1 | head -n 20

[command output]

📊 Analyzing...
The system shows:
- CPU: 23% usage, mainly nginx process
- Memory: 4.2GB used out of 8GB (52%)
- Low load average, stable system
💡 Suggestion: Sufficient memory, no action needed
```

### Flag combinations
```bash
# Complex task with thinking and powerful model
$ ai -t -b find and fix memory leak in application

# Quick analysis with better model
$ aie -b postgresql performance
```

## ⚙️ Advanced Configuration

### Configuration File

The installer automatically creates `~/.aiexec/config` from `config.template` during installation. This file lets you customize all aspects of AI Exec behavior.

**Location**: `~/.aiexec/config`

**Edit with**:
```bash
nano ~/.aiexec/config
# or
vim ~/.aiexec/config
```

**Changes take effect immediately** - no restart needed!

### What You Can Configure

#### 1. AI Model Tiers
Customize which models are used for each tier:

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `MODEL_FAST` | `claude-haiku-4-5-20251001` | Fast tier (default) - Quick responses, low cost |
| `MODEL_BALANCED` | `claude-sonnet-4-5-20250929` | Balanced tier (`-b` flag) - Better reasoning, moderate cost |
| `MODEL_PREMIUM` | `claude-opus-4-1-20250805` | Premium tier (`-p` flag) - Maximum capability, highest cost |
| `DEFAULT_MODEL_TIER` | `fast` | Which tier to use by default (`fast`/`balanced`/`premium`) |

#### 2. Behavior Settings

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `DEFAULT_THINKING` | `false` | Enable extended thinking by default |
| `AI_AIE_AUTO_SMART` | `true` | Auto-detect complex prompts in explore mode |
| `AI_RESPONSE_LANG` | `English` | Language for AI analysis reports (any language supported by Claude) |
| `EXPLORE_OUTPUT_MAX_CHARS` | `4000` | Max output chars for analysis |

**AI Response Language**: Controls the language of analysis reports in `aie` command. Set to "Italian", "Spanish", or any language supported by Claude. Command generation and system messages remain in English.

Example:
```bash
# Italian analysis reports
AI_RESPONSE_LANG="Italian"

$ aie show disk usage
📋 REPORT
Il sistema mostra...
```

#### 3. Smart Mode Detection
Fine-tune automatic complexity detection:

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `SMART_MODE_THRESHOLD` | `2` | Minimum complexity score to trigger smart mode |
| `SMART_MODE_LENGTH_THRESHOLD` | `150` | Prompt length threshold (characters) |
| `SMART_MODE_KEYWORDS` | (array) | 47 complexity keywords (Italian + English) |
| `SMART_MODE_COMPLEX_TERMS` | (array) | 15 technical terms |
| `SMART_MODE_MULTISTEP_PATTERN` | (regex) | Regex pattern for multi-step operations |

#### 4. Security
Extend the safety blacklist with custom patterns:

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `AI_BLACKLIST_EXTRA` | `""` | Additional patterns for ASK blacklist (pipe-separated regex) |

**Examples:**
```bash
AI_BLACKLIST_EXTRA="systemctl.*stop.*nginx|docker.*rm.*-f"
AI_BLACKLIST_EXTRA="git.*push.*--force|npm.*publish"
```

### Context File System (NEW!)

**Location**: `~/.aiexec/context.txt`

Automatically include context in all AI prompts. Perfect for project-specific information!

**How it works:**
- If `~/.aiexec/context.txt` exists, its content is automatically prepended to all prompts
- Applies to all modes: `ai`, `aix`, `aie`, and `aic`
- Maximum 2000 characters (automatically truncated)
- Silent if file doesn't exist (no errors)

**Example:**
```bash
# Create context file for your project
cat > ~/.aiexec/context.txt << 'EOF'
This is a Python project using FastAPI framework.
Database: PostgreSQL with SQLAlchemy ORM
Testing: pytest
Deployment: Docker containers
EOF

# Now all commands will have this context
ai create a new user endpoint
# AI knows it's FastAPI, will generate appropriate code

aic what database am I using
# Response: "You're using PostgreSQL with SQLAlchemy ORM"
```

**Use cases:**
- Project-specific tech stack information
- Common coding preferences or conventions
- Environment details (OS, shell, tools)
- Reminders about project structure

### Clipboard Integration (NEW!)

The `ai` command automatically copies generated commands to your clipboard for instant pasting!

**Supported platforms:**
- **Linux X11**: Uses `xclip`
- **Linux Wayland**: Uses `wl-copy`
- **Linux fallback**: Uses `xsel`

**Installation (if needed):**
```bash
# Debian/Ubuntu
sudo apt install xclip

# Wayland
sudo apt install wl-clipboard

# Alternative
sudo apt install xsel
```

**Usage:**
```bash
$ ai list python files
find . -name "*.py"
✓ Command copied to clipboard

# Just paste and run!
$ <Ctrl+V> <Enter>
```

**Disable clipboard:**
```bash
ai --no-clipboard list files  # Skips clipboard copy
```

### Environment Variables Override

You can temporarily override config settings using environment variables:

```bash
# Temporary language change
AI_RESPONSE_LANG="Italian" aie analyze logs

# Disable smart mode detection
AI_AIE_AUTO_SMART=false aie complex task

# Custom blacklist for one command
AI_BLACKLIST_EXTRA="pattern1|pattern2" aix command
```

### Add Custom Aliases
In `~/.bashrc` or `~/.zshrc`:

```bash
alias ait='ai -t'          # ai with thinking
alias aib='ai -b'          # ai with balanced tier
alias aixt='aix -t'        # aix with thinking
```

## 📊 Model Tiers

AI Exec uses a tier-based system that you can fully customize via `~/.aiexec/config`:

| Tier | Flag | Default Model | Speed | Cost | When to use |
|------|------|---------------|-------|------|-------------|
| **Fast** | (default) | Haiku 4.5 | ⚡⚡⚡ | 💰 | Simple commands, daily use |
| **Balanced** | `-b` | Sonnet 4.5 | ⚡⚡ | 💰💰💰 | Complex tasks, analysis |
| **Premium** | `-p` | Opus 4.1 | ⚡ | 💰💰💰💰💰 | Critical work, deep analysis |

**Customize models**: Edit `~/.aiexec/config` to assign different AI models to each tier based on your needs and budget.

## 🔒 Security Recommendations

### Best Practices:
1. **Use `ai` as default** - always verify before executing
2. **`aix` only for safe commands** - e.g. `ls`, `cat`, `grep`
3. **NEVER `aix` with `sudo`** without verifying first
4. **Always check** commands that modify system files

### DANGEROUS Example ⚠️:
```bash
# ❌ DON'T DO:
aix delete all old files

# ✅ INSTEAD:
ai delete old files
# [verify the generated command]
# [execute it yourself if correct]
```

## 🐛 Troubleshooting

### Claude not found
```bash
# Verify installation
which claude
claude doctor

# Reinstall if necessary
curl -fsSL https://claude.ai/install.sh | bash
source ~/.bashrc
```

### API key not configured
```bash
# Add permanently
echo 'export ANTHROPIC_API_KEY="sk-ant-xxx"' >> ~/.bashrc
source ~/.bashrc

# Verify
echo $ANTHROPIC_API_KEY
```

### ai/aix/aie commands not found
```bash
# Verify PATH
echo $PATH | grep ".local/bin"

# Add if missing
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Strange output or errors
```bash
# Try with thinking for debug
ai -t [your request]

# Or use more powerful model
ai -s [your request]
```

## 📈 Optimization Tips

1. **Be specific**: "list log files modified today" instead of "log files"
2. **Use fast tier by default**: switch to balanced/premium only if needed
3. **Thinking only for complexity**: not needed for simple commands
4. **Batch commands**: one complex request instead of 10 calls

## 🔄 Updates

```bash
# Update Claude Code
claude install

# Update aiexec script
cd aiexec-cli
git pull
./install.sh
```

## 📝 Notes

- Claude Code requires internet connection
- Commands are executed with your user permissions
- Extended thinking increases latency and cost
- Haiku 4.5 is very fast and economical for daily use

## 🆘 Support

For issues with:
- **Claude Code**: https://docs.claude.com
- **API/authentication**: https://console.anthropic.com
- **This wrapper**: https://github.com/GiampaoloGabba/aiexec-cli/issues

---

**Happy coding! 🚀**
