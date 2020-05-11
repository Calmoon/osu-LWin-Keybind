#SingleInstance force
#Persistent
#include <AutoHotInterception>

AHI := new AutoHotInterception()

Loop {
	WinWaitActive, ahk_exe osu!.exe
	AHI.SubscribeKey(1, GetKeySC("LWin"), true, Func("KeyEvent"))
	
	WinWaitNotActive, ahk_exe osu!.exe
	AHI.UnsubscribeKey(1, GetKeySC("LWin"))
}

KeyEvent(state){
	global AHI
	AHI.SendKeyEvent(1, GetKeySC("x"), state)
}