#!/bin/bash
# DIY Part 1 - 在 feeds update 之前执行
# 功能：添加第三方 feed 源（Passwall）

set -e

echo ">>> [DIY-1] 添加 Passwall feeds..."
# 注意：OpenWrt feeds 脚本不支持 ;branch 语法，直接用仓库 URL
cat >> feeds.conf.default << 'FEEDS'
src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git
src-git passwall https://github.com/xiaorouji/openwrt-passwall.git
FEEDS

echo ">>> [DIY-1] feeds.conf.default 当前内容："
cat feeds.conf.default
echo ">>> [DIY-1] 完成！"
