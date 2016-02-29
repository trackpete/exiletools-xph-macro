; POE XPH Checker
; Version 3.0 (2015-09-21)
;
; The latest version of this can always be found here:
;
;   http://exiletools.com
;
; Written by Pete Waterman aka trackpete on reddit, pwx* in game
;
; PLEASE NOTE: This macro is UNSUPPORTED and EXPERIMENTAL. It works pretty well for me, but
; various users have different experiences. You MUST tweak the box size (minheight & minwidth)
; to get accurate results. In version 3, only comma and decimal formatted numbers are supported -
; numbers with spaces won't work without modification to the regexp that reduces accuracy.
;
; Please read the detailed setup extructions at http://exiletools.com if you have any questions.
;
; FAQ: Is this against the Terms of Service?
;      NO! This program and this macro *does not interact with the game client.* It does not take
;      a single in-game action for you. Reading the screen is not against the TOS. Performing an
;      automated action based on this WOULD be against the TOS, but this macro does NOT take any
;      action.
;
; == Requirements / Setup =====================================
;
; 1. Make sure you are using AHK from http://ahkscript.org/download/ - only Unicode versions 
;      have been tested (I use Unicode 64-bit)
;
; 2. Download Capture2Text from Sourceforge: http://capture2text.sourceforge.net/
;
; 3. Extract the Capture2Text zip file somewhere and make a note of the location. I recommend
;      using a simple directory like c:\temp\capture2text or c:\capture2text
;
; 4. Search this file for the variable %Capture2TextPATH% and ensure it is set properly
;
; 5. Edit the default hotkeys if desired. Currently ctrl-x will set the first checkpoint and
;      show you stats from that checkpoint. ctrl-shift-x will RESET the checkpoint.
;
; 6. Make sure you start Path of Exile in Windowed or Windowed Full Screen mode
;
; 7. Hover your mouse as close to the bottom of the screen in the middle of the XP bar and hit ^x.
;      If you see an "XP OCR Failed" tooltip message, that means the OCR didn't come back clean
;      (or capture2text isn't installed right), just mouse over a slightly different area and try
;      again. Sometimes you might need to move because confusing backgrounds can mess it up.
;
;      IMPORTANT: Please review the Troubleshooting & Tweaking section if it doesn't work consistently.
;      You really should set minwidth and minheight variables to be optimal.
;
; 8. Kill stuff. Any time you want, hit ^x over the XP bar again to get an update. ^X to reset. Bam.
;
; 9. To save the information from the current checkpoint, press ^s. This
;    will give you a popup that allows you to verify the information and make a note that will be
;    saved to a log file. To save and start a new checkpoint immediately, press ^S.
;
;10. To view the log file in game, press ^l 
;
; Author's Note: I'm not an AHK programmer, I learned everything on the fly. There is a
; good chance this code will look sloppy to experienced AHK programmers, if you have any
; advice or would like to re-write it, please feel free and let me know. 
;
; Author's Note 2: There's a lot of random stuff commented out here from when I was writing and
; debugging this. I'm lazy and leaving it in. Seriously I don't know what I'm doing with AHK most
; of the time, I just google "how to add numbers in ahk" etc. If you can do it better, do it! That'd
; be hot.
;
; USAGE NOTE: This requires your Path of Exile to be in Windowed (or Windowed Full Screen) 
; to work properly, otherwise the popup will just show in the background and you won't
; see it.

; ===================================================
; Troubleshooting & Tweaking
;
; You really need to set the MinWidth and MinHeight variables to match the size of the XP box for
; your window resolution. If it is too wide, you will be much more likely to get false characters
; that will mess it up. 
; 
; To find the right size, take a look at the "output" directory in the capture2text folder after
; running the macro. There will be a tif file showing the original screen capture. Adjust the settings
; until the tif file is the right size for a three line XP box at your resolution.
;
; You can also check the text output to see what is going on with the OCR. In general, the code
; in this macro removes commas and periods, then searches for "Exp: #######" followed by a space
; to identify the amounts. If you consistently are getting "OCR Failed" check the output and make
; sure stuff is going into the tif and text files accurately.
;
; Darker backgrounds make a BIG DIFFERENCE. Lighting backgrounds are more likely to pick up a bunch
; of noisy false characters. Avoid having the XP mouseover conflict with the skill bars as well.

; ===================================================
; Change Log
; v1.0a (2015-01-23):
;      Proof of Concept release. Well received on Reddit, but lots of concerns about OCR failing/etc.
;      https://www.reddit.com/r/pathofexile/comments/2tuzan/experimental_ingame_xphour_macro_for_all_100_legal/
;
; v1.1E (2015-01-30):
;      EXPERIMENTAL RELEASE.
;      - Made the OCR check into a function that repeats up to 3x - each time it draws a slightly bigger
;        OCR box. This has increased the hit rate for me in initial testing, but it's still not 100%.
;        This can probably be done much better. More than 3x causes too much of a visible delay.
;      - Added detection for current level (sometimes can get 58 confused with 53, etc.)
;      - Added Logging functionality. Hit ^s to save a current summary line to a log in CSV format.
;        You can type a note in to add to it, such as the zone name. Hit ^S to do the same but start
;        a new checkpoint immediately.
;      - Added Basic Listview for XPH log - ^l to access it. This needs serious improvement.
;      - Generally tried to clean up the code a little bit, but really I'm not great at AHK sorry
;     
; v2.0 (2015-02-25):
;
;      - Completely rewrote the variable handling to make it use AHK's Associative Arrays which are similar
;        to the perl hashes I'm familiar with, but not as cool. This allowed me to implement tracking of
;        multiple simultaneous XP stats
;      - Added GEM tracking support! Each gem will be tracked individually BASED ON ITS NAME. Everything with
;        gems works just like with character XP, except it sends a ^c to the client to get the info into the
;        clipboard, which GGG supports. You may track, report, and save logs for multiple gems and your character
;        at the same time, as long as each gem has a different name. I don't see a reasonable way to handle trying to 
;        track a level 2 Empower and a level 1 Empower, for example. Sorry.
;      - Cleaned up some formatting in the text results
;      - Added auto conversion to Hours for time remaining if it is greater than 120min
;      - Added a single decimal point to time remaining estimations (i.e. "1.3 hours" or "21.6 min")
;
; v3.0 (2015-09-21)
;
;      - Refactored a bunch of code to optimize it
;      - Changed the runwait command to call a global variable
;      - Removed resizing of capture box on retry
;      - Added support for numbers like 1.234 instead of just 1,234
;      - Improved some of the tooltip formatting

; == Startup Options ===========================================
#SingleInstance force
#NoEnv 
#Persistent ; Stay open in background
SendMode Input 
StringCaseSense, On ; Match strings with case.
Menu, tray, Tip, ExileTools XP/Hour 3

If (A_AhkVersion <= "1.1.15")
{
    msgbox, You need AutoHotkey v1.1.15 or later to run this script. `n`nPlease go to http://ahkscript.org/download and download a recent version.
    exit
}

; == Variables and Options and Stuff ===========================
;   CHANGE THIS LINE TO HAVE THE CORRECT PATH!
Global Capture2TextPATH := "c:\temp\capture2text"

; These are used to draw the default OCR box. You WILL need to adjust them for
; maximum accuracy

; These are some rough guidelines from my testing:
; 1920x1080 - Width: 415, Height: 66, XSpace: 33
; 2560x1440 - Width: 548, Height: 90, XSpace: 33
; There are instructions on how to find the exact size of your XP window at http://exiletools.com

Global MinWidth := 548    ; This is the minimum width of the XP box to capture
Global MinHeight := 90    ; This is the minimum height of the XP box to capture
Global XSpace := 33       ; This is the empty space between the mouse cursor and start of XP box
Global YSpace := 0        ; This is a little padding below the mouse cursor so you don't have to be at the bottom of the XP box
                          ; Really honestly, you are best off setting this to 0 and making sure that you always put your mouse
						  ; at the VERY BOTTOM of the screen if you don't have the Exp Per Hour line.

; This sets the default pixel width and number of rows to show in the list
; summary box. If you have a higher resolution screen I suggest increasing the
; width and rows! If the box is too big, shrink it!
Global ListWidth := 1200
Global ListRows := 30
						  
						  
; Set the default XPH log name, for now it goes into the same directory as the AHK
; file. Lazy.
Global XPHLog := "xph.log"

; How much the mouse needs to move before the popup goes away
; It defaults to 100px so you can move a fair bit, if you don't like that lower MouseMoveThreshold
MouseMoveThreshold := 100
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen

; I'm used to Perl and global variables. It's lazy, I know, but I'm just making all of these
; Global so I don't have to pass them between subroutines/functions/etc.
Global X
Global Y
Global ResetCheck
Global OCRcheck ; so we can check for returns from OCR

Global HashCurrentXP := Object() ; Trying to make a super global?
Global HashLastXP := Object() ; Trying to make a super global?
Global HashCurrentLevel := Object() ; Trying to make a super global?
Global HashLastLevel := Object() ; Trying to make a super global?
Global HashNextXP := Object() ; Trying to make a super global?
Global HashCurrentTime := Object() ; Trying to make a super global?
Global HashLastTime := Object() ; Trying to make a super global?

; You can change the macros here. First one is to see current stats, second one to see + reset checkpoint, third to save to log

#IfWinActive, Path of Exile ahk_class Direct3DWindowClass 
^x::
{
  FunctionFetchXP("noreset")
  return
}

^+x::
{
  FunctionFetchXP("reset")
  return
}

^s::
{
  FunctionFetchXP("save")
  return
}

^+s::
{
  FunctionFetchXP("savereset")
  return
}

^l::
{
  FunctionListView()
  return
}


; == Popup/Tooltip Stuff =======================================

; This is for the tooltip, so it shows it and starts a timer that watches mouse movement.
; I imagine there's a better way of doing this.
FunctionShowToolTip(content)
{
    ; Get position of mouse cursor
    MouseGetPos, X, Y	
    ToolTip, %content%, X + 30, Y - 120
    SetTimer, SubWatchCursor, 100       
}

; Watches the mouse cursor to get rid of the tooltip after too much movement
SubWatchCursor:
    MouseGetPos, CurrX, CurrY
    MouseMoved := (CurrX - X)**2 + (CurrY - Y)**2 > MouseMoveThreshold**2
    If (MouseMoved)
    {
        SetTimer, SubWatchCursor, Off
        ToolTip
    }
    return

; == The Goods =====================================
FunctionRunOCR(Retries) {
    Retries := Retries + 1	
	; Retry twice with gradually larger boxes, then bail
	if (Retries > 2) {
      ; I had a really hard time getting information out of this nested sub in AHK. This works, screw it.
	  OCRcheck = bad        	  
	  return
	}
	
	; Get the current mouse coordinates, then draw a box using those to start with	
	; You can change this behavior if needed, but also adjust the MinHeight / MinWidth variables up top
    MouseGetPos, MX, MY
	; Bottom Left starts at X + XSpace coordinate of mouse pointer
	MinX := MX + XSpace                         
	; Top Left side starts MinHeight px above coordinate of mouse pointer
	MinY := MY - MinHeight
	; Right side ends MinWidth px to the right of mouse pointer
	MaxX := MX + MinWidth + XSpace
	; Bottom Right side ends YSpace px below mouse pointer
	MaxY := MY + YSpace
	
    ; This is a debug feature, uncomment it to see what you're capturing during test	
    ;MsgBox, %Capture2TextPATH%/capture2text.exe %MinX% %MinY% %MaxX% %MaxY%

    RunWait %Capture2TextPATH%/capture2text.exe %MinX% %MinY% %MaxX% %MaxY%,%Capture2TextPATH%,Hide,
	
	CurrentTime = %A_Now%
    ClipBoardData = %clipboard%
	StringReplace, ClipBoardData, ClipBoardData,% Chr(44),, All          ; Strip commas out of clipboard data so regexp works with \d+
	StringReplace, ClipBoardData, ClipBoardData,% Chr(44),, All          ; Strip periods for internationalized numbers
	; NOTE: I haven't found a way to consistently handle numbers with spaces in them, like some internationalization. Sorry mates. :(
	
    ;   This is another debug feature, if you want to see the OCR data to see if "exp" / etc. is showing up in it or not
    ;	MsgBox, %ClipBoardData%
    Match := RegExMatch(ClipBoardData, "Exp..?(\d+)", CurrentXP)	     ; This regexp checks for numbers after Exp. It is loose due to inaccuracy in OCR
    Match := RegExMatch(ClipBoardData, "Next Level..?(\d+) ", NextXP)	 ; Same for next level
	Match := RegExMatch(ClipBoardData, "Level (\d+)", MyLevel)	 ; Same for next level
    if (CurrentXP1 < 1 OR NextXP1 < HashCurrentXP[Character] OR NextXP1 < 1 OR MyLevel1 < 1) {         ; Make sure the XP we get make sense to prevent hits on something like "Exp: 12 3 898"
  	  FunctionRunOCR(Retries)
	} else {
	  HashCurrentXP["Character"] := CurrentXP1
	  HashNextXP["Character"] := NextXP1
	  HashCurrentLevel["Character"] := MyLevel1	  	  
	  HashCurrentTime["Character"] := CurrentTime
	  OCRcheck = ok
	}
} 

FunctionTrackXP(Target,ClipBoardData,ResetCheck) {

  ; Hashes are really weird in AHK. I feel like there should be a more elegant way to do this
  ; than continually creating then unpacking hashes but I can't figure out how to use
  ; a key value pair as a variable  	  
  CurrentXP := HashCurrentXP[(Target)]
  CurrentLevel := HashCurrentLevel[(Target)]
  CurrentTime := HashCurrentTime[(Target)]
  NextXP := HashNextXP[(Target)]
  LastXP := HashLastXP[(Target)]
  LastTime := HashLastTime[(Target)]
  LastLevel := HashLastLevel[(Target)]

;  For key, value in HashCurrentXP
;    MsgBox %key% = %value%
  
;  MsgBox,
;  ( LTrim
;    Target: %Target%
;	CurrentXP: %CurrentXP%
;	NextXP: %NextXP%
;	CurrentLevel: %CurrentLevel%
;	CurrentTime: %CurrentTime%
;	LastXP: %LastXP%
;	LastTime: %LastTime%
;	LastLevel: %LastLevel%
;  )
  


  if (LastXP < 1) {      ; First time for this Target let's set a checkpoint
      PrettyCurrentXP := RegExReplace(CurrentXP, "\G\d{1,3}(?=(?:\d{3})+(?:\D|$))", "$0,")  ; Commas and stuff, in case they're still there.
	  ; This is the line that gets printed in the popup, feel free to modify it
	  content = %Target% Checkpoint Created:`n`n%PrettyCurrentXP% XP (level %CurrentLevel%)
		HashLastXP[(Target)] := CurrentXP
  	    HashLastLevel[(Target)] := CurrentLevel
	    HashLastTime[(Target)] := CurrentTime   
		FunctionShowToolTip(content)    	
	} else if (CurrentXP > LastXP AND NextXP > CurrentXP) {  ; Sweet, we have XP. Also the target for the next level makes sense.
      IncreaseXP := CurrentXP - LastXP
	  PrettyIncreaseXP := RegExReplace(IncreaseXP, "\G\d{1,3}(?=(?:\d{3})+(?:\D|$))", "$0,")
  	  PrettyCurrentXP := RegExReplace(CurrentXP, "\G\d{1,3}(?=(?:\d{3})+(?:\D|$))", "$0,")
      IncreaseSeconds := CurrentTime	          ; EnvSub seems to need a mandatory variable to modify, weird
	  EnvSub, IncreaseSeconds, LastTime, seconds  ; Compare current time to last time, this is clumsy but the way it seems to work
	  ; All of this below is clumsy, I don't know how to do it more efficiently in AHK. Round didn't seem to work
	  ; when I did it all on one line.
	  XPS := IncreaseXP / IncreaseSeconds
	  XPS := Round(XPS)
	  XPH := XPS * 3600
	  XPH := Round(XPH)
      PrettyXPH := RegExReplace(XPH, "\G\d{1,3}(?=(?:\d{3})+(?:\D|$))", "$0,")
	  TimeToLevel := (NextXP - CurrentXP) / XPS / 60
      if (TimeToLevel > 120) {
	    TimeToLevel := TimeToLevel / 60
		TimeToLevel := Round(TimeToLevel, 1)
		TimeToLevel = %TimeToLevel% hours
	  } else {
	    TimeToLevel := Round(TimeToLevel, 1)
		TimeToLevel = %TimeToLevel% minutes
	  }
	  if (IncreaseSeconds > 120) {
	    IncreaseTime := IncreaseSeconds / 60
		IncreaseTime := Round(IncreaseTime, 1)
		IncreaseTime = %IncreaseTime% min
	  } else {
	    IncreaseTime = %IncreaseSeconds% sec
	  }
	  ; This is the line that gets printed in the popup, feel free to modify it
      content = %Target% XPH: %PrettyXPH% over the last %IncreaseTime%`nTime to Next Level: %TimeToLevel%`n+%PrettyIncreaseXP% XP since last checkpoint`n(Level %CurrentLevel% w/ %PrettyCurrentXP% XP)

	  if (ResetCheck = "reset") {      ; We need to reset the checkpoint
		HashLastXP[(Target)] := CurrentXP
  	    HashLastLevel[(Target)] := CurrentLevel
	    HashLastTime[(Target)] := CurrentTime   
		content = %content% `n`n>> resetting checkpoint to current XP!		
		FunctionShowToolTip(content)
	  }	else if (ResetCheck = "savereset" OR ResetCheck = "save") {   ; Saving this data to a log file
	    ; Default CSV data for log file
		logcontent = %Target%,%LastTime%,%CurrentTime%,%LastXP%,%CurrentXP%,%IncreaseSeconds%,%IncreaseXP%,%XPH%,%LastLevel%,%CurrentLevel%
        content = %content% (saving to %XPHLog%
		if (ResetCheck = "savereset") {
		HashLastXP[(Target)] := CurrentXP
  	    HashLastLevel[(Target)] := CurrentLevel
	    HashLastTime[(Target)] := CurrentTime   
		content = %content% `n`n>> resetting checkpoint to current XP!
		}
		content = %content%)
			  	  
		Prompt =
(
%content%

Notes for this entry in XP log:

)
        MouseGetPos, X, Y
		InputBox,LogNote,Save XP Information,%Prompt%,,500,250,X - 100,Y - 600,,30,
		logcontent = %logcontent%,"%LogNote%"`n
		FileAppend, %logcontent%, %XPHLog%  
	  } else { ; Oh, just show it
	  	FunctionShowToolTip(content)	
	  }
	} else { ; see below
	  content = XP has not increased since checkpoint or bad OCR!`n`nCheckpoint: %LastXP% at %LastTime% %ExitStatus%
	  if (ResetCheck = "reset") {
		HashLastXP[(Target)] := CurrentXP
  	    HashLastLevel[(Target)] := CurrentLevel
	    HashLastTime[(Target)] := CurrentTime       
        content = %content%`n`n>> resetting checkpoint to current XP!
	  }	
	  FunctionShowToolTip(content)	  
	}
	clipboard = My %Target% gained XP at %PrettyXPH% XPH over the last %IncreaseSeconds%s, %TimeToLevel% to next level. (+%PrettyIncreaseXP% XP gained at level %CurrentLevel%)		 
}


