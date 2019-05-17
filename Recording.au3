; AutoIt Helper Files
#include <Misc.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>

; Custom Helper Files
#include <.\libs\MouseOnEvent.au3>
#include <.\libs\_isSingleton.au3>

HotKeySet("q", "_Quit")
HotKeySet("r", "_StartRecordingMode")
HotKeySet("+c", "_ClearExec")

; handles
$dll = DllOpen("user32.dll")
Global $hOP = 0

; Variables
Global $isRecordingMode = False

; PrimaryClick Variables
Global $isRecordingLMB = False
Global $aPrevPos[2] = [0, 0]
Global $avPrevMousePos[2] = [0,0]

; WheelClick Variables
Global $isRecordingWheelClick = False


; -------------------------------------------------------------------------------------------------------------------------------

; Main Loop
While 1
    Sleep(50)
    If $isRecordingMode And $isRecordingLMB Then
        _PrimaryClick()
    EndIf
    If $isRecordingMode And $isRecordingWheelClick Then
        _WheelClick()
    EndIf
WEnd

; Get ready for recording & set MouseEvent handlers
Func _StartRecordingMode()
    If Not $isRecordingMode Then
	  $hOP = FileOpen("Exec.au3", 1)  ; Append
	  $isRecordingMode = True
	  ToolTip("Recording Mode on!")
	  _MouseSetOnEvent($MOUSE_PRIMARYDOWN_EVENT, "_StartRecordingLMB")
	  _MouseSetOnEvent($MOUSE_PRIMARYUP_EVENT, "_StopRecordingLMB")
	  _MouseSetOnEvent($MOUSE_SECONDARYDOWN_EVENT, "_SecondaryClick")
	  _MouseSetOnEvent($MOUSE_WHEELSCROLLDOWN_EVENT, "_MouseScrollDown")
	  _MouseSetOnEvent($MOUSE_WHEELSCROLLUP_EVENT, "_MouseScrollUp")
	  _MouseSetOnEvent($MOUSE_SECONDARYDOWN_EVENT, "_SecondaryClick")
	  _MouseSetOnEvent($MOUSE_WHEELDOWN_EVENT, "_StartRecordingWheelClick")
	  _MouseSetOnEvent($MOUSE_WHEELUP_EVENT, "_StopRecordingWheelClick")

    Else
        $isRecordingMode = False
        ToolTip("Recording Mode off")
        _MouseSetOnEvent($MOUSE_PRIMARYDOWN_EVENT)
        _MouseSetOnEvent($MOUSE_PRIMARYUP_EVENT)
        _MouseSetOnEvent($MOUSE_SECONDARYDOWN_EVENT)
        _MouseSetOnEvent($MOUSE_WHEELSCROLLDOWN_EVENT)
        _MouseSetOnEvent($MOUSE_WHEELSCROLLUP_EVENT)
		_MouseSetOnEvent($MOUSE_SECONDARYDOWN_EVENT)
        _MouseSetOnEvent($MOUSE_WHEELDOWN_EVENT)
		_MouseSetOnEvent($MOUSE_WHEELUP_EVENT)
    EndIf
EndFunc

; Handle RMB Click
Func _SecondaryClick()
    $avMousePos = MouseGetPos()
    FileWriteLine($hOP, "MouseMove(" & $avMousePos[0]& ", "  & $avMousePos[1] & ")" & @CRLF)
    FileWriteLine($hOP, "MouseClick(" & '"' & "secondary" & '"'& ")" & @CRLF)
    FileWriteLine($hOP, "_TogglePause()" & @CRLF & @CRLF)
    ToolTip("Registered RMB")
EndFunc

Func _DoubleClick()
    FileWriteLine($hOP, "MouseUp(" & '"' & "primary" & '"' & ")" & @CRLF)
EndFunc

; Handle Scrolls
Func _MouseScrollDown()
    FileWriteLine($hOP, "MouseWheel(" & '"' & "down" & '"' & "," & "1" & ")" & @CRLF)
    FileWriteLine($hOP, "Sleep(10))" & @CRLF)
