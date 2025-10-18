# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Git Commit Guidelines

**IMPORTANT**: When creating git commits:
- **DO NOT** add "Generated with Claude Code" footer or "Co-Authored-By: Claude" signature
- Write clear, concise commit messages that focus on the "why" rather than the "what"
- Use the repository's existing commit message style (check `git log` for examples)
- Keep commits clean and professional without AI attribution

## Project Overview

AI Exec CLI is a fast, secure bash wrapper for Claude Code that provides intelligent command generation and execution with built-in safety features. The project consists of a single bash script (`aiexec`) that interfaces with Claude Code to translate natural language prompts into shell commands.

## Configuration System

### Configuration File
**Location**: `~/.aiexec/config`
**Template**: `config.template` (in repository root)
**Format**: Bash-sourceable (for maximum performance < 1ms overhead)

The configuration file is loaded at startup via `source` command (aiexec:11-13). This approach provides:
- **Near-zero overhead**: < 1ms on modern SSDs
- **No parsing required**: Native bash execution
- **Easy customization**: Standard bash syntax
- **Dynamic updates**: Changes take effect immediately (no restart needed)

### Configurable Elements

#### 1. AI Model Tiers (config.template:14-27)
```bash
# Fast tier (default) - Quick responses, low cost
MODEL_FAST="claude-haiku-4-5-20251001"

# Balanced tier (-b flag) - Better reasoning, moderate cost
MODEL_BALANCED="claude-sonnet-4-5-20250929"

# Premium tier (-p flag) - Maximum capability, highest cost
MODEL_PREMIUM="claude-opus-4-1-20250805"

# Which tier to use by default (fast/balanced/premium)
DEFAULT_MODEL_TIER="fast"
```

#### 2. Behavior Settings (config.template:29-36)
```bash
DEFAULT_THINKING="false"              # Enable extended thinking by default
AI_AIE_AUTO_SMART="true"              # Auto-detect complex prompts in explore mode
AI_RESPONSE_LANG="English"            # Language for AI analysis reports
EXPLORE_OUTPUT_MAX_CHARS="4000"       # Max output chars for analysis
```

#### 3. Smart Mode Detection (config.template:38-71)
```bash
SMART_MODE_THRESHOLD="2"              # Minimum complexity score (default: 2)
SMART_MODE_LENGTH_THRESHOLD="150"     # Prompt length threshold (chars)
SMART_MODE_KEYWORDS=(...)             # 47 complexity keywords (IT+EN)
SMART_MODE_COMPLEX_TERMS=(...)        # 15 technical terms
SMART_MODE_MULTISTEP_PATTERN="..."    # Regex for multi-step operations
```

#### 4. Security (config.template:93-106)
```bash
AI_BLACKLIST_EXTRA=""  # Additional patterns for ASK blacklist (extends built-in)
```

### Configuration Loading Architecture (aiexec:8-76)

The configuration system uses a **fallback pattern** for robustness:

1. **Load user config** (if exists): `source "$HOME/.aiexec/config"`
2. **Set defaults** for undefined variables: `${VAR:-default}` syntax
3. **Define arrays** only if not in config: `[[ ! -v ARRAY_NAME ]]` check

This ensures the script works **without** a config file while allowing **full customization**.

**Example flow**:
```bash
# If config defines MODEL_FAST, use it; otherwise use default
MODEL_FAST="${MODEL_FAST:-claude-haiku-4-5-20251001}"

# If config defines array, skip; otherwise define default
if [[ ! -v SMART_MODE_KEYWORDS ]]; then
  SMART_MODE_KEYWORDS=(
    'analiz[zs][aie]' 'debug' ...
  )
fi
```

### Flag System with Tier Mapping (aiexec:422-452)

The script maps user flags to configured model tiers:
- **Default model**: Determined by `DEFAULT_MODEL_TIER` setting
- **`-b, --balanced`**: Uses `MODEL_BALANCED` from config
- **`-p, --premium`**: Uses `MODEL_PREMIUM` from config
- **Legacy `-s, --sonnet`**: Maps to `MODEL_BALANCED` (with deprecation warning)
- **Legacy `-o, --opus`**: Maps to `MODEL_PREMIUM` (with deprecation warning)

This abstraction allows users to change underlying models without changing their usage patterns.

## Core Architecture

### Main Script: `aiexec`
The entire application is a single bash script (E:\Archivio\Sviluppo\Scripts\aiexeccli\aiexec) that provides four operational modes:

