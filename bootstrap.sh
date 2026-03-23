#!/bin/bash

set -e

DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# ------------------------------------------------
# Helpers
# ------------------------------------------------
info()    { echo "  ℹ️  $1"; }
success() { echo "  ✅ $1"; }
warning() { echo "  ⚠️  $1"; }
step()    { echo ""; echo "👉 $1"; }
header()  { echo ""; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; echo "  $1"; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; }

# ------------------------------------------------
# Start
# ------------------------------------------------
clear
echo ""
echo "  ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗"
echo "  ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝"
echo "  ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗"
echo "  ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║"
echo "  ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║"
echo "  ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝"
echo ""
echo "  🚀 Starting dotfiles bootstrap..."
echo ""

# ------------------------------------------------
# 1. Xcode Command Line Tools
# ------------------------------------------------
header "1/8 🔧 Xcode Command Line Tools"
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode Command Line Tools..."
  xcode-select --install
  warning "Please complete the Xcode CLT installation and re-run this script."
  exit 1
else
  success "Already installed"
fi

# ------------------------------------------------
# 2. Homebrew
# ------------------------------------------------
header "2/8 🍺 Homebrew"
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Load Homebrew into current shell immediately
if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
success "Homebrew ready ($(brew --version | head -1))"

# ------------------------------------------------
# 3. Brew packages
# ------------------------------------------------
header "3/8 📦 Brew Packages"

BREW_PACKAGES=(
  atuin
  bat
  direnv
  exa
  fd
  ffmpeg
  ffmpegthumbnailer
  fzf
  gh
  git
  lazydocker
  lazygit
  lsd
  neovim
  pnpm
  ripgrep
  starship
  stow
  tmux
  tree-sitter
  wget
  yazi
  zellij
  zoxide
  zsh-autosuggestions
  zsh-syntax-highlighting
  cowsay
  rustup-init
)

for pkg in "${BREW_PACKAGES[@]}"; do
  if brew list "$pkg" &>/dev/null; then
    success "$pkg"
  else
    info "Installing $pkg..."
    brew install "$pkg" &>/dev/null && success "$pkg installed"
  fi
done

# ------------------------------------------------
# 4. Uninstall Oh My Zsh
# ------------------------------------------------
header "4/8 🧹 Oh My Zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
  info "Removing Oh My Zsh..."
  rm -rf "$HOME/.oh-my-zsh"
  # Clean up any omz remnants in .zshrc
  if [ -f "$HOME/.zshrc" ] && ! [ -L "$HOME/.zshrc" ]; then
    rm -f "$HOME/.zshrc"
    info "Removed old .zshrc (will be restored by stow)"
  fi
  success "Oh My Zsh removed"
else
  success "Oh My Zsh not present, skipping"
fi

# ------------------------------------------------
# 5. nvm
# ------------------------------------------------
header "5/8 📦 nvm"
if [ ! -d "$HOME/.nvm" ]; then
  info "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
  success "nvm installed"
else
  success "Already installed"
fi

# ------------------------------------------------
# 6. git submodules
# ------------------------------------------------
header "6/8 🔗 Git Submodules"
if [ -f "$DOTFILES_DIR/.gitmodules" ]; then
  cd "$DOTFILES_DIR"
  git submodule update --init --recursive
  success "Submodules initialized"
else
  warning "No .gitmodules found, skipping"
fi

# ------------------------------------------------
# 7. stow
# ------------------------------------------------
header "7/8 🔗 Stowing Dotfiles"

PACKAGES=(ghostty starship tmux zshrc nvim zellij)

mkdir -p "$BACKUP_DIR"
BACKED_UP=false

for pkg in "${PACKAGES[@]}"; do
  if [ ! -d "$DOTFILES_DIR/$pkg" ]; then
    warning "$pkg not found in dotfiles, skipping"
    continue
  fi

  info "Stowing $pkg..."

  # Handle file conflicts
  while IFS= read -r -d '' src; do
    rel="${src#$DOTFILES_DIR/$pkg/}"
    target="$HOME/$rel"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
      warning "Conflict: backing up $target"
      mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
      mv "$target" "$BACKUP_DIR/$rel"
      BACKED_UP=true
    fi
  done < <(find "$DOTFILES_DIR/$pkg" -type f -print0)

  # Handle directory conflicts (e.g. ~/.config/ghostty exists as real dir)
  while IFS= read -r -d '' src_dir; do
    rel_dir="${src_dir#$DOTFILES_DIR/$pkg/}"
    target_dir="$HOME/$rel_dir"

    if [ -d "$target_dir" ] && [ ! -L "$target_dir" ]; then
      warning "Directory conflict: backing up $target_dir"
      mv "$target_dir" "$BACKUP_DIR/$(basename "$target_dir")_$(date +%s)"
      BACKED_UP=true
    fi
  done < <(find "$DOTFILES_DIR/$pkg" -mindepth 1 -maxdepth 1 -type d -print0)

  stow -d "$DOTFILES_DIR" -t "$HOME" "$pkg"
  success "$pkg stowed"
done

# ------------------------------------------------
# 8. Ghostty Library config notice
# ------------------------------------------------
header "8/8 👻 Ghostty"
GHOSTTY_LIB="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
if [ -f "$GHOSTTY_LIB" ]; then
  ACTIVE_LINES=$(grep -v '^\s*#' "$GHOSTTY_LIB" | grep -v '^\s*$' | wc -l | tr -d ' ')
  if [ "$ACTIVE_LINES" -gt 0 ]; then
    warning "Ghostty has active config in Library path:"
    warning "$GHOSTTY_LIB"
    warning "This may override your dotfiles config."
    warning "Consider commenting out its contents."
  else
    success "Ghostty Library config is already commented out"
  fi
else
  success "No conflicting Ghostty Library config found"
fi

# ------------------------------------------------
# Done
# ------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🎉 Bootstrap complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  📋 Next steps:"
echo "     1. source ~/.zshrc"
echo "     2. Run 'nvim' to install LazyVim plugins"
echo "     3. Run 'nvm install --lts' to install Node.js"
echo ""

if [ "$BACKED_UP" = true ]; then
  echo "  📁 Conflicting files backed up to:"
  echo "     $BACKUP_DIR"
  echo ""
fi
