#!/bin/bash

set -e

DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "================================================"
echo " dotfiles bootstrap"
echo "================================================"

# ------------------------------------------------
# 1. Xcode Command Line Tools
# ------------------------------------------------
echo ""
echo "[1/8] Checking Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
  echo "  → Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "  ⚠ Please complete the Xcode CLT installation and re-run this script."
  exit 1
else
  echo "  ✓ Already installed"
fi

# ------------------------------------------------
# 2. Homebrew
# ------------------------------------------------
echo ""
echo "[2/8] Checking Homebrew..."
if ! command -v brew &>/dev/null; then
  echo "  → Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "  ✓ Already installed"
fi

# ------------------------------------------------
# 3. Brew packages
# ------------------------------------------------
echo ""
echo "[3/8] Installing brew packages..."

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
    echo "  ✓ $pkg already installed"
  else
    echo "  → Installing $pkg..."
    brew install "$pkg"
  fi
done

# ------------------------------------------------
# 4. Uninstall Oh My Zsh (if present)
# ------------------------------------------------
echo ""
echo "[4/8] Checking Oh My Zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "  → Removing Oh My Zsh..."
  rm -rf "$HOME/.oh-my-zsh"
  echo "  ✓ Oh My Zsh removed"
else
  echo "  ✓ Oh My Zsh not present"
fi

# ------------------------------------------------
# 5. nvm
# ------------------------------------------------
echo ""
echo "[5/8] Checking nvm..."
if [ ! -d "$HOME/.nvm" ]; then
  echo "  → Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
else
  echo "  ✓ Already installed"
fi

# ------------------------------------------------
# 6. git submodules
# ------------------------------------------------
echo ""
echo "[6/8] Initializing git submodules..."
cd "$DOTFILES_DIR"
git submodule update --init --recursive
echo "  ✓ Submodules initialized"

# ------------------------------------------------
# 7. stow (with conflict handling)
# ------------------------------------------------
echo ""
echo "[7/8] Stowing dotfiles..."

PACKAGES=(ghostty starship tmux zshrc nvim)

mkdir -p "$BACKUP_DIR"

for pkg in "${PACKAGES[@]}"; do
  if [ ! -d "$DOTFILES_DIR/$pkg" ]; then
    echo "  ⚠ $pkg not found in dotfiles, skipping"
    continue
  fi

  echo "  → Stowing $pkg..."

  # Find files that would be created by stow and check for conflicts
  while IFS= read -r -d '' src; do
    # Get relative path from package dir
    rel="${src#$DOTFILES_DIR/$pkg/}"
    target="$HOME/$rel"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "    ⚠ Conflict: $target exists, backing up to $BACKUP_DIR"
      mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
      mv "$target" "$BACKUP_DIR/$rel"
    fi
  done < <(find "$DOTFILES_DIR/$pkg" -type f -print0)

  stow -d "$DOTFILES_DIR" -t "$HOME" "$pkg"
  echo "  ✓ $pkg stowed"
done

# ------------------------------------------------
# 8. LazyVim
# ------------------------------------------------
echo ""
echo "[8/8] Checking LazyVim..."
if [ ! -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
  echo "  → nvim config not found (should be stowed from dotfiles)"
else
  echo "  ✓ nvim config present, LazyVim will auto-install on first launch"
  echo "    Run 'nvim' to complete LazyVim plugin installation"
fi

# ------------------------------------------------
# Done
# ------------------------------------------------
echo ""
echo "================================================"
echo " ✓ Bootstrap complete!"
echo "================================================"
echo ""
echo "Next steps:"
echo "  1. source ~/.zshrc"
echo "  2. Run 'nvim' to install LazyVim plugins"
echo "  3. Run 'nvm install --lts' to install Node.js"
if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR")" ]; then
  echo ""
  echo "  ⚠ Backed up conflicting files to: $BACKUP_DIR"
fi
