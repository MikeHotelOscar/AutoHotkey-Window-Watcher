#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SendMode Input
#UseHook On ;forces the use of keyboard hooks in hotkey execution
#SingleInstance force ;only one instance of this script may run at a time!
#WinActivateForce ;uses the not nice way to manipulate which window is active
#WinActivateForce ;https://autohotkey.com/docs/commands/_WinActivateForce.htm ;prevent taskbar flashing.
#Persistent
Process, Priority, , High
SetTitleMatchMode 2
#NoTrayIcon
;{AutoExecute
;{Define Groups for different functions
;{Move to Top Right Corner
;GroupAdd, MoveTRC, ahk_class SomeClass
;GroupAdd, MoveTRC, ahk_exe SomeExe
;}
;{Maximize on Open
GroupAdd, MaximizeOnOpen, 
;}
;{Do Not Maximize
;GroupAdd, DoNotMax, 
;}
;{AllGroups
;GroupAdd, AllGroups, ahk_group MoveTRC
;GroupAdd, AllGroups, ahk_group MaximizeOnOpen
;GroupAdd, AllGroups, ahk_group DoNotMax
;}
;}
WindowWatcherInit() ;initializes a loop that takes certain actions when certain windows open
;}
;{Functions
;{WindowWatcher Initiate
WindowWatcherInit(){
    static initDone := false

    if (initDone) ; If the function has been run before, exit out of this function
        return
    initDone := true ; Tell the function from now on this function has been run

    SetTimer, WindowWatcherPollForNewWindows ; Start Polling windows
}
;}
;{WindowWatcher Trigger
WindowWatcherTrigger(wParam, hwnd, ExeClass = 0) { ; ExeClass is an optional parameter used only for destroyed windows
    if (wParam == "Created") {
        OnWindowCreated(hwnd) ; if a window has been created, do a set of actions associated with a particular exe or class being opened.
    }
	else if (wParam == "Destroyed"){
		OnWindowDestroyed(hwnd, ExeClass) ; if a window has been destroyed, do a set of actions associated with the closed window
    }
}
;}
;{Window Watcher Poll for New Windows
WindowWatcherPollForNewWindows() {
    static windows := "" ; Initialize the array of windows, updated at the end of the function
    WinGet, wins, List, , , , ; get a list of all window IDs as a pseudo-array
    newWindows := Object()	; Create an object to store the current open windows
	ExeClass := Object()
    Loop, %wins%
    {
        this_id := wins%A_Index% ; create a variable with the window ID of a single window
		WinGet,WinExe,ProcessName,ahk_id %this_id% ; Get the Exe name of loop index
		WinGetClass,WinClass,ahk_id %this_id% ; Get the Class Name of the loop index
		ExeClass := [WinExe, WinClass] ; Assign the Exe Name and Class Name to a holding array
        newWindows[this_id] := ExeClass ; Add the ExeClass array as a value to the object as a value for key this_id
		;msgbox, % newWindows[this_id][1] . " " . newWindows[this_id][2]
        if (windows && !windows[this_id]){
            WindowWatcherTrigger("Created", this_id)
			; if this_id is not in the previous iteration of windows,
			; send a created Trigger with the Window ID
		}
    }
	;msgbox, % NewWindows.Count()
    for wid, ExeClassArray in windows {
        if (!newWindows[wid])
            WindowWatcherTrigger("Destroyed", wid, ExeClassArray) 	
			; if there is a ID from the previous iteration that is not in the new list,
			; send a destroyed trigger with the window ID and ExeClass array
    }
	MouseGetPos,,,WinID
	WinGetClass,WinClass,ahk_id %WinID%
	if (WinClass = "WorkerW"){
		WinActivate, AHK_class WorkerW
	}
    windows := newWindows
	if (stopscript = 1){ ; If script is closing, break the full loop
		Settimer, WindowWatcherPollForNewWindows, off
	}
}
;}
;{On Window Created
OnWindowCreated(hwnd) {
	; use an if statement matching ahk_class or ahk_exe, with ahk_id concatenated with the hwnd of the window, like so:
	; winexist("(ahk_class|ahk_exe|ahk_group) "SomeClass, SomeExe or SomeGroup" ahk_id" . hwnd)
	; When a command window opens, move it to top-right.
	if (WinExist("ahk_group MoveTRC ahk_id " . hwnd)){
		WinGetPos, , , w, , ahk_id %hwnd%
		x := A_ScreenWidth - w + 10
		WinMove, ahk_id %hwnd%, , %x%, 0
	}
	; Maximize the Window when it opens
	else if (WinExist("ahk_id " . hwnd . " ahk_group MaximizeOnOpen")) {
        WinMaximize, ahk_id %hwnd%
	}
	; If the new window is not a member of any other Action Groups
	; and the size is less than a quarter of the screen, maximize the window.
	else if !winactive("ahk_group AllGroups ahk_id" . hwnd){
			WinGetPos, , , width, height, ahk_id %hwnd%
			if (width * height >= .5 * A_ScreenWidth * A_ScreenHeight){
				WinMaximize, ahk_id %hwnd%
			}
		}
}
;}
;{On Window Destroyed
OnWindowDestroyed(hwnd, ExeClass){
	;ExeClass is an array of [Exe of Window, Class of Window]
	;use the form ((ExeClass[1] = "SomeExe") && !winexist("ahk_exe SomeExe ahk_id" . hwnd))
	;or the form ((ExeClass[2] = "SomeClass") && !winexist("ahk_Class SomeClass ahk_id" . hwnd))
}
;}
;}