EndFunc

Func _MouseScrollUp()
    FileWriteLine($hOP, "MouseWheel(" & '"' & "up" & '"' & "," & "1" & ")" & @CRLF)
    FileWriteLine($hOP, "Sleep(10)" & @CRLF)
EndFunc

; Handle LMB & LMB drag
Func _StartRecordingLMB()
    $isRecordingLMB= True
EndFunc

Func _StopRecordingLMB()
    $isRecordingLMB= False
EndFunc

Func _StartRecordingWheelClick()
    $isRecordingWheelClick= True
EndFunc

Func _StopRecordingWheelClick()
    $isRecordingWheelClick= False
EndFunc

Func _PrimaryClick()
    $avMousePos = MouseGetPos()

    ; click in the exact same place
    If $avMousePos[0] = $avPrevMousePos[0] And $avMousePos[1] = $avPrevMousePos[1] Then
        _DoubleClick()
        Return True
    EndIf

    FileWriteLine($hOP, "MouseMove(" & $avMousePos[0]& ", "  & $avMousePos[1] & ")"  & @CRLF)
    FileWrite($hOP, "Sleep(200)" & @CRLF)
    FileWrite($hOP, "MouseDown(" & '"' & "primary" & '"' & ")"  & @CRLF)

    ; save Mouse movement while MouseDown
    While $isRecordingLMB
        $aPos = MouseGetPos()
        If $aPos[0] <> $aPrevPos[0] Or $aPos[1] <> $aPrevPos[1] And $aPos[0] <> $avMousePos[0] Then
            FileWriteLine($hOP, "MouseMove(" & $aPos[0]& ", "  & $aPos[1] & "," & "0" & ")"  & @CRLF)
            FileWriteLine($hOP, "Sleep(10)" & @CRLF)
        EndIf
        $aPrevPos = $aPos
        Sleep(5)
    WEnd

    FileWriteLine($hOP, "MouseUp(" & '"' & "primary" & '"' & ")" & @CRLF)
    $avPrevMousePos = $avMousePos
    FileWriteLine($hOP, "_TogglePause()" & @CRLF & @CRLF)
    ToolTip("Registered")
EndFunc

Func _WheelClick()
    $avMousePos = MouseGetPos()

    FileWriteLine($hOP, "MouseMove(" & $avMousePos[0]& ", "  & $avMousePos[1] & ")"  & @CRLF)
    FileWrite($hOP, "Sleep(200)" & @CRLF)
    FileWrite($hOP, "MouseDown(" & '"' & "middle" & '"' & ")"  & @CRLF)

    ; save Mouse movement while MouseDown
    While $isRecordingWheelClick
        $aPos = MouseGetPos()
        If $aPos[0] <> $aPrevPos[0] Or $aPos[1] <> $aPrevPos[1] And $aPos[0] <> $avMousePos[0] Then
            FileWriteLine($hOP, "MouseMove(" & $aPos[0]& ", "  & $aPos[1] & "," & "0" & ")"  & @CRLF)
            FileWriteLine($hOP, "Sleep(10)" & @CRLF)
        EndIf
        $aPrevPos = $aPos
        Sleep(5)
    WEnd

    FileWriteLine($hOP, "MouseUp(" & '"' & "middle" & '"' & ")" & @CRLF)
    $avPrevMousePos = $avMousePos
    FileWriteLine($hOP, "_TogglePause()" & @CRLF & @CRLF)
    ToolTip("Registered")
EndFunc

; Script Utilities
Func _Quit()
    DllClose($dll)
    Exit
EndFunc

Func _ClearExec()
    $hOPO = FileOpen("Exec.au3", 2) ; Overwrite
    FileWrite($hOPO, "#include <.\libs\_Quit.au3>" & @CRLF & "#include <.\libs\_Pause.au3>" & @CRLF & "#include <.\libs\_isSingleton.au3>" & @CRLF & @CRLF)
    ToolTip("Exec cleared")
    FileClose($hOPO)
EndFunc

