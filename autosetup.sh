#!/bin/bash
# 系统基础配置、speedtest、eza、btop 和 doggo 的安装与配置脚本。

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 用户或使用 sudo 运行此脚本。"
  exit 1
fi

echo "=========================================="
echo "🎯 阶段 1: 检查和安装核心依赖"
echo "=========================================="
apt update
# 安装通用工具，包括 wget, curl, jq, git, vim 等
apt install -y net-tools dnsutils mtr git unzip zip wget curl vnstat lsof iptables lrzsz xz-utils openssl gawk file bzip2 ntpsec-ntpdate jq vim 

# 确保 wget 或 curl 可用
DOWNLOADER=""
if command -v curl &> /dev/null; then
    DOWNLOADER="curl -sSL"
elif command -v wget &> /dev/null; then
    DOWNLOADER="wget -qO-"
else
    echo "❌ 错误: 找不到 'curl' 或 'wget'。无法继续下载安装。"
    exit 1
fi

echo "=========================================="
echo "⚙️ 阶段 2: 基础系统配置和优化"
echo "=========================================="

# 清理可能导致 apt update 报 402 Payment Required 错误的失效 Speedtest 仓库
rm -f /etc/apt/sources.list.d/ookla_speedtest-cli.list

# 系统更新
apt upgrade -y 

# 禁用休眠/挂起功能 (使用 printf 避免 heredoc 结束符报错)
mkdir -p /etc/systemd/sleep.conf.d
printf '[Sleep]\nAllowSuspend=no\nAllowHibernation=no\nAllowSuspendThenHibernate=no\nAllowHybridSleep=no\n' > /etc/systemd/sleep.conf.d/nosuspend.conf

