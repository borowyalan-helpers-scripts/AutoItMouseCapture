#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <File.au3>
#include <.\libs\MouseOnEvent.au3>

HotKeySet("+1", "_Quit")
HotKeySet("o", "_StartRecordingMode")

; handles
$dll = DllOpen("user32.dll")
$hOP = FileOpen("Exec.au3", 1)

; CurveDrag Variables
Global $isRecordingMode = False
Global $isRecording = False
Global $aPrevPos[2] = [0, 0]
Global $avPrevMousePos[2] = [0,0]

; Don't allow multiple instances
If _Singleton("Start", 1) = 0 Then
    MsgBox($MB_SYSTEMMODAL, "Warning", "The script is already running")
    Exit
EndIf

; -------------------------------------------------------------------------------------------------------------------------------

; Main Loop
While 1
    Sleep(10)
    If $isRecordingMode And $isRecording Then
        _CurveDragStart()
    EndIf
WEnd

; DragMode
Func _StartRecordingMode()
    If Not $isRecordingMode Then
        $isRecordingMode = True
        ToolTip("Recording Mode on!")
        _MouseSetOnEvent($MOUSE_PRIMARYDOWN_EVENT, "_CurveDragHelper")
        _MouseSetOnEvent($MOUSE_PRIMARYUP_EVENT, "_CurveDragHelper")
        _MouseSetOnEvent($MOUSE_SECONDARYDOWN_EVENT, "_SecondaryClick")
        _MouseSetOnEvent($MOUSE_WHEELSCROLLDOWN_EVENT, "_MouseScrollDown")
        _MouseSetOnEvent($MOUSE_WHEELSCROLLUP_EVENT, "_MouseScrollUp")
		_MouseSetOnEvent($MOUSE_SECONDARYDOWN_EVENT, "_SecondaryClick")
    Else
        $isRecordingMode = False
        ToolTip("Recording Mode off")
        _MouseSetOnEvent($MOUSE_PRIMARYDOWN_EVENT, "")
        _MouseSetOnEvent($MOUSE_PRIMARYUP_EVENT, "")
        _MouseSetOnEvent($MOUSE_SECONDARYDOWN_EVENT, "")
        _MouseSetOnEvent($MOUSE_WHEELSCROLLDOWN_EVENT, "")
        _MouseSetOnEvent($MOUSE_WHEELSCROLLUP_EVENT, "")
		_MouseSetOnEvent($MOUSE_SECONDARYDOWN_EVENT, "")
    EndIf
EndFunc

; Click
Func _SecondaryClick()
        $avMousePos = MouseGetPos()
        ToolTip("x = " & $avMousePos[0] & "  y = " & $avMousePos[1])
        FileWriteLine($hOP, "MouseMove(" & $avMousePos[0]& ", "  & $avMousePos[1] & ")" & @CRLF)
        FileWriteLine($hOP, "MouseClick(" & '"' & "secondary" & '"'& ")" & CRLF)
        FileWriteLine($hOP, "_TogglePause()")
        ToolTip("Registered RMB")
EndFunc

; Scrolls
Func _MouseScrollDown()
    FileWriteLine($hOP, "MouseWheel(" & '"' & "down" & '"' & "," & "1" & ")" & @CRLF)
    FileWriteLine($hOP, "Sleep(10))" & @CRLF)
EndFunc

Func _MouseScrollUp()
    FileWriteLine($hOP, "MouseWheel(" & '"' & "up" & '"' & "," & "1" & ")" & @CRLF)
    FileWriteLine($hOP, "Sleep(10)" & @CRLF)
EndFunc

; DragFunction
Func _CurveDragHelper()
    If $isRecordingMode Then
        If Not $isRecording Then
            $isRecording = True
        Else
            $isRecording = False
        EndIf
    EndIf
EndFunc

Func _CurveDragStart()
    $avMousePos = MouseGetPos()
    FileWriteLine($hOP, "MouseMove(" & $avMousePos[0]& ", "  & $avMousePos[1] & ")"  & @CRLF)
    If $avMousePos[0] = $avPrevMousePos[0] And $avMousePos[1] = $avPrevMousePos[1] Then
        FileWrite($hOP, "Sleep(5)" & @CRLF)
    Else
        FileWrite($hOP, "Sleep(200)" & @CRLF)
    EndIf
    FileWrite($hOP, "MouseDown(" & '"' & "primary" & '"' & ")"  & @CRLF)

    While $isRecording
        $aPos = MouseGetPos()
        If $aPos[0] <> $aPrevPos[0] Or $aPos[1] <> $aPrevPos[1] And $aPos[0] <> $avMousePos[0] Then
            FileWriteLine($hOP, "MouseMove(" & $aPos[0]& ", "  & $aPos[1] & "," & "0" & ")"  & @CRLF)
            FileWriteLine($hOP, "Sleep(10)" & @CRLF)
        EndIf
        $aPrevPos = $aPos
        Sleep(5)
    WEnd
    FileWriteLine($hOP, "MouseUp(" & '"' & "primary" & '"' & ")" & @CRLF)
    $isRecording = False
    $avPrevMousePos = $avMousePos
    FileWriteLine($hOP, "_TogglePause()" & @CRLF & @CRLF)
    ToolTip("Registered")
EndFunc

; Script Utilities
Func _Quit()
    DllClose($dll)
    FileClose($hOP)
    Exit
EndFunc