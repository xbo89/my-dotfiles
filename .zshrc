# ===================================
# nvm
# ===================================
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ===================================
# pnpm
# ===================================
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

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
export BAT_THEME="Solarized (dark)"