FunctionFetchXP(ResetCheck) {
  ; Only does anything if POE is the window with focus
  ; Why did I put this in here as well? I dunno. I must've had a reason. I can probably take it out though.
  IfWinActive, Path of Exile ahk_class Direct3DWindowClass
  {
    ; Check and see if the mouse cursor is hovered over a gem
	; Note: This will send a ^c which may activate POE Item Info, etc.
	; It is considered a single in-game action.
	clipboard=
	GemName=
	GemName1=
	Send ^c
	; Wait 100ms for information to go to clipboard
	Sleep, 100
    ; Get the clipboard data and see if there's a Gem in it
	ClipBoardData = %clipboard%	
	Match := RegExMatch(ClipBoardData, "Rarity: Gem`r`n(.*?)`r`n---", GemName)
	
	; If there's gem data, process that, otherwise fall back to OCR for char XP
	if (GemName1 <> "") {
   	  StringReplace, ClipBoardData, ClipBoardData,% Chr(44),, All          ; Strip commas out of clipboard data so regexp works with \d+
	  Match := RegExMatch(ClipBoardData, "Level: (\d+)", GemLevel)
      Match := RegExMatch(ClipBoardData, "Experience: (\d+)/(\d+)", GemXP)
	  HashCurrentXP[(GemName1)] := GemXP1
	  HashNextXP[(GemName1)] := GemXP2
	  HashCurrentLevel[(GemName1)] := GemLevel1
      HashCurrentTime[(GemName1)] := A_Now
	  FunctionTrackXP(GemName1,ClipBoardData,ResetCheck)
    } else {	  
	  FunctionRunOCR(0)   
	  if (OCRcheck = "bad") {
  	    content = XP OCR failed twice, please try a darker area or moving your mouse up/down!
  	    FunctionShowToolTip(content)
	    return   
      } else {	
	    Target = Character
        FunctionTrackXP(Target,ClipBoardData,ResetCheck)
	  }
	}	 
  }
}

