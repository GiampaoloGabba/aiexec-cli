# AI Exec - Quick Reference

## 🚀 Quick Install
```bash
curl -fsSL https://raw.githubusercontent.com/GiampaoloGabba/aiexec-cli/main/install.sh | bash
export ANTHROPIC_API_KEY='sk-ant-xxx'
source ~/.bashrc
```

## ⚡ Base Commands
```bash
ai  <prompt>    # Output only (SAFE)
aix <prompt>    # Execute (WITH BLACKLIST)
aie <prompt>    # Execute + report (WITH BLACKLIST)
```

## 🎯 Flags
```bash
-f, --force     # Bypass blacklist (DANGEROUS!)
-r, --raw       # Unclean output
-t, --thinking  # Extended thinking
-b, --balanced  # Balanced tier (better performance)
-p, --premium   # Premium tier (maximum capability)
```

## ⚡ Quick Aliases
```bash
ait   # ai --thinking
aib   # ai --balanced
aixt  # aix --thinking
aiet  # aie --thinking
```

## 🛡️ Blacklist (MAIN FEATURE!)

### 🔴 BLOCK - Completely Blocked
- `rm -rf /` and variants
- Fork bomb
- Disk formatting
- Overwriting /etc/passwd
- `curl | bash`
- Firewall disable

### 🟡 ASK - Require Confirmation
- `find / -delete`
- `chmod -R /`
- SSH modifications
- `reboot` / `shutdown`
- `killall -9`
- `chmod 777 -R`

### Block Example
```bash
$ aix delete everything
🛑 COMMAND BLOCKED!
To force: aix --force [command]
```

### Confirmation Example
```bash
$ aix restart system
⚠️ Risky command!
Do you want to execute? [y/N]
```

## ⚙️ Configuration File

**Location**: `~/.aiexec/config`

Edit with:
```bash
nano ~/.aiexec/config
# or
vim ~/.aiexec/config
```

### What You Can Configure

**AI Models**:
```bash
MODEL_FAST="claude-haiku-4-5-20251001"        # Fast tier (default)
MODEL_BALANCED="claude-sonnet-4-5-20250929"   # Balanced tier (default)
MODEL_PREMIUM="claude-opus-4-1-20250805"      # Premium tier (default)
DEFAULT_MODEL_TIER="fast"                     # Which tier (default: fast)
```

**Behavior**:
```bash
DEFAULT_THINKING="false"          # Default: false
AI_AIE_AUTO_SMART="true"          # Default: true
AI_RESPONSE_LANG="English"        # Default: English
EXPLORE_OUTPUT_MAX_CHARS="4000"   # Default: 4000
```

**Security**:
```bash
AI_BLACKLIST_EXTRA=""  # Default: empty (no custom patterns)
```

**Smart Mode Detection**:
```bash
SMART_MODE_THRESHOLD="2"          # Default: 2
SMART_MODE_LENGTH_THRESHOLD="150" # Default: 150
# Plus customizable keyword arrays (47 keywords + 15 complex terms)
```

Changes take effect immediately (no restart needed)!

## 📊 Error Handling (NEW!)

### Intelligent Exit Code
```bash
$ aie failing command
⚠️ Exit code: 1
📊 Analyzing...
[Claude suggests debug commands]
```

## 🧹 Clean Output (NEW!)

### Before (raw output)
```
```bash
$ ls -la
```
```

### After (clean)
```
ls -la
```

## 🎯 Practical Examples

### Normal (safe)
```bash
ai list files
aix cat file.txt
aie analyze logs
```

### With flags
```bash
ai -b complex query           # Balanced tier
aix -t find pattern            # Thinking
aie --force risky command   # Force
```

### Combinations
```bash
ai -t -b deep analysis
aix --force --thinking critical operation
```

## 🔒 Best Practices

✅ **DO:**
- Use `ai` by default
- `aix` for read commands
- `aie` for diagnostics
- Configure `AI_BLACKLIST_EXTRA`

❌ **DON'T:**
- `--force` without understanding the command
- `aix` for destructive commands
- Ignore blacklist warnings

## 🚨 When to Use --force

```bash
# ❌ NEVER like this
aix --force whatever

# ✅ Only when:
# 1. You verified with 'ai'
ai critical operation
# [verify output]

# 2. You are SURE of the command
aix --force [verified command]
```

## 💡 Quick Tips

```bash
# Full help
ai --help

# Test blacklist
aix rm -rf test/  # Asks for confirmation
ai rm -rf test/   # Only shows (safe)

# Temporary bypass
aix --force [command]

# Raw output
ai --raw [command]

# Powerful combo
aie -t -b analyze complete system
```

## 📊 Model Tiers

| Tier | Flag | Speed | Cost | Use case |
|------|------|-------|------|----------|
| **Fast** | (default) | ⚡⚡⚡ | 💰 | Simple commands |
| **Balanced** | -b | ⚡⚡ | 💰💰💰 | Complex tasks |
| **Premium** | -p | ⚡ | 💰💰💰💰💰 | Critical work |

Configure models in `~/.aiexec/config`

## 📞 Troubleshooting

### Command blocked incorrectly?
```bash
# 1. Verify exact command
ai [your request]

# 2. Execute manually
[shown command]

# 3. Or use force if sure
aix --force [command]
```

### Blacklist too restrictive?
```bash
# Temporarily disable
aix --force [command]

# Or modify patterns in ~/.local/bin/aiexec
# is_dangerous() section
```

### Exit code always 0?
Verify you have the latest version:
```bash
ai --help | head -1
# Should say "AI Exec"
```

## 🆘 Quick Links

- **GitHub**: https://github.com/GiampaoloGabba/aiexec-cli
- **Issues**: https://github.com/GiampaoloGabba/aiexec-cli/issues
- **Claude Docs**: https://docs.claude.com
- **API Console**: https://console.anthropic.com

---
**Remember: safe, fast, and powerful! 🚀**
