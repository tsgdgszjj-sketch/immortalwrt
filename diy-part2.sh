#!/bin/bash
# DIY Part 2 - feeds update/install 之后执行

set -e

# ── 关键修复：清除 actions/checkout 设置的 credential helper ──────────────
# actions/checkout 会给 git 装认证 helper，会干扰克隆其他公开仓库
git config --global credential.helper ''
git config --global url."https://github.com/".insteadOf git://github.com/
export GIT_TERMINAL_PROMPT=0

echo ">>> [DIY-2] 克隆 passwall-packages..."
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages.git package/passwall-packages

echo ">>> [DIY-2] 克隆 passwall LuCI..."
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall.git package/passwall

echo ">>> [DIY-2] 克隆 OpenClash..."
git clone --depth=1 https://github.com/vernesong/OpenClash.git package/luci-app-openclash

echo ">>> [DIY-2] 设置 first-boot-wizard 执行权限..."
[ -f files/usr/bin/first-boot-wizard.sh ] && chmod +x files/usr/bin/first-boot-wizard.sh

echo ">>> [DIY-2] 完成！"
