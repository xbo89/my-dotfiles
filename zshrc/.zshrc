# ===================================
# Homebrew (static path, no fork)
# ===================================
export HOMEBREW_PREFIX="/opt/homebrew"
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"

# ===================================
# Init script cache
# Regenerates only when the binary changes
# ===================================
_init_cached() {
  local name="$1"; shift
  local cache="$HOME/.zsh_cache/${name}.zsh"
  mkdir -p "$HOME/.zsh_cache"
  if [[ ! -s "$cache" || "$(command -v $name)" -nt "$cache" ]]; then
    "$@" >| "$cache" 2>/dev/null
  fi
  source "$cache"
}

# ===================================
# fnm (Node version manager)
# ===================================
_init_cached fnm fnm env --use-on-cd --shell zsh

# ===================================
# atuin
# ===================================
_init_cached atuin atuin init zsh

# ===================================
# claude
# ===================================
export PATH="$HOME/.local/bin:$PATH"

# ===================================
# pnpm
# ===================================
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# ===================================
# Aliases - zellij
# ===================================
alias zj="zellij"

# ===================================
# Aliases - exa (ls replacement)
# ===================================
alias ls="exa --icons"
alias ll="exa --icons -l"
alias la="exa --icons -la"
alias lt="exa --icons --tree --level=2"

# ===================================
# Aliases - bat (cat replacement)
# ===================================
alias cat="bat"
export BAT_THEME="Catppuccin Frappe"

# ===================================
# zoxide
# ===================================
_init_cached zoxide zoxide init zsh

# ===================================
# starship
# ===================================
_init_cached starship starship init zsh

# ===================================
# zsh-autosuggestions
# ===================================
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# ===================================
# zsh-syntax-highlighting
# ===================================
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ===================================
# Aliases - Git
# ===================================
alias g="git"
alias gs="git status"
alias gp="git push"
alias gl="git pull"
alias glog="git log --oneline --graph --decorate"
alias lg="lazygit"

# ===================================
# Aliases - pnpm
# ===================================
alias pn="pnpm"
alias pnd="pnpm dev"
alias pnb="pnpm build"
alias pni="pnpm install"

# ===================================
# Aliases - System
# ===================================
alias yz="yazi"
alias lzd="lazydocker"
alias reload="source ~/.zshrc"
alias ip="curl -s ifconfig.me"
