# Dotfiles

Personal macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
dotfiles/
├── hammerspoon/    # macOS automation & window management
├── tmux/           # Terminal multiplexer
├── vim/            # Vim editor
└── zsh/            # Zsh shell
```

## Installation

```bash
cd ~/dotfiles
stow <package>    # e.g. stow vim, stow zsh
```

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

### Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `src` | `source ~/.zshrc` | Reload shell config |
| `vf` | `vim $(fd . \| fzf)` | Fuzzy-find a file and open in Vim |
| `vz` | `z && vim` | Navigate with zoxide then open Vim |

### Functions

| Function | Usage | Description |
|----------|-------|-------------|
| `d [session]` | `d` or `d work` | SSH to host `d` and attach to a tmux session (defaults to `main`) |

### Local Overrides

Machine-specific config and secrets can be placed in `~/.zshrc.local` — it is sourced automatically if present.
