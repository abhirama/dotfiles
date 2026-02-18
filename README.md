# Dotfiles

Personal macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
dotfiles/
├── claude/         # Global Claude Code instructions
├── hammerspoon/    # macOS automation & window management
├── karabiner/      # Keyboard remapping (Hyper key + word nav)
├── tmux/           # Terminal multiplexer
├── vim/            # Vim editor
└── zsh/            # Zsh shell
```

## Installation

```bash
cd ~/dotfiles
stow <package>    # e.g. stow vim, stow zsh
```

## Claude Code

Global instructions for [Claude Code](https://claude.com/claude-code) that apply to all projects. Symlinks `~/.claude/CLAUDE.md`.

**Rules**:
- Never commit secrets or sensitive information (API keys, tokens, passwords, private keys)
- Python projects: always use a virtual environment and maintain `requirements.txt`

## Vim

Leader key is `Space`. Local leader is `,`.

### Plugins

| Plugin | Purpose |
|--------|---------|
| vim-sensible | Sensible defaults |
| vim-ai | AI-powered code assistance (Google Gemini) |
| vim-ai-provider-google | Gemini provider for vim-ai |
| vim-markdown | Markdown syntax highlighting |
| tabular | Table alignment |
| vim-pencil | Prose optimization |

### Keyboard Shortcuts

#### Pane Navigation

| Shortcut | Action |
|----------|--------|
| `Space + h` | Move to left pane |
| `Space + j` | Move to pane below |
| `Space + k` | Move to pane above |
| `Space + l` | Move to right pane |

#### Split Management

| Shortcut | Action |
|----------|--------|
| `Space + v` | Vertical split |
| `Space + s` | Horizontal split |

#### Blogging

| Shortcut | Action |
|----------|--------|
| `Space + b` | Toggle Blogging Mode (spell check, word count, soft wraps, pencil mode) |
| `Space + ab` | Open AI sidecar session for the current blog post |

#### AI Chat (in `.aichat` files)

| Shortcut | Mode | Action |
|----------|------|--------|
| `Ctrl + s` | Normal | Send chat to AI |
| `Ctrl + s` | Insert | Exit insert mode and send chat to AI |

## Zsh

Framework: [oh-my-zsh](https://ohmyz.sh/) with the `robbyrussell` theme.

### Plugins

| Plugin | Purpose |
|--------|---------|
| git | Git aliases and shortcuts |
| autojump | Fast directory navigation |

### Tools

| Tool | Purpose |
|------|---------|
| [nvm](https://github.com/nvm-sh/nvm) | Node version manager |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter `cd` command |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder |
| [pipx](https://pipx.pypa.io/) | Python app installer |
| [Entire CLI](https://entire.io) | Shell completion via `entire completion zsh` |

### Aliases (defined in `~/.zsh_aliases`)

| Alias | Command | Description |
|-------|---------|-------------|
| `src` | `source ~/.zshrc` | Reload shell config |
| `vf` | `vim $(fd . \| fzf)` | Fuzzy-find a file and open in Vim |
| `vz` | `z && vim` | Navigate with zoxide then open Vim |
| `dpush` | `rsync -avzP ~/do-sync/ d:~/do-sync/` | Push files from local Mac to DigitalOcean |
| `dpull` | `rsync -avzP d:~/do-sync/ ~/do-sync/` | Pull files from DigitalOcean to local Mac |
| `yoclau` | `claude --dangerously-skip-permissions` | Launch Claude Code with dangerously skip permissions |

### Functions

| Function | Usage | Description |
|----------|-------|-------------|
| `d [session]` | `d` or `d work` | SSH to host `d` and attach to a tmux session (defaults to `main`). Sets iTerm2 tab/pane title to session name |
| `d -l` | `d -l` | List active tmux sessions on remote host `d` |

### Cross-Platform Support

The zsh configuration is portable across macOS and Linux. Platform-specific paths (Homebrew, Antigravity) are guarded behind existence checks, and optional tools (`zoxide`, `entire`) are loaded only when available. Use `~/.zshrc.local` for machine-specific overrides.

### Local Overrides

Machine-specific config and secrets can be placed in `~/.zshrc.local` — it is sourced automatically if present.

## Karabiner

Keyboard remapping via [Karabiner-Elements](https://karabiner-elements.pqrs.org/).

### Hyper Key

CapsLock is mapped to `Ctrl+Alt+Cmd+Shift` (the "Hyper" key), used as a modifier for Hammerspoon and Karabiner shortcuts.

### Word Navigation (via Karabiner)

These shortcuts are handled by Karabiner at the HID level (not Hammerspoon) so that iTerm2's Esc+ setting translates them into Meta escape sequences. They are **context-aware** — terminal apps get Meta sequences for readline/TUI compatibility, while other apps (browsers, editors) get macOS-native word navigation.

| Shortcut | Terminal (iTerm2, Terminal) | Other Apps |
|----------|---------------------------|------------|
| `Hyper + b` | `Option+B` (Meta `\eb`, word backward) | `Option+Left` (word backward) |
| `Hyper + w` | `Option+F` (Meta `\ef`, word forward) | `Option+Right` (word forward) |
| `Hyper + d` | `Right`, `Option+B`, `Option+D` (delete word) | `Option+Backspace` (delete word backward) |

### iTerm2 Setup (required)

Set the Left Option key to **Esc+** so that Option+letter produces Meta escape sequences instead of special characters (e.g., `\eb` instead of `∫`):

1. Open **iTerm2 → Preferences** (Cmd+,)
2. Go to **Profiles → Keys**
3. Set **Left Option Key** to **Esc+**

This is required for the Karabiner word navigation shortcuts above. It also enables physical Option+Left/Right/Backspace for word navigation in all terminal apps.

## Tmux

Terminal multiplexer with session persistence. Plugin manager: [TPM](https://github.com/tmux-plugins/tpm) (auto-bootstraps if missing).

### Features

| Feature | Detail |
|---------|--------|
| Default shell | `/bin/zsh` |
| Mouse support | Enabled |
| Scrollback | 10,000 lines |
| Colors | 256-color (`screen-256color`) |

## Hammerspoon

macOS automation and window management. Requires the **Hyper key** (`Ctrl + Alt + Cmd + Shift`), typically mapped to CapsLock via Karabiner or Raycast.

### Vim Navigation (context-aware)

#### In Raycast

| Shortcut | Action |
|----------|--------|
| `Hyper + h` | `Ctrl + h` (navigate left in list) |
| `Hyper + j` | `Ctrl + j` (navigate down in list) |
| `Hyper + k` | `Ctrl + k` (navigate up in list) |
| `Hyper + l` | `Ctrl + l` (navigate right in list) |

#### Global (when Raycast is not visible)

| Shortcut | Action |
|----------|--------|
| `Hyper + h` | Left arrow |
| `Hyper + j` | Down arrow |
| `Hyper + k` | Up arrow |
| `Hyper + l` | Right arrow |

### Window Management (MiroWindowsManager)

| Shortcut | Action |
|----------|--------|
| `Hyper + Up` | Snap window to top half |
| `Hyper + Down` | Snap window to bottom half |
| `Hyper + Left` | Snap window to left half |
| `Hyper + Right` | Snap window to right half |
| `Hyper + f` | Fullscreen window |
| `Hyper + Space` | Move window to next monitor |

### Application Launcher

| Shortcut | Action |
|----------|--------|
| `Hyper + Return` | Toggle Raycast |

### Line Navigation

| Shortcut | Terminal (iTerm2, Terminal) | Other Apps |
|----------|---------------------------|------------|
| `Hyper + a` | `Ctrl+A` (beginning of line) | `Ctrl+A` (beginning of line) |
| `Hyper + e` | `Ctrl+E` (end of line) | `Ctrl+E` (end of line) |
| `Hyper + b` | `Option+B` — word backward (Karabiner) | `Option+Left` — word backward (Karabiner) |
| `Hyper + w` | `Option+F` — word forward (Karabiner) | `Option+Right` — word forward (Karabiner) |
| `Hyper + d` | `Right`, `Opt+B`, `Opt+D` — delete word (Karabiner) | `Option+Backspace` — delete word backward (Karabiner) |
| `Hyper + u` | `Ctrl+U` (delete to beginning of line) | `Cmd+Backspace` (delete to beginning of line) |
| `Hyper + x` | `Ctrl+K` (delete to end of line) | `Ctrl+K` (delete to end of line) |

> **Mnemonic**: **B**ack a word / forward a **W**ord. **D**elete the word. **U**ndo what you typed (wipes left). **X** out the rest (wipes right).

### Utilities

| Shortcut | Action |
|----------|--------|
| `Hyper + v` | Force paste (bypasses paste restrictions) |
| `Hyper + r` | Reload Hammerspoon config |
