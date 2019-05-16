#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <File.au3>
#include <.\libs\_Mouse_UDF.au3>
#include <.\libs\MouseOnEvent.au3>

$hOPO = FileOpen(".\Exec.au3", 2)
$hOP = FileOpen(".\Exec.au3", 1)

HotKeySet("+9", "RunRecordingFunction")
HotKeySet("+0", "RunExecFunction")
HotKeySet("+c", "_ClearExec")


If _Singleton("Helper", 1) = 0 Then
    MsgBox($MB_SYSTEMMODAL, "Warning", "Helper is already running.")
    Exit
EndIf

Func RunExecFunction()
   _RunAu3("Exec.au3")
EndFunc

Func RunRecordingFunction()
   _RunAu3("Recording.au3")
EndFunc

Func _RunAU3($sFilePath, $sWorkingDir = "", $iShowFlag = @SW_SHOW, $iOptFlag = 0)
    Return Run('"' & @AutoItExe & '" /AutoIt3ExecuteScript "' & $sFilePath & '"', $sWorkingDir, $iShowFlag, $iOptFlag)
 EndFunc   ;==>_RunAU3

Func _ClearExec()
   FileWrite($hOPO, "#include <.\libs\_Quit.au3>" & @CRLF & "#include <.\libs\_Pause.au3>" & @CRLF & @CRLF)
EndFunc

While 1
   Sleep(20)
WEnd

