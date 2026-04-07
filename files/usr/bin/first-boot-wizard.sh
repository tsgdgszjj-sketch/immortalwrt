#!/bin/sh
# ImmortalWrt 首次启动 IP 设置向导
# 在系统第一次启动时弹出交互式菜单，设置 LAN IP 后才继续启动

SETUP_FLAG="/etc/config/.setup_complete"
WIZARD_LOG="/tmp/first-boot-wizard.log"

# ──────────────────────────────────────────────────
# 如果已经配置过，直接跳过
# ──────────────────────────────────────────────────
[ -f "$SETUP_FLAG" ] && exit 0

# ──────────────────────────────────────────────────
# 等待控制台就绪（系统日志输出完毕后再显示菜单）
# ──────────────────────────────────────────────────
sleep 3

# 强制绑定到控制台 I/O
exec </dev/console >/dev/console 2>&1

# ──────────────────────────────────────────────────
# 辅助函数：输入校验
# ──────────────────────────────────────────────────
validate_ip() {
    local ip="$1"
    echo "$ip" | grep -qE \
        '^([0-9]{1,3}\.){3}[0-9]{1,3}$' || return 1
    local IFS=.
    set -- $ip
    for octet; do
        [ "$octet" -le 255 ] || return 1
    done
    return 0
}

validate_mask() {
    local mask="$1"
    case "$mask" in
        255.255.255.0|255.255.0.0|255.0.0.0|\
        255.255.255.128|255.255.255.192|255.255.255.224|\
        255.255.254.0|255.255.252.0)
            return 0 ;;
        *)
            validate_ip "$mask" && return 0 || return 1 ;;
    esac
}

print_banner() {
    echo ""
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║         ImmortalWrt  首次启动配置向导                ║"
    echo "║         First Boot Setup Wizard                      ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo ""
    echo "  本向导将帮助您设置路由器的 LAN IP 地址。"
    echo "  直接按 Enter 使用括号内的默认值。"
    echo ""
}

# ──────────────────────────────────────────────────
# 主流程
# ──────────────────────────────────────────────────
print_banner

# 读取当前配置作为默认值
CURRENT_IP=$(uci get network.lan.ipaddr 2>/dev/null || echo "192.168.1.1")
CURRENT_MASK=$(uci get network.lan.netmask 2>/dev/null || echo "255.255.255.0")
CURRENT_HOST=$(uci get system.@system[0].hostname 2>/dev/null || echo "ImmortalWrt")

# ── 步骤 1：LAN IP ──────────────────────────────
while true; do
    printf "  [1/4] LAN IP 地址 [%s]: " "$CURRENT_IP"
    read NEW_IP
    [ -z "$NEW_IP" ] && NEW_IP="$CURRENT_IP"
    if validate_ip "$NEW_IP"; then
        break
    else
        echo "      ✗ IP 格式无效，请重新输入（例如 192.168.2.1）"
    fi
done

# ── 步骤 2：子网掩码 ────────────────────────────
while true; do
    printf "  [2/4] 子网掩码 [%s]: " "$CURRENT_MASK"
    read NEW_MASK
    [ -z "$NEW_MASK" ] && NEW_MASK="$CURRENT_MASK"
    if validate_mask "$NEW_MASK"; then
        break
    else
        echo "      ✗ 掩码格式无效，请重新输入（例如 255.255.255.0）"
    fi
done

# ── 步骤 3：网关（可选）───────────────────────────
printf "  [3/4] 默认网关（可选，留空跳过）: "
read NEW_GW

# ── 步骤 4：主机名 ──────────────────────────────
printf "  [4/4] 主机名 [%s]: " "$CURRENT_HOST"
read NEW_HOST
[ -z "$NEW_HOST" ] && NEW_HOST="$CURRENT_HOST"

# ── 确认并应用 ──────────────────────────────────
echo ""
echo "  ┌─────────────────────────────────────┐"
echo "  │  即将应用以下配置：                 │"
printf "  │  LAN IP  : %-25s│\n" "$NEW_IP"
printf "  │  子网掩码: %-25s│\n" "$NEW_MASK"
if [ -n "$NEW_GW" ]; then
    printf "  │  网关    : %-25s│\n" "$NEW_GW"
fi
printf "  │  主机名  : %-25s│\n" "$NEW_HOST"
echo "  └─────────────────────────────────────┘"
echo ""
printf "  确认应用? [Y/n]: "
read CONFIRM
CONFIRM=$(echo "$CONFIRM" | tr '[:upper:]' '[:lower:]')

if [ "$CONFIRM" = "n" ] || [ "$CONFIRM" = "no" ]; then
    echo "  已取消，使用默认配置继续启动..."
    touch "$SETUP_FLAG"
    exit 0
fi

# 应用 UCI 配置
uci set network.lan.ipaddr="$NEW_IP"
uci set network.lan.netmask="$NEW_MASK"
[ -n "$NEW_GW" ] && uci set network.lan.gateway="$NEW_GW"
uci commit network

uci set system.@system[0].hostname="$NEW_HOST"
uci commit system

# 记录配置日志
{
    echo "First boot wizard completed at $(date)"
    echo "LAN IP: $NEW_IP"
    echo "Mask:   $NEW_MASK"
    echo "GW:     ${NEW_GW:-none}"
    echo "Host:   $NEW_HOST"
} > "$WIZARD_LOG"

# 标记已完成（下次启动跳过）
touch "$SETUP_FLAG"

echo ""
echo "  ✓ 配置已保存！"
echo "  ✓ 路由器 IP 地址: http://$NEW_IP"
echo "  ✓ 系统正在继续启动，稍后即可通过浏览器访问管理界面..."
echo ""

# 重启网络服务以应用新 IP
/etc/init.d/network restart &

exit 0
