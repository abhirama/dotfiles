# Dotfiles Project

This is a personal macOS dotfiles repository managed with **GNU Stow** for symlink management.

## Project Structure

The repository uses GNU Stow's directory-per-package pattern:

```
dotfiles/
├── hammerspoon/    # Hammerspoon (macOS automation)
├── tmux/           # Tmux terminal multiplexer
├── vim/            # Vim editor
└── zsh/            # Zsh shell
```

Each directory contains dotfiles that Stow will symlink to `~` (home directory).

## Key Components

### Hammerspoon (macOS Automation)

**Purpose**: Advanced macOS automation and window management with custom keyboard shortcuts.

**Key Features**:
- **Hyper Key Setup**: CapsLock mapped to `Ctrl+Alt+Cmd+Shift` (configured via Karabiner or Raycast)
- **Context-Aware Vim Navigation** (`hyper_vim.lua`):
  - In Raycast: `Hyper+hjkl` → `Ctrl+hjkl` (list navigation)
  - Elsewhere: `Hyper+hjkl` → Arrow keys (optional global navigation)
- **Window Management** (via MiroWindowsManager Spoon):
  - `Hyper+Arrows`: Snap windows to screen halves
  - `Hyper+F`: Fullscreen
  - `Hyper+Space`: Move window to next monitor
- **Quick Actions**:
  - `Hyper+Return`: Toggle Raycast
  - `Hyper+V`: Force paste (bypasses paste restrictions)
  - `Hyper+R`: Reload Hammerspoon config

**Spoons**: Uses SpoonInstall for automatic Spoon management (MiroWindowsManager included).

### Vim

**Purpose**: Lightweight Vim configuration with AI-assisted coding.

**Plugin Manager**: vim-plug (auto-installs if missing)

**Plugins**:
- `tpope/vim-sensible`: Sensible defaults
- `madox2/vim-ai`: AI-powered code assistance
- `madox2/vim-ai-provider-google`: Google Gemini integration

**AI Configuration**:
- Provider: Google Gemini
- Model: `gemini-2.5-flash`
- Token stored in `~/.config/gemini.token`
- Config file: `~/.config/vim-ai.ini`

**Editor Settings**: 2-space indentation (tabs → spaces)

### Tmux

**Purpose**: Terminal multiplexer with session persistence.

**Plugin Manager**: TPM (Tmux Plugin Manager) with auto-bootstrap

**Plugins**:
- `tmux-resurrect`: Save/restore tmux sessions
- `tmux-continuum`: Automatic session save/restore

**Features**:
- Mouse support enabled
- 10,000 line scrollback buffer
- 256-color support
- Auto-restores last session on startup

### Zsh

**Purpose**: Shell configuration with productivity enhancements.

**Framework**: oh-my-zsh (robbyrussell theme)

**Plugins**:
- `git`: Git aliases and shortcuts
- `autojump`: Fast directory navigation

**Tools Integrated**:
- **nvm**: Node version manager
- **zoxide**: Smarter cd command
- **fzf**: Fuzzy finder integration
- **pipx**: Python app installer

**Custom Aliases**:
- `src`: Reload `.zshrc`
- `vf`: Open file via fzf in Vim
- `vz`: Navigate with zoxide and open Vim
- `claude`: Launch Claude CLI with Opus planning mode
- `d [session]`: SSH to host 'd' with tmux session (defaults to 'main')

**Local Overrides**: Sources `~/.zshrc.local` for machine-specific configs/secrets

## Installation & Management

### Using GNU Stow

**Install dotfiles**:
```bash
cd ~/dotfiles
stow hammerspoon  # Links ~/.hammerspoon
stow tmux         # Links ~/.tmux.conf
stow vim          # Links ~/.vimrc and ~/.config/vim-ai.ini
stow zsh          # Links ~/.zshrc
```

**Uninstall**:
```bash
stow -D <package>  # Removes symlinks
```

