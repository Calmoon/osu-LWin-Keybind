#SingleInstance
#Persistent
#include <AutoHotInterception>

AHI := new AutoHotInterception()

findKeyboardID() {
	global AHI
	
	; lmao, checking if a string is in a list of strings is WEIRD in this language, bruh  
	keyboardList := []
	knownHWIDs := ""
	for index, device in AHI.GetDeviceList() {
		if device.Id > 10
			break
		deviceHWID := device.Vid . device.Pid
		if deviceHWID not in %knownHWIDs% 
			keyboardList.Push(device)
			knownHWIDs .= deviceHWID . ","
	}
	
	if keyboardList.MaxIndex() < 1 {
		MsgBox No keyboard was detected.`nThe program will now exit.
		ExitApp
		
	} else if keyboardList.MaxIndex() > 1 {
		MsgBox, , Multiple keyboards detected, Multiple keyboards were detected!`nWe'll need to set this up first.`n`nAfter clicking OK, the program will show you message boxes giving instructions. Just follow them.`n`nDon't worry if the same message box shows up multiple times.`n`nYou'll only need to go through this once.
	
		instructionNumber := 1
		for index, currentDevice in keyboardList {
			global currentHWID := [currentDevice.Vid, currentDevice.Pid]
			
			MsgBox, , Instruction %instructionNumber%, After clicking OK, press any key on the keyboard you want the script to run on.
			
			; Subscribes all keys of the current keyboard in the loop with <block> set to true
			; This means only AHI can listen to this keyboard's keypresses
			AHI.SubscribeKeyboard(currentDevice.Id, true, Func("TestEvent"))
			
			; If any keypress IS detected by AHK (via the code below), though, then the currently subscribed keyboard is not the one we're looking for
			; Because if it was, AHK wouldn't detect the keypress (only AHI can detect the subscribed keyboard's keypresses, remember?).
			; So we move onto the next one in the device list, if it happens
			Input, SingleKey, L1, {LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{CapsLock}{NumLock}{PrintScreen}{Pause}
			
			instructionNumber++
		}
		
	} else {
		global keyboardID := keyboardList[1].Id
		KeyboardHWID := [keyboardList[1].Vid, keyboardList[1].Pid]
		saveKeyboardHWID(KeyboardHWID)
		return
	}
	
}

TestEvent(keyCode, state) {
	; If 'state' returns true, a keypress was detected on the current subscribed keyboard in the loop @ line 30
	; That means it's the correct one. Read comments in the mentioned loop to understand why
	if state {
		saveKeyboardHWID(0)
		MsgBox, , Set-up complete, Done!`n`nosu! LWin Keybind will start working after you click OK.`n`n(WARNING: DO NOT PRESS ANY KEY! Just click OK)
		Reload
	}
}

saveKeyboardHWID(VIDPID) {
	if not VIDPID { ; If 0 was passed as the parameter, save the global currentHWID (from the loop @ line 30) instead
		global currentHWID
		VIDPID := currentHWID
	}
	; Yes, I know. I'm doing it like this because the syntax for parsing variables is ridiculous and this is easier
	FileAppend, % VIDPID[1], keyboardHWID.ini
	FileAppend, `n, keyboardHWID.ini
	FileAppend, % VIDPID[2], keyboardHWID.ini
}

; " main 'function' " below ----------------------------------------------------------------------

if FileExist("keyboardHWID.ini") {
	VIDPID := []
	Loop, Read, keyboardHWID.ini
		VIDPID.Push(A_LoopReadLine)
	global keyboardID := AHI.GetKeyboardId(VIDPID[1], VIDPID[2], 1)	
	
} else 
	findKeyboardID()

MsgBox osu! LWin Keybind is running!`n`nYou can exit via right-clicking the tray icon or by pressing Ctrl+F11 at any time.`n`nIf you ever start using a different keyboard, delete the generated 'keyboardHWID.ini' file and re-run the script.

Loop {
	WinWaitActive, ahk_exe osu!.exe
	AHI.SubscribeKey(keyboardID, GetKeySC("LWin"), true, Func("LWinEvent"))
	
	WinWaitNotActive, ahk_exe osu!.exe
	AHI.UnsubscribeKey(keyboardID, GetKeySC("LWin"))
}

LWinEvent(state){
	global AHI
	global keyboardID
	AHI.SendKeyEvent(keyboardID, GetKeySC("z"), state)
}

Ctrl & F11::ExitApp
return