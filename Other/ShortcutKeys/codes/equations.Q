[General]
SyntaxVersion=2
BeginHotkey=69
BeginHotkeyMod=6
PauseHotkey=0
PauseHotkeyMod=0
StopHotkey=123
StopHotkeyMod=0
RunOnce=1
EnableWindow=
MacroID=2c7f77ec-b33b-4eee-9c02-20ed05423aa5
Description=equations
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
KeyUp "E", 1
SayString "\begin{aligned}"
KeyPress "Enter", 1
KeyPress "Enter", 1
SayString "\end{aligned}"
KeyPress "Up", 1
