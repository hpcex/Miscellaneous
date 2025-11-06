#!/bin/bash
# 系统基础配置、eza、btop 和 doggo 的安装。

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
# 确保 wget 或 curl 可用 (doggo脚本需要 [cite: 8, 9])
DOWNLOADER=""
if command -v curl &> /dev/null; then
    DOWNLOADER="curl -sSLO"
elif command -v wget &> /dev/null; then
    DOWNLOADER="wget -q"
else
    echo "❌ 错误: 找不到 'curl' 或 'wget'。无法继续下载安装。"
    exit 1
fi

echo "=========================================="
echo "⚙️ 阶段 2: 基础系统配置和优化"
echo "=========================================="

# 系统更新
apt upgrade -y 
# 禁用休眠/挂起功能
mkdir -p /etc/systemd/sleep.conf.d
cat > /etc/systemd/sleep.conf.d/nosuspend.conf << EOF
[Sleep]
AllowSuspend=no
AllowHibernation=no
AllowSuspendThenHibernate=no
AllowHybridSleep=no
EOF 
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
# 替换 vim 配置
rm /etc/vim/vimrc.tiny
apt remove vim-tiny -y
wget -O /root/.vimrc https://raw.githubusercontent.com/hpcex/misc/main/.vimrc 


echo "=========================================="
echo "📁 阶段 3: 安装 eza "
echo "=========================================="

apt install -y gpg [cite: 17]
mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg [cite: 17]
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee -a /etc/apt/sources.list.d/gierens.list [cite: 18]
apt update
apt install -y eza [cite: 18]
# eza 别名将在最后统一配置

echo "=========================================="
echo "📊 阶段 4: 安装 btop "
echo "=========================================="

ARCH=$(uname -m) [cite: 1]
DOWNLOAD_URL=""
FILENAME="btop.tbz"
INSTALL_PATH="/usr/local/sbin/"
TEMP_DIR="/tmp/btop_install"

if [ "$ARCH" = "aarch64" ]; then
    echo "✅ 检测到架构: ARM64 (aarch64)。"
    DOWNLOAD_URL="https://github.com/aristocratos/btop/releases/latest/download/btop-aarch64-linux-musl.tbz" [cite: 2]
elif [ "$ARCH" = "x86_64" ]; then
    echo "✅ 检测到架构: AMD64 (x86_64)。"
    DOWNLOAD_URL="https://github.com/aristocratos/btop/releases/latest/download/btop-x86_64-linux-musl.tbz" [cite: 3]
else
    echo "❌ 警告：btop 不支持的系统架构 ($ARCH)，跳过安装。"
    BTOP_INSTALLED=false
fi

if [ -n "$DOWNLOAD_URL" ]; then
    BTOP_INSTALLED=true
    mkdir -p "$TEMP_DIR"
    echo "⬇️ 正在下载 btop..."
    if ! wget -qO "$TEMP_DIR/$FILENAME" "$DOWNLOAD_URL"; then [cite: 4]
        echo "❌ btop 下载失败，跳过安装。"
        BTOP_INSTALLED=false
    fi

    if [ "$BTOP_INSTALLED" = true ]; then
        echo "📦 正在安装 btop..."
        tar xjf "$TEMP_DIR/$FILENAME" -C "$TEMP_DIR"
        mkdir -p "$INSTALL_PATH"
        if mv "$TEMP_DIR/btop/bin/btop" "$INSTALL_PATH" && chmod +x "$INSTALL_PATH/btop"; then [cite: 5]
            echo "🎉 btop 安装成功！路径：$INSTALL_PATH/btop"
        else
            echo "❌ btop 安装失败。"
        fi
    fi
    rm -rf "$TEMP_DIR"
    echo "✅ btop 临时文件清理完成。"
fi


echo "=========================================="
echo "🐶 阶段 5: 安装 doggo "
echo "=========================================="

API_URL="https://api.github.com/repos/mr-karan/doggo/releases/latest"
JQ_INSTALLED=true # 已在 Section 0 中安装 jq
VERSION=""

# 4.1 获取最新版本号
echo "   正在获取 doggo 最新版本号..."
VERSION=$(curl -s "$API_URL" | jq -r '.tag_name' | sed 's/^v//') [cite: 11]

if [ -z "$VERSION" ]; then
    echo "❌ 严重错误：未能从 GitHub API 获取 doggo 版本号，跳过安装。"
else
    echo "✨ 已自动获取到 doggo 最新版本: v${VERSION}"
    
    # 4.2 自动获取架构并映射
    OS_ARCH=$(uname -m)
    ARCH="" 
    case "${OS_ARCH}" in
        x86_64 | amd64)
            ARCH="x86_64" [cite: 12]
            ;;
        aarch64 | arm64)
            ARCH="arm64"
            ;;
        *)
            echo "❌ doggo 不支持或无法识别的系统架构 '${OS_ARCH}'，跳过安装。"
            DOGGO_INSTALLED=false
            ;;
    esac

    if [ -n "$ARCH" ]; then
        DOGGO_INSTALLED=true
        PLATFORM="Linux"
        FILENAME="doggo_${VERSION}_${PLATFORM}_${ARCH}.tar.gz"
        URL="https://github.com/mr-karan/doggo/releases/download/v${VERSION}/${FILENAME}"
        TEMP_DIR="/tmp/doggo_install_v${VERSION}_$$" [cite: 13]

        echo "   旧的可执行文件已清理。"
        rm -f /usr/local/sbin/dog /usr/local/bin/doggo

        echo "   正在下载和安装 doggo..."
        mkdir -p "${TEMP_DIR}"
        cd "${TEMP_DIR}"

        if ! ${DOWNLOADER} "${URL}"; then [cite: 14]
            echo "❌ doggo 下载失败，URL可能无效：${URL}。跳过安装。"
            DOGGO_INSTALLED=false
        fi

        if [ "$DOGGO_INSTALLED" = true ]; then
            tar -xzf "${FILENAME}"
            find . -name "doggo" -type f -exec mv {} /usr/local/bin/doggo \; [cite: 15]
            chmod +x /usr/local/bin/doggo
            echo "🎉 doggo v${VERSION} 已安装到 /usr/local/bin/doggo"
        fi

        cd /
        rm -rf "${TEMP_DIR}"
        echo "✅ doggo 临时文件清理完成。"
    fi
fi

echo "=========================================="
echo "📝 阶段 6: 设置别名 "
echo "=========================================="

# eza 别名 (追加到 /root/.bashrc)
echo -e '\nalias ls="eza --icons"\nalias ll="eza --time-style=long-iso --icons --binary -lhg"\nalias tree="eza --tree --icons"' >> /root/.bashrc [cite: 18]

# doggo 别名 (追加到 /root/.bashrc)
ALIAS_LINE="alias dog='/usr/local/bin/doggo'"
if ! grep -q "$ALIAS_LINE" /root/.bashrc; then 
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