# 设置时区
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
# 同步时间
ntpdate ntp.aliyun.com 
# rsyslog 和 cron 配置
sed -i 's/#\(cron.*\)/\1/' /etc/rsyslog.conf && service rsyslog restart && service cron restart 
# 增加历史记录大小
sed -i 's/HISTSIZE=1000/HISTSIZE=10000/g' /etc/profile && source /etc/profile 
# 下载 ipt.sh 和 .bashrc
wget -O /usr/bin/ipt.sh https://raw.githubusercontent.com/hpcex/misc/main/ipt.sh && chmod +x /usr/bin/ipt.sh 
wget -O /root/.bashrc https://raw.githubusercontent.com/hpcex/misc/main/.bashrc 
# 安装 nexttrace
bash <(curl -Ls https://raw.githubusercontent.com/sjlleo/nexttrace/main/nt_install.sh) 

# 安装 speedtest (使用官方二进制直接下载或 Debian 源，避开 Packagecloud 402 错误)
echo "⬇️ 正在安装 Speedtest..."
if apt install -y speedtest-cli 2>/dev/null; then
    echo "🎉 speedtest-cli 安装完成！"
else
    ST_ARCH=$(uname -m)
    if [ "$ST_ARCH" = "x86_64" ]; then
        curl -sSL https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-x86_64.tgz | tar -xz -C /usr/local/bin speedtest 2>/dev/null
    elif [ "$ST_ARCH" = "aarch64" ]; then
        curl -sSL https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-aarch64.tgz | tar -xz -C /usr/local/bin speedtest 2>/dev/null
    fi
    chmod +x /usr/local/bin/speedtest 2>/dev/null
    echo "🎉 Speedtest 官方二进制版本安装完成！"
fi

# 替换 vim 配置
rm -f /etc/vim/vimrc.tiny
apt remove vim-tiny -y
wget -O /root/.vimrc https://raw.githubusercontent.com/hpcex/misc/main/.vimrc 


echo "=========================================="
echo "📁 阶段 3: 安装 eza"
echo "=========================================="

apt install -y gpg
mkdir -p /etc/apt/keyrings
# 加 --yes 参数避免已存在密钥时弹出交互性提示
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --yes --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list
apt update
apt install -y eza

echo "=========================================="
echo "📊 阶段 4: 安装 btop"
echo "=========================================="

# 优先尝试使用 apt 安装（Debian 12 已内置 btop）
if apt install -y btop 2>/dev/null; then
    echo "🎉 btop 通过 apt 安装成功！"
else
    ARCH=$(uname -m)
    DOWNLOAD_URL=""
    FILENAME="btop.tbz"
    INSTALL_PATH="/usr/local/sbin/"
    TEMP_DIR="/tmp/btop_install"

    if [ "$ARCH" = "aarch64" ]; then
        echo "✅ 检测到架构: ARM64 (aarch64)。"
        DOWNLOAD_URL="https://github.com/aristocratos/btop/releases/latest/download/btop-aarch64-linux-musl.tbz"
    elif [ "$ARCH" = "x86_64" ]; then
        echo "✅ 检测到架构: AMD64 (x86_64)。"
        DOWNLOAD_URL="https://github.com/aristocratos/btop/releases/latest/download/btop-x86_64-linux-musl.tbz"
    else
        echo "❌ 警告：btop 不支持的系统架构 ($ARCH)，跳过安装。"
    fi

    if [ -n "$DOWNLOAD_URL" ]; then
        mkdir -p "$TEMP_DIR"
        echo "⬇️ 正在下载 btop..."
        if curl -sSL -o "$TEMP_DIR/$FILENAME" "$DOWNLOAD_URL" || wget -qO "$TEMP_DIR/$FILENAME" "$DOWNLOAD_URL"; then
            echo "📦 正在安装 btop..."
            tar xjf "$TEMP_DIR/$FILENAME" -C "$TEMP_DIR" 2>/dev/null
            mkdir -p "$INSTALL_PATH"
            if [ -f "$TEMP_DIR/btop/bin/btop" ] && mv "$TEMP_DIR/btop/bin/btop" "$INSTALL_PATH" && chmod +x "$INSTALL_PATH/btop"; then
                echo "🎉 btop 安装成功！路径：$INSTALL_PATH/btop"
            else
                echo "❌ btop 安装失败。"
            fi
        else
            echo "❌ btop 下载失败，跳过安装。"
        fi
        rm -rf "$TEMP_DIR"
        echo "✅ btop 临时文件清理完成。"
    fi
fi


echo "=========================================="
echo "🐶 阶段 5: 安装 doggo"
echo "=========================================="

API_URL="https://api.github.com/repos/mr-karan/doggo/releases/latest"
VERSION=""

# 5.1 获取最新版本号
echo "   正在获取 doggo 最新版本号..."
VERSION=$(curl -s "$API_URL" | jq -r '.tag_name' | sed 's/^v//')

if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
    echo "❌ 严重错误：未能从 GitHub API 获取 doggo 版本号，跳过安装。"
else
    echo "✨ 已自动获取到 doggo 最新版本: v${VERSION}"
    
    # 5.2 自动获取架构并映射
    OS_ARCH=$(uname -m)
    ARCH="" 
    case "${OS_ARCH}" in
        x86_64 | amd64)
            ARCH="x86_64"
            ;;
        aarch64 | arm64)
            ARCH="arm64"
            ;;
        *)
            echo "❌ doggo 不支持或无法识别的系统架构 '${OS_ARCH}'，跳过安装。"
            ;;
    esac

    if [ -n "$ARCH" ]; then
        FILENAME="doggo-linux-${ARCH}.tar.gz"
        URL="https://github.com/mr-karan/doggo/releases/download/v${VERSION}/${FILENAME}"
        TEMP_DIR="/tmp/doggo_install_v${VERSION}_$$"

        echo "   旧的可执行文件已清理。"
        rm -f /usr/local/sbin/dog /usr/local/bin/doggo

        echo "   正在下载和安装 doggo..."
        mkdir -p "${TEMP_DIR}"
        cd "${TEMP_DIR}" || exit 1

        if curl -sSL -o "${FILENAME}" "${URL}" || wget -qO "${FILENAME}" "${URL}"; then
            if tar -xzf "${FILENAME}" 2>/dev/null; then
                DOGGO_BIN=$(find . -name "doggo" -type f | head -n 1)
                if [ -n "$DOGGO_BIN" ]; then
                    mv "$DOGGO_BIN" /usr/local/bin/doggo
                    chmod +x /usr/local/bin/doggo
                    echo "🎉 doggo v${VERSION} 已成功安装到 /usr/local/bin/doggo"
                else
                    echo "❌ doggo 解压后未找到二进制文件。"
                fi
            else
                echo "❌ doggo 压缩包解压失败。"
            fi
        else
            echo "❌ doggo 下载失败，URL可能无效：${URL}"
        fi

        cd /
        rm -rf "${TEMP_DIR}"
        echo "✅ doggo 临时文件清理完成。"
    fi
fi

echo "=========================================="
echo "📝 阶段 6: 设置别名"
echo "=========================================="

# eza 别名 (追加到 /root/.bashrc)
if ! grep -q "alias ls=\"eza" /root/.bashrc 2>/dev/null; then
    echo -e '\nalias ls="eza --icons"\nalias ll="eza --time-style=long-iso --icons --binary -lhg"\nalias tree="eza --tree --icons"' >> /root/.bashrc
    echo "➕ 已将 'eza' 别名添加到 /root/.bashrc"
else
    echo "ℹ️ /root/.bashrc 中已存在 'eza' 别名，跳过写入。"
fi

# doggo 别名 (追加到 /root/.bashrc)
ALIAS_LINE="alias dog='/usr/local/bin/doggo'"
if ! grep -q "$ALIAS_LINE" /root/.bashrc 2>/dev/null; then 
    echo "$ALIAS_LINE" >> /root/.bashrc
    echo "➕ 已将 'alias dog' 添加到 /root/.bashrc"
else
    echo "ℹ️ /root/.bashrc 中已存在 'alias dog'，跳过写入。"
fi

# 刷新 shell 缓存
hash -r
# 重新加载 /root/.bashrc 以在当前会话中生效
source /root/.bashrc 

echo ""
echo "=========================================="
echo "🎉 所有配置和工具安装完成！"
echo "=========================================="
