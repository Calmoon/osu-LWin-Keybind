#SingleInstance
#Persistent
#include <AutoHotInterception>

AHI := new AutoHotInterception()

findKeyboardID() {
	global AHI
	for index, device in AHI.GetDeviceList() {
		if not device.isMouse
			return device.Id
	}
	MsgBox, No keyboard was detected.`nThe program will now exit.
	ExitApp
}

keyboardID := findKeyboardID()

Loop {
	WinWaitActive, ahk_exe osu!.exe
	AHI.SubscribeKey(keyboardID, GetKeySC("LWin"), true, Func("KeyEvent"))
	
	WinWaitNotActive, ahk_exe osu!.exe
	AHI.UnsubscribeKey(keyboardID, GetKeySC("LWin"))
}

KeyEvent(state){
	global AHI
	global keyboardID
	AHI.SendKeyEvent(keyboardID, GetKeySC("z"), state)
}