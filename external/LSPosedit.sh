#!/bin/bash

# 定义颜色
RED='\033[31m'    # 红色
GREEN='\033[32m'  # 绿色
YELLOW='\033[33m' # 黄色
RESET='\033[0m'   # 重置颜色

# Root权限验证
[ $(id -u) -eq 0 ] || {
    echo -e "${RED}\n必须使用Root权限执行!${RESET}"
    exit 1
}

# 检查 ssh-keygen 是否可用
if ! command -v ssh-keygen >/dev/null 2>&1; then
    echo -e "${RED}\n请使用 MT 管理器扩展包环境执行！${RESET}"
    exit 1
fi

# 默认密钥位置
route="/data/local/tmp/.ssh/"
key="id_ed25519"
KEY_PATH=${route}/${key}

# 定义清理函数 (用于退出时清理)
cleanup() {
    echo -e "\n${YELLOW}正在清理并退出...${RESET}"
    exit 0
}

# 捕获中断信号 (Ctrl+C)
trap cleanup INT TERM

# 输出欢迎信息
echo -e "${GREEN}\n欢迎使用辅助签名脚本\nTG @lsposed0${RESET}\n"

# 主循环控制变量
running=true
while $running; do
    current_time=$(date "+%Y年-%m月-%d日 %H时:%M分:%S秒")
    echo -e "${GREEN}当前时间: ${current_time}${RESET}\n"

    echo -e "${YELLOW}============= 主菜单 =============${RESET}"
    echo -e " 1. 辅助通过验证 (生成密钥并签名)"
    echo -e " 0. 退出脚本"
    echo -e "${YELLOW}==================================${RESET}"
    echo -e -n "${GREEN}请输入选项序号: ${RESET}"
    read choice
    echo

    case $choice in
        1)
            START_TIME=$(date +%s)
            echo -e -n "${YELLOW}请输入你 Github 账号邮箱：${RESET} "
            read EMAIL
            mkdir -p "${route}${EMAIL}"
            echo

            ssh-keygen -t ed25519 -C "${EMAIL}" -f "${route}${EMAIL}/${key}" -N "" -q

            echo -e "${GREEN}请将以下内容更新到 Github 中：${RESET}\n"
            cat "${route}${EMAIL}/${key}.pub"
            echo

            echo -e -n "${YELLOW}请输入挑战码: ${RESET} "
            read CHALLENGE_CODE
            echo

            SIGNED_OUTPUT=$(echo -n "${CHALLENGE_CODE}" | ssh-keygen -Y sign -n lsposed -f "${route}${EMAIL}/${key}" 2>&1)
            echo -e "${GREEN}签名结果: ${RESET}${SIGNED_OUTPUT}\n"

            END_TIME=$(date +%s)
            ELAPSED_TIME=$((END_TIME - START_TIME))
            echo -e "${GREEN}选项1运行完成，总耗时: ${ELAPSED_TIME} 秒\n${RESET}"
            ;;

        0)
            echo -e "${GREEN}感谢使用，正在终止进程...${RESET}"
            running=false
            sleep 1
            exit 0
            ;;

        *)
            echo -e "${RED}输入错误: 无效的选项序号，请重新输入！${RESET}"
            ;;
    esac

    echo -e "\n${YELLOW}----------------------------------${RESET}\n"
done

cleanup
