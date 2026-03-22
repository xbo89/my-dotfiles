# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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
export BAT_THEME="OneHalfDark"

# ===================================
# zoxide
# ===================================
eval "$(zoxide init zsh)"

# ===================================
# starship
# ===================================
eval "$(starship init zsh)"

# ===================================
# zsh-autosuggestions
# ===================================
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# ===================================
# zsh-syntax-highlighting
# ===================================
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