FunctionListView() {
    
  Gui, Destroy
;  Gui +Resize    ; This doesn't resize the inside of the box, not sure how to fix that
  Gui, Add, ListView, x0 y0 r%ListRows% w%ListWidth% grid, Target|CheckpointTime|EndTime|cpXP|EndXP|Seconds|XPgain|XPH|cpLevel|EndLevel|Notes
  Loop, read, %XPHLog%
  {
    Loop, parse, A_LoopReadLine, CSV
	{
	  ; I feel like there should be a better way to do this, but I can't find it.
      if A_Index = 1 
	  { 
	    Col1 = %A_LoopField%
      } else if A_Index = 2 
	  { 
	    Col2 = %A_LoopField%
	  } else if A_Index = 3 
	  {
	    Col3 = %A_LoopField%
	  } else if A_Index = 4 
	  {
	    Col4 = %A_LoopField%
      } else if A_Index = 5
	  {
	    Col5 = %A_LoopField%
	  } else if A_Index = 6 
	  {
	    Col6 = %A_LoopField%
	  } else if A_Index = 7
	  {
	    Col7 = %A_LoopField%
      } else if A_Index = 8 
	  {
	    Col8 = %A_LoopField%
      } else if A_Index = 9
	  {
	    Col9 = %A_LoopField%
	  } else if A_Index = 10
	  {
	    Col10 = %A_LoopField%
	  } else if A_Index = 11
	  {
	    Col11 = %A_LoopField%
	  }
    }
	LV_Add("", Col1, Col2, Col3, Col4, Col5, Col6, Col7, Col8, Col9, Col10, Col11)
  }
  GuiControl, +Redraw, MyListView
  LV_ModifyCol()
  LV_ModifyCol(1, "Auto") 
  LV_ModifyCol(2, "Integer") 
  LV_ModifyCol(3, "Integer") 
  LV_ModifyCol(4, "Integer") 
  LV_ModifyCol(5, "Integer") 
  LV_ModifyCol(6, "Integer") 
  LV_ModifyCol(7, "Integer") 
  LV_ModifyCol(8, "Integer") 
  LV_ModifyCol(9, "Integer") 
  LV_ModifyCol(10, "Integer") 
  LV_ModifyCol(11, "Auto") 
  Gui, Show

GuiSize:  ; Expand or shrink the ListView in response to the user's resizing of the window.
if A_EventInfo = 1  ; The window has been minimized.  No action needed.
    return
; Otherwise, the window has been resized or maximized. Resize the ListView to match.
GuiControl, Move, MyListView, % "W" . (A_GuiWidth - 20) . " H" . (A_GuiHeight - 40)
return  

Return

}
