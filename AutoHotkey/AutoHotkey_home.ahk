; # ---  win 键
; ^ ---  ctrl
; ! ---  alt
; + ---  shift

; 调节系统音量 ctrl + alt + 方向键
^!Down::
Send {Volume_Down 1}  
return

^!Up::
Send {Volume_Up 1}  
return

^!End::
Send {Volume_Mute}  
return

; 关闭显示器 ctrl + alt + NUM 0
^!Numpad0::
SendMessage,0x112,0xF170,2,,Program Manager

; 窗口置顶 win + `
#`::
WinGetActiveTitle, Title
WinSet, AlwaysOnTop, toggle, %Title%
return

; 快速文字
::/fg::
SendInput ---*----------------------------------------------------------*---
return

; 快速启动
^!Numpad4::Run c:\soft\apps\everedit\EverEdit.exe
^!Numpad5::Run c:\soft\apps\textpro\textpro.exe
^!Numpad8::Run C:\Soft\apps\SpeQ\SpeQ.exe

; ctrl + space 代替 win + sapce
^space::#space

; ctrl + ` 代替 ctrl + alt + D
^`::^!d

; 输出当前时间 YYYY-MM-DD HH:MM:SS
::/dd::
d = %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%
clipboard = %d%
Send ^v
return

; 快速输入书名号
![::send,{U+300A}            ; alt + [ 输出左书名号
!]::send,{U+300B}            ; alt + ] 输出右书名号   

; 复制选择文字并转换「空格」为「下划线」 
; ctrl + alt + 小键盘 -
^!NumpadSub::        
Send ^c
Send ^c
clip := RegExReplace(clipboard, "\s","_")
clip := RegExReplace(clipboard, "\s","_")
tooltip,%clip%		;在鼠标右侧显示clipboard内容
sleep,1000
tooltip,
clipboard = %clip%
return