**Restow** (update after changes):
```bash
stow -R <package>
```

### What Gets Ignored

See `.stow-local-ignore`:
- `.git/`, `.gitignore`
- `.claude/`
- `README.md`

See `.gitignore`:
- macOS: `.DS_Store`
- Vim: `*.swp`
- Tmux: Plugin directories (`plugins/`, `resurrect/`, `continuum/`)

## Development Workflow

### Making Changes

1. Edit files in `~/dotfiles/<package>/`
2. Test the changes (configs are symlinked, so changes apply immediately)
3. Commit changes:
   ```bash
   git add <files>
   git commit -m "Description"
   git push
   ```

### Adding New Configurations

1. Create new directory: `mkdir ~/dotfiles/<package>`
2. Add config files (must start with `.` for home directory dotfiles)
3. Stow the package: `stow <package>`
4. Update `.gitignore` and `.stow-local-ignore` as needed

### Hammerspoon Development

- After editing `.hammerspoon/*.lua`, press `Hyper+R` to reload
- Check console for errors: Open Hammerspoon → Console
- Debug logging available for `hyper_vim.lua` module
- **Keybindings reference**: The Hammerspoon section in `README.md` provides a human-readable overview of shortcuts (code in `init.lua` and `hyper_vim.lua` is the source of truth)

### Vim Plugin Updates

```bash
vim +PlugUpdate +qall      # Update all plugins
vim +PlugInstall +qall     # Install new plugins
```

## Important Notes

### For Claude Code

- **Never commit secrets**: Check for `.env`, token files, or credentials before staging
- **Prefer editing over creating**: Edit existing configs rather than creating new files
- **Test before committing**: Configs are live-linked via Stow, so test changes immediately
- **Follow commit patterns**: Check `git log` for commit message style (recent history shows merge commits from feature branches)
- **Keep README.md updated**: When adding, removing, or modifying any config file (`.vimrc`, `.zshrc`, `.tmux.conf`, Hammerspoon configs, etc.), ALWAYS update `README.md` to reflect the changes — including new aliases, keybindings, plugins, tools, or functions

### Platform-Specific

- **macOS only**: This setup is optimized for macOS (Darwin)
- **Hyper key**: Requires external remapping (Karabiner-Elements or Raycast)
- **Hammerspoon**: Needs Accessibility permissions in System Settings

### Dependencies

External tools required:
- GNU Stow (for symlink management)
- Hammerspoon (for macOS automation)
- oh-my-zsh (for Zsh framework)
- Git (for version control)
- Vim (text editor)
- Tmux (terminal multiplexer)

Optional but recommended:
- Karabiner-Elements or Raycast (for Hyper key mapping)
- fzf (fuzzy finder)
- zoxide (smart cd)
- nvm (Node version manager)

## Recent Changes

Based on git history:

1. **Stow Migration** (PR #4): Migrated from manual dotfile management to GNU Stow
2. **Vim AI Integration** (PR #7): Added vim-ai with Google Gemini support
3. **Hammerspoon SpoonInstall** (PR #3): Automated Spoon package management
4. **Tmux Config**: Added with auto-bootstrapping TPM
5. **Raycast Integration**: Hyper+Return hotkey for quick access

## Troubleshooting

### Stow Conflicts

If Stow reports conflicts:
```bash
stow -n <package>  # Dry run to see what would happen
stow -v <package>  # Verbose output
```

Resolve by backing up existing files and re-stowing.

### Hammerspoon Not Working

1. Check Accessibility permissions (System Settings → Privacy & Security)
2. Verify Hyper key mapping in Karabiner or Raycast
3. Check Hammerspoon Console for Lua errors
4. Try `Hyper+R` to reload config

### Vim Plugins Not Loading

```bash
vim +PlugStatus    # Check plugin status
vim +PlugClean     # Remove unused plugins
```

Ensure `~/.vim/autoload/plug.vim` exists (auto-installs on first run).
