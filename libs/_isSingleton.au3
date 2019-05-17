#include <Misc.au3>

If _Singleton("Recording", 1) = 0 Then
    MsgBox($MB_SYSTEMMODAL, "Warning", "Recording script is already running")
    Exit
EndIf

If _Singleton("Exec", 1) = 0 Then
    MsgBox($MB_SYSTEMMODAL, "Warning", "Exec script is already running")
    Exit
EndIf