1. **Simple Mode** (`ai` alias): Generates command without execution (always safe) + auto-copy to clipboard
2. **Exec Mode** (`aix` alias): Generates and auto-executes command with blacklist protection
3. **Explore Mode** (`aie` alias): Executes command and provides intelligent analysis of results
4. **Chat Mode** (`aic` alias): Direct AI conversation without command generation

### Key Components

#### Context System (Lines 174-179)
The `load_context()` function automatically loads context from `~/.aiexec/context.txt` if present:
- Maximum 2000 characters (truncated with `head -c 2000`)
- Silently skips if file doesn't exist
- Context is prepended to all prompts in all modes (simple, exec, explore, chat)
- Useful for project-specific information or common instructions

#### Clipboard System (Lines 181-201)
The `copy_to_clipboard()` function implements multi-platform clipboard support with fallback chain:
- **Primary**: `xclip -selection clipboard` (X11)
- **Fallback 1**: `wl-copy` (Wayland)
- **Fallback 2**: `xsel --clipboard` (X11 alternative)
- Returns 0 on success, 1 if no clipboard tool available
- Automatically used in simple mode unless `--no-clipboard` flag is set
- Shows colorized notification on success/failure

#### Security System (Lines 90-177)
The `is_dangerous()` function implements a two-level blacklist system:
- **BLOCK_PAT**: Catastrophic patterns that are completely blocked (e.g., `rm -rf /`, fork bombs, disk formatting, `curl | bash`)
- **ASK_PAT**: Risky patterns that require user confirmation (e.g., `find / -delete`, recursive chmod/chown on /, mass kill, reboot/shutdown)

The function returns:
- 0: Safe command
- 1: Requires confirmation (ASK)
- 2: Blocked command (BLOCK)

#### Command Cleaning (Lines 60-75)
The `clean_cmd()` function sanitizes Claude's output by:
- Extracting first line only
- Removing backticks, markdown code blocks
- Trimming spaces and prompt symbols (`#`, `$`, `>`)
- Removing bash -c / sh -c wrappers

#### Confirmation/Blocking (Lines 77-88)
The `confirm_or_block()` function handles security violations:
- BLOCK: Shows error and suggests using `--force` flag, exits with code 2
- ASK: Prompts user for y/N confirmation before proceeding

#### Smart Mode Auto-Detection (Lines 221-330)
The `should_use_smart_mode()` function automatically detects complex prompts in explore mode (`aie`) and offers to switch to balanced tier + thinking for better analysis via an interactive toggle prompt.

**Scoring System (threshold ≥2):**
- **Length** (+1): Prompt >150 characters
- **Keywords** (+1 or +2): Italian/English complexity keywords with flexible patterns
  - IT: analiz[zs][aie], debug, spieg[ah], perch[eé], problem[ai], error[ei], crash, trov[aio], cerc[ah], etc.
  - EN: analyz[ei], explain, why, troubleshoot, diagnos[ei], identif[yi], solv[ei], check, inspect, find, search, detect, slow, issue, bug, fail, etc.
  - Max 2 points: 1 match = +1, 2+ matches = +2
- **Complex Terms** (+1 or +2): Technical commands and concepts
  - awk, sed, regex, grep -E, find.*-exec, database, sql, network, tcp, socket, docker, kubernetes, systemctl, journalctl, etc.
  - Max 2 points: 1 match = +1, 2+ matches = +2
- **Multi-step** (+1): Sequential operation indicators (Italian/English)
  - IT: "e poi", "dopo", "se .* allora", "quindi .* e", "prima .* poi"
  - EN: "and then", "after", "if .* then", "first .* then"

**Interactive Prompt (`prompt_thinking_mode()`):**
When complexity is detected, shows an interactive toggle prompt:
```
🧠 Complexity detected. Use thinking mode (balanced tier + thinking)?
   [ ] YES    [●] NO    (Spacebar: toggle | Enter: confirm)
```
- **Default: NO** (fast tier mode, green [●] on NO)
- **Spacebar**: Toggle between YES/NO
- **Enter**: Confirm selection
- **ESC**: Cancel (treated as NO)

**Behavior:**
- Only triggers when `MODE="explore"` and `AI_AIE_AUTO_SMART=true` (default)
- Only activates if user hasn't explicitly set model (`-b`, `-p`, `-m`) or thinking (`-t`)
- User confirmation required before switching models
- Shows result: "✅ Thinking mode activated" or "⚡ Continuing with fast mode"
- Can be disabled via config: `AI_AIE_AUTO_SMART=false`

