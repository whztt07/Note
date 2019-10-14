[General]
SyntaxVersion=2
BeginHotkey=80
BeginHotkeyMod=6
PauseHotkey=0
PauseHotkeyMod=0
StopHotkey=123
StopHotkeyMod=0
RunOnce=1
EnableWindow=
MacroID=eddb7b5f-4dd8-4f88-89eb-256188030f52
Description=pmb
Enable=1
AutoRun=0
[Repeat]
Type=0
Number=1
[SetupUI]
Type=2
QUI=
[Relative]
SetupOCXFile=
[Comment]

[Script]
KeyUp "Ctrl", 1
KeyUp "Alt", 1
KeyUp "P", 1
Delay 100
x = WaitKey()
KeyPress "BackSpace", 1
SayString "\pmb{" + Chr(x + 32) + "}"
