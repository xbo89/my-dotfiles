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
header "1/10 🔧 Xcode Command Line Tools"
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
header "2/10 🍺 Homebrew"
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
header "3/10 📦 Brew Packages"
info "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"
success "All packages ready"

# ------------------------------------------------
# 4. Uninstall Oh My Zsh
# ------------------------------------------------
header "4/10 🧹 Oh My Zsh"
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
# 5. Node.js via fnm
# ------------------------------------------------
header "5/10 📦 Node.js (fnm)"
if command -v fnm &>/dev/null; then
  info "Installing Node.js LTS..."
  fnm install --lts
  fnm default lts-latest
  eval "$(fnm env --shell bash)"
  fnm use default
  success "Node.js $(node -v) ready"
else
  warning "fnm not found, skipping (will be installed via brew above)"
fi

# ------------------------------------------------
# 6. Claude Code
# ------------------------------------------------
header "6/10 🤖 Claude Code"
if command -v node &>/dev/null; then
  if command -v claude &>/dev/null; then
    info "Updating Claude Code..."
    npm update -g @anthropic-ai/claude-code &>/dev/null
    success "Claude Code $(claude --version) ready"
  else
    info "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code &>/dev/null
    success "Claude Code $(claude --version) installed"
  fi
else
  warning "node not found, skipping Claude Code install"
fi

# ------------------------------------------------
# 7. bat Catppuccin theme
# ------------------------------------------------
header "7/10 🦇 bat Catppuccin Frappé Theme"
BAT_THEME_DIR="$(bat --config-dir)/themes"
BAT_THEME_FILE="$BAT_THEME_DIR/Catppuccin Frappe.tmTheme"
mkdir -p "$BAT_THEME_DIR"
if [ ! -f "$BAT_THEME_FILE" ]; then
  info "Downloading Catppuccin Frappé theme for bat..."
  curl -fsSL "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Frappe.tmTheme" \
    -o "$BAT_THEME_FILE"
  bat cache --build &>/dev/null
  success "bat Catppuccin Frappé theme installed"
else
  success "Already installed"
fi

# ------------------------------------------------
# 7. git submodules
# ------------------------------------------------
header "8/10 🔗 Git Submodules"
if [ -f "$DOTFILES_DIR/.gitmodules" ]; then
  cd "$DOTFILES_DIR"
  git submodule update --init --recursive
  success "Submodules initialized"
else
  warning "No .gitmodules found, skipping"
fi

# ------------------------------------------------
# 8. stow
# ------------------------------------------------
header "9/10 🔗 Stowing Dotfiles"

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
# 9. Ghostty Library config notice
# ------------------------------------------------
header "10/10 👻 Ghostty"
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
echo ""

if [ "$BACKED_UP" = true ]; then
  echo "  📁 Conflicting files backed up to:"
  echo "     $BACKUP_DIR"
  echo ""
fi