**Examples:**
- ✅ "analizza i log per trovare gli errori" → ASKS (IT keywords: analizza + errori)
- ✅ "analyze the logs to find errors" → ASKS (EN keywords: analyze + errors)
- ✅ "debug performance issue in database" → ASKS (EN keywords + database)
- ✅ "ottimizza le performance del database" → ASKS (IT keywords + database)
- ✅ Long prompt (>150 chars) with complexity keyword → ASKS
- ❌ "usa awk" / "use awk" → SILENT (only 1 indicator, needs ≥2)
- ❌ "mostra i file" / "show files" → SILENT (simple request)

### Execution Modes

#### Simple Mode (Lines 259-270)
- Generates command using Claude Code via `ask_command()`
- Optionally cleans output (unless `--raw` flag used)
- Shows warning for dangerous commands but never blocks
- Returns command string for manual execution

#### Exec Mode (Lines 272-294)
- Generates command via `ask_command()`
- Checks blacklist (unless `--force` used)
- Supports dry-run mode (`--dry-run`)
- Executes directly with `bash -lc` to preserve login shell environment
- Exits with the command's exit code

#### Explore Mode (Lines 272-338)
- Generates and executes command
- Creates temporary file with `mktemp` to capture stdout and stderr
- Displays command output and exit code
- Sends output (truncated to 4000 chars) to Claude for intelligent analysis
- Analysis language configurable via `AI_RESPONSE_LANG` environment variable (default: English)
- Cleans up temporary file after analysis

#### Chat Mode (Lines 690-694)
- New mode for direct AI conversation without command generation
- Calls `ask_ai()` function (Lines 523-548)
- Loads context from `~/.aiexec/context.txt` if present
- No command cleaning (raw AI response)
- No blacklist checks (not generating commands)
- Supports all model flags (-t, -b, -p, -m)
- Use case: Ask questions, get explanations, general AI assistance

## Configuration

### Flags and Options
The script supports multiple flags (parsed in lines 441-459):
- `-t, --thinking`: Enable extended thinking mode
- `-b, --balanced`: Use balanced tier model (from config)
- `-p, --premium`: Use premium tier model (from config)
- `-m, --model <name>`: Specify custom model name
- `-f, --force`: Bypass blacklist checks (DANGEROUS)
- `-r, --raw`: Don't clean Claude's output
- `-n, --dry-run`: Show what would run without executing (for aix/aie)
- `--no-clipboard`: Disable automatic clipboard copy in simple mode
- `-h, --help`: Display help message
- `--install-aliases`: Create symlinks for ai/aix/aie/aic
- **Legacy**: `-s, --sonnet` and `-o, --opus` (deprecated, map to balanced/premium with warning)

### Model Selection (Tier-Based)
The script uses a tier-based model selection system (aiexec:422-428):
1. **Default tier**: Determined by `DEFAULT_MODEL_TIER` config (default: "fast")
2. **Fast tier**: Uses `MODEL_FAST` from config (default: claude-haiku-4-5-20251001)
3. **Balanced tier** (`-b`): Uses `MODEL_BALANCED` from config (default: claude-sonnet-4-5-20250929)
4. **Premium tier** (`-p`): Uses `MODEL_PREMIUM` from config (default: claude-opus-4-1-20250805)
5. **Custom model** (`-m`): Directly specify any model name

The selected model is passed to Claude Code via `--model` flag.

### Extended Thinking
- Default: disabled (`DEFAULT_THINKING="false"` at line 10)
- `-t/--thinking`: enables extended thinking for complex problems
- Implemented by modifying the system prompt to disable chain-of-thought when not needed (lines 236-239)

### Custom Blacklist Extensions
Users can extend the blacklist via environment variable:
```bash
export AI_BLACKLIST_EXTRA="pattern1|pattern2"
```

This gets appended to ASK_PAT array at runtime (line 161).

### Smart Mode Auto-Detection Control
Control automatic smart mode detection for explore mode:
```bash
export AI_AIE_AUTO_SMART=true   # Enable (default)
export AI_AIE_AUTO_SMART=false  # Disable
```

When enabled, explore mode (`aie`) automatically uses balanced tier + thinking for complex prompts based on heuristic analysis. Manual model/thinking flags (`-b`, `-p`, `-m`, `-t`) always override auto-detection.

### AI Response Language
Configure the language for AI-generated analysis reports in explore mode:
```bash
export AI_RESPONSE_LANG="English"  # Default
export AI_RESPONSE_LANG="Italian"  # Italian responses
export AI_RESPONSE_LANG="Spanish"  # Spanish responses
# ... any language supported by Claude
```

