; # ---  win ��
; ^ ---  ctrl
; ! ---  alt
; + ---  shift

; ����ϵͳ���� ctrl + alt + �����
^!Down::
Send {Volume_Down 1}  
return

^!Up::
Send {Volume_Up 1}  
return

^!End::
Send {Volume_Mute}  
return

; �ر���ʾ�� ctrl + alt + NUM 0
^!Numpad0::
SendMessage,0x112,0xF170,2,,Program Manager

; �����ö� win + `
#`::
WinGetActiveTitle, Title
WinSet, AlwaysOnTop, toggle, %Title%
return

; ��������
::/fg::
SendInput ---*----------------------------------------------------------*---
return

; ��������
^!Numpad4::Run c:\soft\apps\everedit\EverEdit.exe
^!Numpad5::Run c:\soft\apps\textpro\textpro.exe
^!Numpad8::Run C:\Soft\apps\SpeQ\SpeQ.exe

; ctrl + space ���� win + sapce
^space::#space

; ctrl + ` ���� ctrl + alt + D
^`::^!d

; �����ǰʱ�� YYYY-MM-DD HH:MM:SS
::/dd::
d = %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%
clipboard = %d%
Send ^v
return

; ��������������
![::send,{U+300A}            ; alt + [ �����������
!]::send,{U+300B}            ; alt + ] �����������   

; ����ѡ�����ֲ�ת�����ո�Ϊ���»��ߡ� 
; ctrl + alt + С���� -
^!NumpadSub::        
Send ^c
Send ^c
clip := RegExReplace(clipboard, "\s","_")
clip := RegExReplace(clipboard, "\s","_")
tooltip,%clip%		;������Ҳ���ʾclipboard����
sleep,1000
tooltip,
clipboard = %clip%
return
