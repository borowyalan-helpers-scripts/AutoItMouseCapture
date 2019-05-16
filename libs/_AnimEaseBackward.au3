#include <GuiConstants.au3>
#include <AnimationEasing.au3>

; Create a GUI and a label, then show it.
GuiCreate("Easing Test", 391, 32)
$TestLabel = GuiCtrlCreateLabel("Animation Position", 10, 10, 380, 20)
GuiSetState()

; Loop through the animation.
For $i = 0 To 100
	; Compute the animation.
	$nCurrentPosition = _AnimEaseBackward($i / 100, 2) * 100
	; Set the data and position of the label.
	GUICtrlSetData ($TestLabel, "Current Frame: " & $i & "; Current Position: " & $nCurrentPosition)
	GUICtrlSetPos ($TestLabel, 10 + $nCurrentPosition, 10);
	; Sleep for a bit.
	Sleep (10)
Next

; Sleep for a little bit more before ending the script.
Sleep (1000)
Exit
