## 配置 debian 网络  
编辑 /etc/network/interfaces

iface eth0 inet static  
address 192.168.1.242  
netmask 255.255.255.0  
gateway 192.168.1.240  
dns-nameservers 192.168.1.240  

## 开转发
sysctl -w net.ipv4.ip_forward=1  
验证一下，回显是 1 说明转发开启成功：  
cat /proc/sys/net/ipv4/ip_forward  

## 下载最新版 clash  
wget https://github.com/Dreamacro/clash/releases/download/v1.9.0/clash-linux-amd64-v1.9.0.gz  
gzip -d clash-linux-amd64-v1.9.0.gz  
mkdir -p /opt/clash  
mv clash-linux-amd64-v1.9.0 /opt/clash/clash  
chmod +x /opt/clash/clash  
复制config.yaml到 /opt/clash 目录下  

## 配置 iptable
192.168.1.0/24是你的lan段的地址，请根据自己的情况修改，这里port 7892是clash的转发端口。  

iptables -t nat -A PREROUTING -s 192.168.1.0/24 -d 192.168.1.242/32 -j ACCEPT  
iptables -t nat -A PREROUTING -s 192.168.1.0/24 -p tcp -j REDIRECT --to-ports 7892  

或

iptables -t nat -A PREROUTING -s 192.168.1.0/24 -d 192.168.1.242/32 -j ACCEPT  
iptables -t nat -A PREROUTING -s 192.168.1.0/24 -p tcp --dport 443 -j REDIRECT --to-ports 7892  
iptables -t nat -A PREROUTING -s 192.168.1.0/24 -p tcp --dport 80 -j REDIRECT --to-ports 7892  

## 保存 iptable 规则
apt install iptables-persistent  
iptables-save > /etc/iptables/rules.v4  

若要从 rules.v4 文件恢复配置，命令是  
iptables-restore < /etc/iptables/rules.v4  

## 做成系统服务并启动
mv clash.service /lib/systemd/system/

clash.service内容如下：

[Unit]  
Description=clash Client Daemon  
After=network.target  
Wants=network.target  

[Service]  
Type=simple  
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE  
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE  
PIDFile=/var/run/clash.pid  
ExecStart=/opt/clash/clash -d /opt/clash  
Restart=always  
RestartSec=2  

[Install]  
WantedBy=multi-user.target  

## web ui
下载最新版yacd  
https://github.com/haishanh/yacd/releases  

然后解压到 /root/.config/clash/dashboard 下

## 应用并启动
systemctl enable clash  
systemctl start clash  
systemctl stop clash  

## 看日志
cd /var/log  
tail -f syslog  
或
journalctl --no-pager | grep 'clash'