This environment variable controls the language of analysis reports generated by the `aie` (explore) command. When set to a language other than English, the AI will be instructed to respond in that language. All command generation prompts and user-facing messages remain in English regardless of this setting.

### Context File System
The script supports automatic context loading from a fixed file location:

**Location**: `~/.aiexec/context.txt`

**Behavior**:
- If the file exists, its content is automatically prepended to all AI prompts
- Applies to all modes: simple, exec, explore, and chat
- Content is limited to 2000 characters (truncated with `head -c 2000`)
- If file doesn't exist, operation continues silently (no error)
- Loaded by `load_context()` function (aiexec:174-179)

**Use Cases**:
- Project-specific information (e.g., "This is a Django project using PostgreSQL")
- Common instructions or preferences
- Standard library imports or conventions
- Environment-specific details

**Example**:
```bash
echo "This is a Python project using FastAPI and SQLAlchemy" > ~/.aiexec/context.txt
ai "create a new user endpoint"  # Context automatically included
```

### Clipboard Integration
Simple mode (`ai`) automatically copies generated commands to the clipboard for convenience:

**Implementation** (aiexec:181-201):
- Multi-platform support with intelligent fallback
- **Linux X11**: Uses `xclip -selection clipboard`
- **Linux Wayland**: Uses `wl-copy`
- **Linux fallback**: Uses `xsel --clipboard`
- Returns success/failure status with colorized notification

**Behavior**:
- Enabled by default in simple mode only
- Disabled with `--no-clipboard` flag
- Shows `✓ Command copied to clipboard` on success (green)
- Shows warning if no clipboard tool available (yellow)
- Does NOT apply to exec, explore, or chat modes

**Requirements**:
- At least one clipboard tool must be installed: `xclip`, `wl-copy`, or `xsel`
- Install with: `sudo apt install xclip` (or `wl-clipboard` for Wayland)

## Testing and Development

### Manual Testing
Test the script directly without installation:
```bash
./aiexec simple "list files"
./aiexec exec "echo test"
./aiexec explore "show disk usage"
./aiexec chat "what is a symbolic link"
```

### Testing with Flags
```bash
./aiexec simple -t "complex task"        # With thinking
./aiexec exec -b "advanced command"      # With balanced tier
./aiexec explore -p "very complex task"  # With premium tier
./aiexec chat -b "explain bash arrays"   # Chat with balanced tier
```

### Testing Security Features
```bash
./aiexec exec "rm -rf /"                 # Should BLOCK
./aiexec exec "find / -delete"           # Should ASK
./aiexec exec --force "risky command"    # Bypasses blacklist
```

### Testing Context File
```bash
# Create context file
echo "This is a test project using Python and FastAPI" > ~/.aiexec/context.txt

# Test context loading in different modes
./aiexec simple "create a hello world endpoint"  # Should use context
./aiexec chat "what frameworks am I using"       # Should know from context

# Verify context is included
./aiexec simple --raw "test" | grep -i "fastapi"  # Should contain context

# Clean up
rm ~/.aiexec/context.txt
```

### Testing Clipboard Integration
```bash
# Test clipboard copy (requires xclip/wl-copy/xsel)
./aiexec simple "echo hello"
# Should show: ✓ Command copied to clipboard
# Verify with: xclip -o  (or wl-paste / xsel -o)

# Test --no-clipboard flag
./aiexec simple --no-clipboard "echo test"
# Should NOT show clipboard notification

# Test without clipboard tool (simulate)
PATH=/usr/bin:/bin ./aiexec simple "test"
# Should show warning about missing clipboard tool
```

### Verifying Command Cleaning
```bash
./aiexec simple --raw "test"    # Shows uncleaned output
./aiexec simple "test"          # Shows cleaned output
```

### Testing Smart Mode Auto-Detection
```bash
# Complex prompts that trigger interactive prompt (Italian & English)
./aiexec explore "analizza i log per trovare gli errori"
./aiexec explore "analyze the logs to find errors"
./aiexec explore "debug performance issue in database"
# → Shows toggle prompt, default NO, spacebar to change, Enter to confirm

# Simple prompts that DON'T trigger prompt (use fast tier silently)
./aiexec explore "mostra i file"
./aiexec explore "show files"
./aiexec explore "ls"

# Manual override prevents auto-detection prompt
./aiexec explore -b "analizza i log"  # Uses balanced tier, no prompt shown
./aiexec explore -t "mostra i file"   # Uses fast tier + thinking, no prompt shown

# Disable auto-detection entirely
AI_AIE_AUTO_SMART=false ./aiexec explore "analizza i log"  # Silent, uses fast tier
```

