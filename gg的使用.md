## 安装  
curl -Ls https://hubmirror.v2raya.org/raw/mzz2017/gg/main/release/go.sh | sudo sh

## 查看版本  
gg --version

## 添加节点  
gg config -w node=vmess://MY_VMESS_SERVER_SHARE_LINK  
gg config -w node=socks5://127.0.0.1:7891  
下次再添加节点时会覆盖现有的配置。

## 列出所有配置项  
gg config  

## 直接代理整个 shell session：  
gg bash  
退出命令 exit 或 ctrl + D  

## 与 zsh 冲突  
Q: 我正在使用 oh-my-zsh，使用 gg 时我得到一个错误 git：'gui' 不是一个 git 命令。参见 'git --help'。怎样解决这个问题？  
A: It is a problem of oh-my-zsh, it added an alias from gg to git gui. Append following content to ~/.zshrc:  

unalias gg  

