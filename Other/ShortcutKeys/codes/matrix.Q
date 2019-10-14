[General]
SyntaxVersion=2
BeginHotkey=77
BeginHotkeyMod=6
PauseHotkey=0
PauseHotkeyMod=0
StopHotkey=123
StopHotkeyMod=0
RunOnce=1
EnableWindow=
MacroID=a174e0b0-2029-447b-a78f-285b0dc61d54
Description=matrix
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
KeyUp "M", 1
SayString "\left[\begin{matrix}"
KeyPress "Enter", 1
KeyPress "Enter", 1
SayString "\end{matrix}\right"
KeyPress "Up", 1
