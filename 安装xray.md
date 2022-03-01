	apt -y install net-tools unzip socat curl wget screen mtr
         
	curl https://get.acme.sh | sh  
	alias acme.sh=~/.acme.sh/acme.sh  
	echo 'alias acme.sh=~/.acme.sh/acme.sh' >>/etc/profile  

	acme.sh --issue -d 域名 --standalone -m hpcex53@gmail.com

	mkdir /usr/share/xray && mkdir /etc/xray  
	export DAT_PATH='/usr/share/xray'  
	export JSON_PATH='/etc/xray'  

	bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

	sed --in-place 's|/usr/local/etc/xray/|/etc/xray/|g' /etc/systemd/system/xray*.service  
	systemctl daemon-reload

	acme.sh --install-cert -d 域名 \  
	--key-file       /etc/xray/key.pem  \  
	--fullchain-file /etc/xray/cert.pem \  
	--reloadcmd     "systemctl restart xray"  

	chown nobody /etc/xray/*

把 config.json 放到 /etc/xray/

	systemctl enable xray  
	systemctl start xray  

完成

