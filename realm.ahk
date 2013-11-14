;;;;; global vars
#include options.ahk

;;;;;;;;;;;;;; DO NOT DELETE!!
goto STARTUP ; DO NOT DELETE!!
;;;;;;;;;;;;;; DO NOT DELETE!!

;;;;; hotkeys
#include hotkeys.ahk


STARTUP:
	OnExit, ExitSub
	#NoEnv
	#SingleInstance force
	SendMode Input
	SetWorkingDir %A_ScriptDir%
	SetKeyDelay 0
	SetMouseDelay 0
	SetTitleMatchMode 3
	#include includes/SetSystemCursor.ahk
	#ClipboardTimeout -1
	SysGet, menuHeight, 15
	SysGet, vBorderWidth, 32
	SysGet, hBorderWidth, 33
	SysGet, titleHeight, 4

	Suspend On
	GroupAdd rotmg, Realm of the Mad God
	GroupAdd rotmg, Realm of the Mad God - Mozilla Firefox
	GroupAdd rotmg, Realm of the Mad God - Mozilla Firefox (Private Browsing)
	GroupAdd rotmg, Realm of the Mad God - Google Chrome
	GroupAdd rotmg, Realm of the Mad God - Opera
	GroupAdd rotmg, Realm of the Mad God - Windows Internet Explorer
	GroupAdd rotmg, Realm of the Mad God | Kabam
	GroupAdd rotmg, Realm of the Mad God | Kabam - Mozilla Firefox
	GroupAdd rotmg, Realm of the Mad God | Kabam - Mozilla Firefox (Private Browsing)
	GroupAdd rotmg, Realm of the Mad God | Kabam - Google Chrome
	GroupAdd rotmg, Realm of the Mad God | Kabam - Opera
	GroupAdd rotmg, Realm of the Mad God | Kabam - Windows Internet Explorer
	GroupAdd rotmg, Play Realm of the Mad God, a free online game on Kongregate
	GroupAdd rotmg, Play Realm of the Mad God, a free online game on Kongregate - Mozilla Firefox
	GroupAdd rotmg, Play Realm of the Mad God, a free online game on Kongregate - Mozilla Firefox (Private Browsing)
	GroupAdd rotmg, Play Realm of the Mad God, a free online game on Kongregate - Google Chrome
	GroupAdd rotmg, Play Realm of the Mad God, a free online game on Kongregate - Opera
	GroupAdd rotmg, Play Realm of the Mad God, a free online game on Kongregate - Windows Internet Explorer
	GroupAdd rotmg, Adobe Flash Player 10
	GroupAdd rotmg, Adobe Flash Player 11
	WinNotActive()
Return

WinActive(){
	WinGetTitle, winTitle, A
	WinGet, winProcessName, ProcessName, A
	global USE_CUSTOM_CURSOR, CUSTOM_CURSOR
	Suspend Off
	if(DISABLE_RESIZE&&(winTitle=="Adobe Flash Player 11"||winTitle=="Adobe Flash Player 10"||winProcessName=="Realm of the Mad God.exe")){
		WinSet, Style, -0x40000, ahk_group rotmg	;disable resize borders
	}
	if(USE_CUSTOM_CURSOR){
		SetSystemCursor("img/cursors/"+CUSTOM_CURSOR,0,0)
	}
	WinWaitNotActive ahk_group rotmg
	{
		WinNotActive()
	}
}

WinNotActive(){
	global USE_CUSTOM_CURSOR
	Suspend on
	if(USE_CUSTOM_CURSOR){
		RestoreCursors()
	}
	WinWaitActive ahk_group rotmg
	{
		WinActive()
	}
}

; convert /tp to /teleport in the game chat
:*:/tp::
	ClipSaved := ClipboardAll
	clipboard := "/teleport"
	Blockinput, on
	Send ^a
	Send ^v
	Send {Space}
	Blockinput, off
	Sleep 100
	clipboard := ClipSaved
	ClipSaved := "" ;save memory
Return

; sends passed string to the chat using the specified mode
sendChat(message, mode="public"){
	global
	local activation_key, key
	if(mode=="public"){
		activation_key = %CHAT_ACTIVATION_KEY%
		key = Enter
	} else if(mode=="guild") {
		activation_key = %GUILD_ACTIVATION_KEY%
		key = g
	} else { ;mode=="tell"
		activation_key = %TELL_ACTIVATION_KEY%
		key = Tab
	}
	if(activation_key){
		key = %activation_key%
	}
	local ClipSaved := ClipboardAll
	clipboard := message
	Blockinput, on
	Send {%key%}
	Send ^v
	Send {Enter}
	Blockinput, off
	Sleep 100
	clipboard := ClipSaved
	ClipSaved := "" ;save memory
}

