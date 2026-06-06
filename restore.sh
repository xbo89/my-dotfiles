#!/bin/bash
#
# restore.sh — 恢复被旧版 bootstrap.sh 误搬走的 ~/.config
#
# 旧版脚本的目录冲突逻辑会在 stow 每个包时把整个 ~/.config 搬进备份目录，
# 导致里面混进了好几份快照（ghostty / tmux / zellij 各搬一次）。
# 本脚本会自动找到最新的备份目录，列出其中所有 .config 快照，
# 挑出“内容最全”的一份（通常是第一次搬走的、含你全部 App 配置的原始版本），
# 在你确认后恢复回 ~/.config。
#
# 用法：  bash restore.sh
#

set -euo pipefail

info()    { echo "  ℹ️  $1"; }
success() { echo "  ✅ $1"; }
warning() { echo "  ⚠️  $1"; }
error()   { echo "  ❌ $1"; }

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🔧 恢复 ~/.config"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. 找到最新的备份目录
LATEST_BACKUP=$(ls -dt "$HOME"/.dotfiles_backup_* 2>/dev/null | head -1 || true)
if [ -z "$LATEST_BACKUP" ]; then
  error "没找到任何 ~/.dotfiles_backup_* 目录，无需恢复（或备份已被清理）。"
  exit 1
fi
info "最新备份目录：$LATEST_BACKUP"
echo ""

# 2. 收集其中所有 .config 快照（.config 或 .config_<时间戳>）
mapfile -t SNAPSHOTS < <(find "$LATEST_BACKUP" -maxdepth 1 -type d -name '.config*' 2>/dev/null)
if [ "${#SNAPSHOTS[@]}" -eq 0 ]; then
  error "备份目录里没有 .config 快照，无法自动恢复。"
  info "请手动检查：ls -la \"$LATEST_BACKUP\""
  exit 1
fi

# 3. 选出条目最多的那一份作为“最全”候选
info "找到以下 .config 快照（按内容多少排序）："
echo ""
BEST=""
BEST_COUNT=-1
# 用临时文件收集 (count, path)，再排序展示
TMP=$(mktemp)
for snap in "${SNAPSHOTS[@]}"; do
  count=$(find "$snap" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l | tr -d ' ')
  printf '%s\t%s\n' "$count" "$snap" >> "$TMP"
done
sort -rn "$TMP" | while IFS=$'\t' read -r count path; do
  printf '     %3s 个顶层条目  %s\n' "$count" "$path"
done
# 取最多的一份
read -r BEST_COUNT BEST < <(sort -rn "$TMP" | head -1 | awk -F'\t' '{print $1, $2}')
rm -f "$TMP"
echo ""
success "推荐恢复：$BEST  （$BEST_COUNT 个顶层条目，含 App 配置最全）"
echo ""

# 4. 预览将要恢复的内容
info "这份快照里的顶层内容："
ls -1 "$BEST" | sed 's/^/       /'
echo ""

# 5. 确认
warning "接下来会：删除当前的 ~/.config（多为半截软链），再把上面这份恢复回去。"
printf "  确认继续？[y/N] "
read -r ans
case "$ans" in
  y|Y|yes|YES) ;;
  *) error "已取消，未做任何改动。"; exit 1 ;;
esac

# 6. 把当前 ~/.config 先挪到一个新的安全位置（不直接删，留个后路）
if [ -e "$HOME/.config" ] || [ -L "$HOME/.config" ]; then
  SAFETY="$HOME/.config.broken_$(date +%Y%m%d_%H%M%S)"
  mv "$HOME/.config" "$SAFETY"
  info "当前 ~/.config 已挪到：$SAFETY（确认无误后可删）"
fi

# 7. 恢复
mv "$BEST" "$HOME/.config"
success "已恢复 ~/.config"
echo ""
info "现在确认你的原有配置都在："
echo "     ls -la ~/.config"
echo ""
success "完成。接着可以重跑修好后的：./bootstrap.sh"
echo ""
