# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$HOME/nand2tetris/tools:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git autojump)

source $ZSH/oh-my-zsh.sh

# Change Ctrl+U from kill-whole-line (zsh default) to backward-kill-line,
# so it only deletes from cursor to beginning of line (complementing Ctrl+K).
bindkey '^U' backward-kill-line

# Custom backward word: lands on the space/delimiter before the word
# instead of on the first character (default Meta-b behavior).
# Used by Hyper+B for word-boundary-aligned navigation.
backward-word-boundary() {
    (( CURSOR == 0 )) && return
    zle backward-word
    (( CURSOR > 0 )) && (( CURSOR-- ))
}
zle -N backward-word-boundary
bindkey '\eb' backward-word-boundary

# Custom forward word: lands on the first space/delimiter after the word
# instead of on the first character of the next word (default Meta-f behavior).
# Used by Hyper+W for word-boundary-aligned navigation.
forward-word-boundary() {
    local len=${#BUFFER}
    (( CURSOR >= len )) && return
    # Phase 1: skip non-word characters (spaces/delimiters)
    while (( CURSOR < len )) && [[ "${BUFFER:$CURSOR:1}" != [[:alnum:]] ]]; do
        (( CURSOR++ ))
    done
    # Phase 2: skip word characters (alphanumeric)
    while (( CURSOR < len )) && [[ "${BUFFER:$CURSOR:1}" == [[:alnum:]] ]]; do
        (( CURSOR++ ))
    done
    # Cursor is now on the first non-alnum char after the word
}
zle -N forward-word-boundary
bindkey '\ef' forward-word-boundary

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

export EDITOR='vim'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Load aliases from dedicated file
[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases

# Lazy-load nvm: defers ~690ms of startup cost until node/npm/npx/nvm is first used
export NVM_DIR="$HOME/.nvm"
function _load_nvm() {
  unfunction nvm node npm npx 2>/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
for cmd in nvm node npm npx; do
  eval "function $cmd() { _load_nvm; $cmd \"\$@\" }"
done

command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

export PATH="$PATH:$HOME/.local/bin"

# Load local overrides & secrets if present
if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi

export PATH="$HOME/bin:$PATH"

# Antigravity (macOS only)
[ -d "$HOME/.antigravity" ] && export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# Homebrew PostgreSQL (macOS only)
[ -d "/usr/local/opt/postgresql@16" ] && export PATH="/usr/local/opt/postgresql@16/bin:$PATH"

# SSH to 'd', attaching to a tmux session (creates if missing). Defaults to 'main'.
# Sets iTerm2 tab/pane title to the session name for easy identification.
# Use -l to list active tmux sessions on the remote host.
function d() {
    if [[ "$1" == "-l" ]]; then
        ssh d tmux list-sessions
        return
    fi
    local session="${1:-main}"
    printf '\e]0;%s\a' "$session"
    ssh -t d tmux new-session -A -s "$session"
}

# Mosh equivalent of d(). Uses mosh for the connection but still uses ssh for
# listing sessions since mosh doesn't support non-interactive commands.
function m() {
    if [[ "$1" == "-l" ]]; then
        ssh d tmux list-sessions
        return
    fi
    local session="${1:-main}"
    printf '\e]0;%s\a' "$session"
    mosh d -- tmux new-session -A -s "$session"
}

# Bidirectional Karabiner config sync.
# Karabiner-Elements overwrites symlinks, so Stow can't manage this config.
# Usage: karabiner-sync         (show diff and choose direction)
#        karabiner-sync push    (dotfiles → karabiner)
#        karabiner-sync pull    (karabiner → dotfiles)
function karabiner-sync() {
    local dotfile=~/dotfiles/karabiner/.config/karabiner/karabiner.json
    local config=~/.config/karabiner/karabiner.json

    if diff -q "$dotfile" "$config" &>/dev/null; then
        echo "Already in sync"
        return
    fi

    local choice="$1"
    if [[ -z "$choice" ]]; then
        diff --color "$dotfile" "$config"
        echo ""
        echo "  push) dotfiles → karabiner"
        echo "  pull) karabiner → dotfiles"
        read "choice?Direction [push/pull]: "
    fi

    case "$choice" in
        push) cp "$dotfile" "$config" && echo "Pushed: dotfiles → karabiner" ;;
        pull) cp "$config" "$dotfile" && echo "Pulled: karabiner → dotfiles" ;;
        *) echo "Aborted" ;;
    esac
}

# Entire CLI shell completion
command -v entire &>/dev/null && source <(entire completion zsh)
