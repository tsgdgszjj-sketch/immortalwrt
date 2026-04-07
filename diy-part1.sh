#!/bin/bash
# DIY Part 1 - 在 feeds update 之前执行
# 功能：添加第三方 feed 源（Passwall、OpenClash）

set -e

echo ">>> [DIY-1] 添加 Passwall feeds..."
# Passwall 需要两个仓库：核心代理二进制包 + LuCI 界面
cat >> feeds.conf.default << 'FEEDS'
src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main
src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main
FEEDS

echo ">>> [DIY-1] feeds.conf.default 当前内容："
cat feeds.conf.default

echo ">>> [DIY-1] 完成！"
