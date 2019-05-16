#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <File.au3>
#include <.\libs\MouseOnEvent.au3>

HotKeySet("+1", "_Quit")
HotKeySet("o", "_CurveDragMode")

; handles
$dll = DllOpen("user32.dll")
$hOP = FileOpen("Exec.au3", 1)

; CurveDrag Variables
Global $isCurveDragMode = False
Global $StartCurveFlag = False
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
    If $isCurveDragMode And $StartCurveFlag Then
        _CurveDragStart()
    EndIf
WEnd

; Click
Func _SecondaryClick()
    If $isCurveDragMode Then
        $avMousePos = MouseGetPos()
        ToolTip("x = " & $avMousePos[0] & "  y = " & $avMousePos[1])
        $sFormattedLine= "MouseMove(" & $avMousePos[0]& ", "  & $avMousePos[1] & ")"
        FileWriteLine($hOP, $sFormattedLine)
        ToolTip("")
        $sFormattedLineSecondary= "MouseClick(" & '"' & "secondary" & '"'& ")"
        FileWriteLine($hOP, $sFormattedLineSecondary)
        FileWriteLine($hOP, "_TogglePause()")
        ToolTip("Registered RMB")
    EndIf
EndFunc

; Scrolls
Func _MouseScrollDown()
    $sFormattedLineWheelDown = "MouseWheel(" & '"' & "down" & '"' & "," & "1" & ")" & @CRLF
    FileWriteLine($hOP, $sFormattedLineWheelDown)
    FileWriteLine($hOP, "Sleep(10))" & @CRLF
EndFunc

Func _MouseScrollUp()
    $sFormattedLineWheelUp= "MouseWheel(" & '"' & "up" & '"' & "," & "1" & ")" & @CRLF
    FileWriteLine($hOP, $sFormattedLineWheelUp)
    FileWriteLine($hOP, "Sleep(10)" & @CRLF)    
EndFunc

; DragModes
Func _CurveDragMode()
    If Not $isCurveDragMode Then
        $isCurveDragMode = True
        ToolTip("Curve Drag mode on")
        _MouseSetOnEvent($MOUSE_PRIMARYDOWN_EVENT, "_CurveDragHelper")
        _MouseSetOnEvent($MOUSE_PRIMARYUP_EVENT, "_CurveDragHelper")
        _MouseSetOnEvent($MOUSE_SECONDARYDOWN_EVENT, "_SecondaryClick")
        _MouseSetOnEvent($MOUSE_WHEELSCROLLDOWN_EVENT, "_MouseScrollDown")
        _MouseSetOnEvent($MOUSE_WHEELSCROLLUP_EVENT, "_MouseScrollUp")
        ConsoleWrite("CurveDragMode is on" & @CRLF)
    Else
        $isCurveDragMode = False
        ToolTip("Curve Drag mode off")
        _MouseSetOnEvent($MOUSE_PRIMARYDOWN_EVENT, "")
        _MouseSetOnEvent($MOUSE_PRIMARYUP_EVENT, "")
        _MouseSetOnEvent($MOUSE_SECONDARYDOWN_EVENT, "")
    EndIf
EndFunc

; DragFunction
Func _CurveDragHelper()
    If $isCurveDragMode Then
        If Not $StartCurveFlag Then
            $StartCurveFlag = True
        Else
            $StartCurveFlag = False
        EndIf
    EndIf
EndFunc

Func _CurveDragStart()
    $avMousePos = MouseGetPos()
    $sFormattedLine= "MouseMove(" & $avMousePos[0]& ", "  & $avMousePos[1] & ")"  & @CRLF
    FileWriteLine($hOP, $sFormattedLine)
    If $avMousePos[0] = $avPrevMousePos[0] And $avMousePos[1] = $avPrevMousePos[1] Then
        FileWrite($hOP, "Sleep(5)" & @CRLF)
    Else
        FileWrite($hOP, "Sleep(200)" & @CRLF)
    EndIf
    $sFormattedMouseDown = "MouseDown(" & '"' & "primary" & '"' & ")"  & @CRLF
    FileWrite($hOP, $sFormattedMouseDown)

    While $StartCurveFlag
        $aPos = MouseGetPos()
        If $aPos[0] <> $aPrevPos[0] Or $aPos[1] <> $aPrevPos[1] And $aPos[0] <> $avMousePos[0] Then
            $sFormattedLineCurveDrag = "MouseMove(" & $aPos[0]& ", "  & $aPos[1] & "," & "0" & ")"  & @CRLF
            FileWriteLine($hOP, $sFormattedLineCurveDrag)
            FileWriteLine($hOP, "Sleep(10)" & @CRLF)
        EndIf
        $aPrevPos = $aPos
        Sleep(5)
    WEnd
    $sFormattedMouseUp = "MouseUp(" & '"' & "primary" & '"' & ")" & @CRLF
    FileWriteLine($hOP, $sFormattedMouseUp)
    $StartCurveFlag = False
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


