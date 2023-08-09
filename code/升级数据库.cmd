nali update
REM choice /t 8 /d y /n >nul
curl -o d:\incom\geosite.dat https://cdn.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.dat
curl -o d:\incom\Country.mmdb https://cdn.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/country.mmdb
wget -qO- https://cdn.jsdelivr.net/gh/felixonmars/dnsmasq-china-list/accelerated-domains.china.conf > china.conf
choice /t 4 /d y /n >NUL
sed -i 's/^.\{8\}//; s/................$//' china.conf
choice /t 4 /d y /n >NUL
MOVE .\china.conf d:\incom\china.conf
PAUSE