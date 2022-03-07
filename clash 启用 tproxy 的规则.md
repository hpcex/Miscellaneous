## clash 用 tproxy，代理 tcp 和 udp 流量，并让透明网关自身流量走代理。

	tproxy-port: 7893  
	mixed-port: 7890  

## 新建一个名为 clash 的用户，gid为 23333，并加入 root 组。

	grep -qw clash /etc/passwd || echo "clash:x:0:23333:::" >> /etc/passwd  
	gpasswd -a clash root
	
## 修改 clash.service 文件，用 clash 这个用户来跑 clash。

	[Unit]  
	Description=clash Client Daemon  
	After=network.target  
	Wants=network.target  

	[Service]  
	Type=simple
	User=clash
	CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
	AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
	PIDFile=/var/run/clash.pid  
	ExecStart=/usr/bin/clash -d /root/.config/clash  
	Restart=always  
	RestartSec=2  

	[Install]  
	WantedBy=multi-user.target  

## 规则

	ip rule add fwmark 1 table 100  
	ip route add local 0.0.0.0/0 dev lo table 100  

	iptables -t mangle -N TVB
	iptables -t mangle -A TVB -d 100.64.0.0/10 -j RETURN  
	iptables -t mangle -A TVB -d 127.0.0.0/8 -j RETURN  
	iptables -t mangle -A TVB -d 169.254.0.0/16 -j RETURN  
	iptables -t mangle -A TVB -d 192.0.0.0/24 -j RETURN  
	iptables -t mangle -A TVB -d 224.0.0.0/4 -j RETURN  
	iptables -t mangle -A TVB -d 240.0.0.0/4 -j RETURN  
	iptables -t mangle -A TVB -d 255.255.255.255/32 -j RETURN  
	iptables -t mangle -A TVB -d 192.168.0.0/16 -j RETURN  
	iptables -t mangle -A TVB -d 172.16.0.0/12 -j RETURN  
	iptables -t mangle -A TVB -d 10.0.0.0/8 -j RETURN  
	iptables -t mangle -A TVB -p tcp -j TPROXY --on-port 7893 --tproxy-mark 1  
	iptables -t mangle -A TVB -p udp -j TPROXY --on-port 7893 --tproxy-mark 1  
	iptables -t mangle -A PREROUTING -j TVB  

	iptables -t mangle -N LOCAL_TVB  
	iptables -t mangle -A LOCAL_TVB -d 100.64.0.0/10 -j RETURN  
	iptables -t mangle -A LOCAL_TVB -d 127.0.0.0/8 -j RETURN  
	iptables -t mangle -A LOCAL_TVB -d 169.254.0.0/16 -j RETURN  
	iptables -t mangle -A LOCAL_TVB -d 192.0.0.0/24 -j RETURN  
	iptables -t mangle -A LOCAL_TVB -d 224.0.0.0/4 -j RETURN  
	iptables -t mangle -A LOCAL_TVB -d 240.0.0.0/4 -j RETURN  
	iptables -t mangle -A LOCAL_TVB -d 255.255.255.255/32 -j RETURN  
	iptables -t mangle -A LOCAL_TVB -d 192.168.0.0/16 -j RETURN  
	iptables -t mangle -A LOCAL_TVB -d 172.16.0.0/12 -j RETURN  
	iptables -t mangle -A LOCAL_TVB -d 10.0.0.0/8 -j RETURN  
	iptables -t mangle -A LOCAL_TVB -p tcp -j MARK --set-mark 1  
	iptables -t mangle -A LOCAL_TVB -p udp -j MARK --set-mark 1  
	iptables -t mangle -A OUTPUT -m owner ! --gid-owner 23333 -j LOCAL_TVB  

## EOF
