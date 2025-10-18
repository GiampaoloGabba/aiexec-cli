<div align="center">
  <img src="aiexec-logo-full.svg" alt="AI Exec CLI Logo" width="600">

  <h3>Fast, secure CLI wrapper for Claude Code</h3>
  <p>Intelligent command generation and execution with built-in safety features</p>
</div>

---

## 🚀 Quick Install

One-liner installation:

```bash
curl -fsSL https://raw.githubusercontent.com/GiampaoloGabba/aiexec-cli/main/install.sh | bash
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

```bash
# Examples
ai list files
ai find python files
ai show disk usage
ai backup database
```

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

### Change default model
Edit in `~/.local/bin/aiexec`:

```bash
DEFAULT_MODEL="claude-sonnet-4-5-20250929"  # instead of Haiku
```

### Configure AI response language
Set the language for AI-generated analysis reports (used in `aie` command):

```bash
# In your .bashrc/.zshrc
export AI_RESPONSE_LANG="English"   # Default
export AI_RESPONSE_LANG="Italian"   # Italian analysis reports
export AI_RESPONSE_LANG="Spanish"   # Spanish analysis reports
# ... any language supported by Claude
```

**Note**: This only affects AI-generated analysis reports in explore mode (`aie`). All command generation prompts and system messages remain in English.

Example:
```bash
# English analysis (default)
$ aie show disk usage
📋 REPORT
The system shows...

# Italian analysis
$ export AI_RESPONSE_LANG="Italian"
$ aie show disk usage
📋 REPORT
Il sistema mostra...
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

## 💰 Cost Management

### Fast tier (default):
- Input: $1 / 1M tokens
- Output: $5 / 1M tokens
- **Recommended for daily use**

### Sonnet 4.5:
- ~3x cost of Haiku
- Use only when necessary

### Opus 4.1:
- ~15x cost of Haiku
- Reserve for critical tasks

### Thinking:
- Increases output tokens
- Use only when complex reasoning is needed

## 📈 Optimization Tips

1. **Be specific**: "list log files modified today" instead of "log files"
2. **Use Haiku by default**: switch to Sonnet only if needed
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