### Running the Test Suite
The project includes comprehensive tests in `tests.sh`:
```bash
bash tests.sh
```

Tests cover:
- Security blacklist patterns (BLOCK and ASK)
- Pattern precedence
- Safe command detection (no false positives)
- Smart mode auto-detection heuristics (Italian & English keywords, 76 total tests)

## Installation

### Installation Script
The `install.sh` script performs:
1. Installs Claude Code via `curl -fsSL https://claude.ai/install.sh | bash` if not present
2. Runs `claude doctor` to verify installation
3. Copies `aiexec` to `~/.local/bin/` and makes it executable
4. Creates backup of shell RC file with timestamp
5. Removes old aliases if present (between `# AI Exec aliases` and next empty line)
6. Appends new aliases to `.bashrc` or `.zshrc`:
   - `ai='aiexec simple'` (command generation only)
   - `aix='aiexec exec'` (auto-execute)
   - `aie='aiexec explore'` (execute + analyze)
   - `ait`, `ais`, `aixt`, `aiet` (convenience aliases with flags)
7. Adds `~/.local/bin` to PATH if needed

**Note:** install.sh:3 has a bare `set` command (likely typo) that should be removed or replaced with `set -u` if needed.

### Alternative: Symlink Installation
The script supports `--install-aliases` flag (lines 180-197) which creates symlinks instead of shell aliases:
```bash
./aiexec --install-aliases
```
This creates symlinks in `~/.local/bin/` for `ai`, `aix`, `aie` that point to the main `aiexec` script.

## Important Implementation Details

### Command Generation via Claude Code
The `ask_command()` function calls Claude Code with:
- `--model`: Selected model (from configured tier or custom)
- `--max-turns 1`: Single interaction
- `--output-format text`: Plain text output
- `--append-system-prompt`: Adds instruction for POSIX-compatible command-only output
- English language prompt: "What is the shell command for..."

### Temporary File Handling
Explore mode uses `mktemp` (line 297) to create secure temporary files and ensures cleanup with `rm -f` (line 337).

### Exit Code Preservation
The script uses `set +e` / `set -e` around command execution (lines 298-301) to capture exit codes without terminating the script.

### Environment Preservation
Commands are executed with `bash -lc` (lines 292, 299) to ensure login shell environment is preserved.

### Output Truncation
Analysis mode truncates output to 4000 characters using `head -c 4000` (line 318) to prevent exceeding Claude's context limits.

### Regex Pattern Matching
All blacklist patterns use grep with `-Eiq` flags (lines 165, 171):
- `-E`: Extended regex
- `-i`: Case-insensitive
- `-q`: Quiet (just return status)

### Mode Detection
The script auto-detects operational mode from executable name using `basename "$0"` (lines 206-210):
- `ai` → simple mode
- `aix` → exec mode
- `aie` → explore mode

Can also be specified explicitly as first argument: `./aiexec simple "prompt"`

### Language Configuration
The script uses English for all user-facing messages and AI prompts by default:
- Command generation prompt: "What is the shell command for..." (line 422)
- Analysis prompt in explore mode (lines 488-506)
- Interactive prompts and status messages
- Analysis report language is configurable via `AI_RESPONSE_LANG` environment variable
  - When set to a language other than "English", adds "Respond in <language>." to analysis prompt
  - Allows users to receive analysis reports in their preferred language

## Security Considerations

When modifying the blacklist:
- Test patterns thoroughly as they use extended regex syntax
- Patterns check for command position using `(^|[[:space:];|&])` to avoid matching in strings
- BLOCK_PAT patterns (lines 94-127): Extremely destructive operations that are never allowed
- ASK_PAT patterns (lines 130-157): Risky operations that require user confirmation
- User extensions via `AI_BLACKLIST_EXTRA` are added to ASK_PAT, not BLOCK_PAT

## Common Development Tasks

### Adding New Blacklist Patterns
Edit the `BLOCK_PAT` or `ASK_PAT` arrays in the `is_dangerous()` function (lines 94-157). Use extended regex syntax with proper anchoring.

### Changing Default Model
Modify `DEFAULT_MODEL` variable (line 9) to change the default Claude model.

### Adjusting Output Cleaning
Modify the `clean_cmd()` function (lines 60-75) to add new cleaning rules for Claude's output.

### Modifying Analysis Prompt
Edit the `ANALYSIS_PROMPT` template in explore mode (lines 488-506). The prompt is in English by default. Language of AI responses can be configured via `AI_RESPONSE_LANG` environment variable, which automatically adds language instruction to the prompt when set to a non-English language.
