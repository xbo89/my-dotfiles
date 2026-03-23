# 🍄 My Dotfiles

> 一份让终端变好看、好用的配置文件集合。支持一键安装，换新电脑也不怕。

---

## ✨ 包含什么

| 工具 | 说明 |
|------|------|
| 🖥️ **Ghostty** | 终端模拟器配置 + Catppuccin Mocha 主题 |
| 🌟 **Starship** | 命令行提示符（显示 git 状态、语言版本等） |
| 🪟 **tmux** | 终端分屏工具 + Catppuccin 主题 |
| 🪟 **Zellij** | 另一款终端分屏工具 + Catppuccin Mocha 主题 |
| 📝 **Neovim** | 代码编辑器（LazyVim 配置） |
| 🐚 **Zsh** | Shell 配置，包含常用别名和工具初始化 |

所有主题统一使用 [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) 🎨

---

## 🚀 在新电脑上快速安装

> 💡 **提示**：以下步骤需要在终端（Terminal）中操作。Mac 自带的终端叫 **Terminal**，在应用程序 → 实用工具里可以找到。

### 第一步：安装 Ghostty 终端

推荐先安装 [Ghostty](https://ghostty.org)，这份 dotfiles 的终端配置是基于它的。

下载安装后打开 Ghostty，后续所有操作都在 Ghostty 里进行。

### 第二步：克隆这份配置到本地

在终端里输入以下命令，把配置文件下载到你的电脑：

```bash
git clone --recurse-submodules https://github.com/xbo89/my-dotfiles.git ~/dotfiles
```

> 💡 这会在你的主目录（`~`）下创建一个叫 `dotfiles` 的文件夹。

### 第三步：运行一键安装脚本

```bash
cd ~/dotfiles
chmod +x bootstrap.sh
./bootstrap.sh
```

脚本会自动帮你完成以下所有事情：

- ✅ 安装 Homebrew（Mac 的软件包管理器）
- ✅ 安装所有命令行工具
- ✅ 卸载 Oh My Zsh（如果有的话）
- ✅ 安装 nvm（Node.js 版本管理器）
- ✅ 初始化所有插件（tmux 主题等）
- ✅ 自动关联所有配置文件
- ✅ 检测 Ghostty 配置冲突并提示

> ⏱️ 第一次安装大约需要 5–10 分钟，取决于网速。

### 第四步：重载配置

安装完成后，运行：

```bash
source ~/.zshrc
```

### 第五步：安装 Node.js

```bash
nvm install --lts
```

### 第六步：启动 Neovim 安装插件

```bash
nvim
```

第一次打开会自动下载安装所有插件，等待完成即可（大约 1–2 分钟）。

---

## 🔧 Ghostty 配置说明

安装完成后，如果 Ghostty 的主题没有生效，可能是因为 Ghostty 自己的配置文件覆盖了 dotfiles 的配置。

打开以下路径的文件：

```
~/Library/Application Support/com.mitchellh.ghostty/config
```

> 💡 在 Finder 里按 `Cmd + Shift + G`，粘贴上面的路径即可打开。

把文件里所有内容注释掉（在每行开头加 `#`），保存后重启 Ghostty 即可。

---

## 🔄 日常更新

### 更新这份 dotfiles

```bash
cd ~/dotfiles
git pull
git submodule update --remote
```

### 更新所有 brew 工具

```bash
brew update && brew upgrade
```

---

## 🛠️ 手动关联某个配置

如果某个工具的配置没有生效，可以手动重新关联：

```bash
cd ~/dotfiles
stow -d ~/dotfiles -t ~ ghostty   # Ghostty
stow -d ~/dotfiles -t ~ starship  # Starship
stow -d ~/dotfiles -t ~ tmux      # tmux
stow -d ~/dotfiles -t ~ zellij    # Zellij
stow -d ~/dotfiles -t ~ nvim      # Neovim
stow -d ~/dotfiles -t ~ zshrc     # Zsh
```

---

## 📦 包含的命令行工具

| 工具 | 用途 |
|------|------|
| `exa` | 更好看的 `ls` 命令 |
| `bat` | 更好看的 `cat` 命令（带语法高亮） |
| `fzf` | 模糊搜索 |
| `zoxide` | 智能 `cd`，自动记忆常用目录 |
| `atuin` | 更强大的命令历史搜索 |
| `yazi` | 终端文件管理器 |
| `lazygit` | 终端里的 Git 图形界面 |
| `lazydocker` | 终端里的 Docker 图形界面 |
| `ripgrep` | 超快的文件内容搜索 |
| `starship` | 漂亮的命令行提示符 |

---

## ❓ 常见问题

**Q: 命令找不到（command not found）**

重新加载一下配置：
```bash
source ~/.zshrc
```

**Q: tmux 主题没有生效**

在 tmux 里按 `Ctrl+b` 然后输入 `:source ~/.config/tmux/tmux.conf`

**Q: 安装脚本报错了怎么办**

把报错信息截图或复制下来，查一下具体是哪一步出了问题，通常重新运行一次就能解决。

---

## 🎨 主题

所有工具统一使用 [Catppuccin Mocha](https://github.com/catppuccin/catppuccin)，一个深色、护眼、颜值高的主题。

---

<p align="center">Made with ☕ and 🎨</p>
