#!/bin/bash
# DIY Part 2 - 在 feeds update/install 之后执行
# 功能：克隆额外包、应用自定义配置

set -e

echo ">>> [DIY-2] 克隆 OpenClash（直接放入 package 目录）..."
git clone --depth=1 https://github.com/vernesong/OpenClash.git package/luci-app-openclash

echo ">>> [DIY-2] 设置 files 目录权限..."
# 确保 wizard 脚本可执行（构建时会保留权限）
[ -f files/usr/bin/first-boot-wizard.sh ] && \
    chmod +x files/usr/bin/first-boot-wizard.sh

echo ">>> [DIY-2] 完成！"
