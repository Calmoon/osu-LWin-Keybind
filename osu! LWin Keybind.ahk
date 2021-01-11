#SingleInstance
#Persistent
#include <AutoHotInterception>

AHI := new AutoHotInterception()

findKeyboardID() {
	global AHI
	
	keyboardHandleList := []
	for index, device in AHI.GetDeviceList() {
		if device.Id > 10
			break
		keyboardHandleList.Push(device.Handle)
	}
	
	if keyboardHandleList.MaxIndex() < 1 {
		MsgBox No keyboard was detected.`nThe program will now exit.
		ExitApp
		
	} else if keyboardHandleList.MaxIndex() > 1 {
		MsgBox, , Multiple keyboards detected, Multiple keyboards were detected!`nWe'll need to set this up first.`n`nAfter clicking OK, the program will show you message boxes giving instructions. Just follow them.`n`nDon't worry if the same message box shows up multiple times.`n`nYou'll only need to go through this once.
	
		instructionNumber := 1
		for index, keyboardHandle in keyboardHandleList {
			global currentKbHandle := keyboardHandle
			
			; Subscribes the keyboard at the current index to AHI, with <block> set to true. All its keypresses will be passed onto TestEvent().
			; That means only AHI can listen to said keyboard, AHK cannot.
			AHI.SubscribeKeyboard(AHI.GetDeviceIdFromHandle(false, keyboardHandle), true, Func("TestEvent"))
			
			; In the next lines, AHK waits for the press of any key:
			MsgBox, , Instruction %instructionNumber%, After clicking OK, press any key on the keyboard you want the script to run on.
			Input, SingleKey, L1, {LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{CapsLock}{NumLock}{PrintScreen}{Pause}
			
			; To summarize, there are now two listeners waiting for a keypress: TestEvent() (AHI) and the above code (AHK).
			; The user will then press a key on the correct keyboard.
			; If the above code is what detects it, then the currently subscribed keyboard is wrong. If it was correct, AHK would't be able to listen to it.
			; If TestEvent() is what detects it, we've successfully subscribed the correct keyboard. TestEvent() then saves its HID and stops this loop.
			
			instructionNumber++
		}
		
	} else {
		global keyboardID := AHI.GetDeviceIdFromHandle(false, keyboardHandleList[1])
		saveKeyboardHID(keyboardHandleList[1])
		return
	}
	
}

TestEvent(keyCode, state) {
	; Triggered if a keypress if detected while findKeyboardID() is running.
	if state {
		global currentKbHandle
		saveKeyboardHID(currentKbHandle)
		MsgBox, , Set-up complete, Done!`n`nosu! LWin Keybind will start working after you click OK.`n`n(WARNING: DO NOT PRESS ANY KEY! Just click OK)
		
		; Restarts the code so main can run from zero, detect the newly saved keyboardHID.ini file and finally run the rebind
		Reload
	}
}

saveKeyboardHID(keyboardHandle) {
	FileAppend, % keyboardHandle, keyboardHID.ini
}

; ----------------------- "main" -----------------------

if FileExist("keyboardHID.ini") {
	FileRead, keyboardHandle, keyboardHID.ini
	global keyboardID := AHI.GetDeviceIdFromHandle(false, keyboardHandle)
} else 
	findKeyboardID()

MsgBox osu! LWin Keybind is running!`n`nYou can exit via right-clicking the tray icon or by pressing Ctrl+F11 at any time.`n`nIf you ever start using a different keyboard, delete the generated 'keyboardHID.ini' file and re-run the script.

Loop {
	WinWaitActive, ahk_exe osu!.exe
	AHI.SubscribeKey(keyboardID, GetKeySC("LWin"), true, Func("LWinEvent"))
	
	WinWaitNotActive, ahk_exe osu!.exe
	AHI.UnsubscribeKey(keyboardID, GetKeySC("LWin"))
}

LWinEvent(state) {
	global AHI
	global keyboardID
	AHI.SendKeyEvent(keyboardID, GetKeySC("z"), state)
}

Ctrl & F11::ExitApp
return
