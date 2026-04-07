#!/bin/bash
# DIY Part 2 - feeds update/install 之后执行
# 通过 git clone 直接引入 Passwall 和 OpenClash，绕过 feeds 网络问题

set -e

echo ">>> [DIY-2] 克隆 passwall-packages..."
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages.git package/passwall-packages

echo ">>> [DIY-2] 克隆 passwall LuCI..."
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall.git package/passwall

echo ">>> [DIY-2] 克隆 OpenClash..."
git clone --depth=1 https://github.com/vernesong/OpenClash.git package/luci-app-openclash

echo ">>> [DIY-2] 设置 first-boot-wizard 执行权限..."
[ -f files/usr/bin/first-boot-wizard.sh ] && chmod +x files/usr/bin/first-boot-wizard.sh

echo ">>> [DIY-2] 完成！"
