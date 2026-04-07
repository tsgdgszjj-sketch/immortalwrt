#!/bin/bash
# DIY Part 1 - feeds update 之前执行
# Passwall 和 OpenClash 通过 diy-part2.sh 的 git clone 方式引入，无需额外 feed
echo ">>> [DIY-1] 使用默认 feeds，第三方包通过 git clone 引入"
cat feeds.conf.default
echo ">>> [DIY-1] 完成！"