; item swap function
; move the mouse to the correct slot, double-click, and move it back
invSwap(slot){
	MouseGetPos, mousePosX, mousePosY ;mousePosX/Y have old mouse position
	WinGetPos, , , winSizeX, winSizeY, A ;winSizeX/Y have window size
	WinGet, winProcessName, ProcessName, A
	GetKeyState, LB, LButton, P
	global menuHeight
	global vBorderWidth
	global hBorderWidth
	global titleHeight
	; move the mouse to the correct slot, double-click (using events), and move it back
	if(!imageQualitySearch("inv", imageLocX, imageLocY)){	;if the image search fails (stretched screen)
		;determine if the window is a steam or projector window, and adjust the value accordingly
		intendedX := 634 + Mod((44 * (slot-1)), (4*44))
		intendedY := 400 + (44 * ((slot-1)//(4)))
		stretchedWindowPosition(intendedX, intendedY, stretchedX, stretchedY)	;stretchedX and stretchedY are set by the function call
		windowPosToClientPos(stretchedX, stretchedY, posX, posY)	;posX and posY are set by the function call
	} else { ;not stretched, imageLocX/Y are set
		slotX := imageLocX + 27 + Mod((44 * (slot-1)), (4*44))
		slotY := imageLocY + 46 + (44 * ((slot-1)//(4)))
		windowPosToClientPos(slotX, slotY, posX, posY)	;posX and posY are set by the function call
	}
	BlockInput, on
	CoordMode, Mouse, Client
	MouseMove, posX, posY
	SendEvent {Control Up}
	SendEvent {LButton Down}
	SendEvent {LButton Up}
	SendEvent {LButton Down}
	SendEvent {LButton Up}
	CoordMode, Mouse, Window
	MouseMove, mousePosX, mousePosY
	if (LB == "D"){
		Send {LButton down}
	}
	BlockInput, off
	stretched := false
}

; @param imageName:	base file name (<name>-[low|high|med].png); must be located in the img\ directory
; @param imageLocX:	by-reference variable to be set to the window-related x position of the upper-left corner of the image
; @param imageLocY:	by-reference variable to be set to the window-related y position of the upper-left corner of the image
; @return:			returns true if the search succeeds; false otherwise
; @notes:			If the image search fails (and the function returns false), imageLocX and imageLocY will not be set.
imageQualitySearch(imageName, byref imageLocX, byref imageLocY){
	WinGetPos, , , winSizeX, winSizeY, A ;winSizeX/Y have window size
	ImageSearch, imageLocX, imageLocY, 0, 0, %winSizeX%, %winSizeY%, img\%imageName%-low.png
	if ErrorLevel {
		ImageSearch, imageLocX, imageLocY, 0, 0, %winSizeX%, %winSizeY%, img\%imageName%-high.png
		if ErrorLevel {
			ImageSearch, imageLocX, imageLocY, 0, 0, %winSizeX%, %winSizeY%, img\%imageName%-med.png
			if ErrorLevel {
				; stretched screen or image not found
				return false
			}
		}
	}
	return true
}

; @param intendedX:	what would otherwise be the correct x location in a non-stretched client
; @param intendedY:	what would otherwise be the correct y location in a non-stretched client
; @param actualX:	by-reference variable to be set to the window-related x position of the new x position
; @param actualY:	by-reference variable to be set to the window-related x position of the new y position
stretchedWindowPosition(intendedX, intendedY, byref actualX, byref actualY){
	WinGetPos, , , winSizeX, winSizeY, A ;winSizeX/Y have window size
	WinGet, winProcessName, ProcessName, A
	global menuHeight
	global vBorderWidth
	global hBorderWidth
	global titleHeight
	yMultiplierSubtract := (winProcessName=="Realm of the Mad God.exe")?((hBorderWidth*2)+titleHeight):(menuHeight+(hBorderWidth*2)+titleHeight)
	multiplierX := ((winSizeX-(vBorderWidth*2))/800)
	multiplierY := ((winSizeY-yMultiplierSubtract)/600)
	actualX := (intendedX * multiplierX) + (vBorderWidth*2)
	actualY := (intendedY * multiplierY) + (yMultiplierSubtract)
}

; @param windowX:	x position of a window-related coordinate
; @param windowY:	y position of a window-related coordinate
; @param outputX:	by-reference variable to be set to a client-related x coordinate
; @param outputY:	by-reference variable to be set to a client-related y coordinate
windowPosToClientPos(windowX, windowY, byref outputX, byref outputY){
	WinGetTitle, winTitle, A
	WinGet, winProcessName, ProcessName, A
	WinGet, winMax, MinMax, A
	global menuHeight
	global vBorderWidth
	global hBorderWidth
	global titleHeight
	
	;chrome (not maximized)
	if(winTitle=="Realm of the Mad God - Google Chrome"&&winMax==0){
		outputX := windowX
		outputY := windowY
	;opera, ff
	} else if(winTitle=="Realm of the Mad God - Opera"||winTitle=="Realm of the Mad God - Mozilla Firefox"||winTitle=="Realm of the Mad God - Mozilla Firefox (Private Browsing)") {
		outputX := windowX - vBorderWidth
		outputY := windowY
	;IE, safari, steam
	} else if(winTitle=="Realm of the Mad God - Windows Internet Explorer"||winProcessName=="Safari.exe"||winProcessName=="Realm of the Mad God.exe"){
		outputX := windowX - vBorderWidth
		outputY := windowY - (hBorderWidth+titleHeight)
	;chrome (when maximized)
	} else if(winTitle=="Realm of the Mad God - Google Chrome"&&winMax==1){
		outputX := windowX - vBorderWidth
		outputY := windowY - hBorderWidth
	} else { ;projector
		outputX := windowX - vBorderWidth
		outputY := windowY - (menuHeight+hBorderWidth+titleHeight)
	}
}

ExitSub:
	RestoreCursors()
	ExitApp