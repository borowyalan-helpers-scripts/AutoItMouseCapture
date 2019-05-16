#include-once
#include <AnimationEasing.au3>

;===============================================================================
;
; Description:      Moves the mouse more smoothly, with some random movements.
; Parameter(s):     $iX - The target X position.
;                   $iY - The target Y position.
; Requirement(s):   The _AnimEaseInOut and _AnimEaseBackward function.
; Return Value(s):  None.
; Author(s):        the DtTvB
; Note(s):
;
;===============================================================================
Func _MouseMove($iX, $iY)
	Local $x1 = MouseGetPos(0)
	Local $y1 = MouseGetPos(1)
	Local $xv = Random(-100, 100)
	Local $yv = Random(-100, 100)
	Local $sm = Random(1.5, 2.5)
	Local $m = Random(50, 160)
	Local $ci, $co, $cx, $cy
	for $i = 0 to $m
		$ci = _AnimEaseInOut($i / $m, $sm)
		$co = _AnimEaseBackward($i / $m, $sm)
		$cx = $x1 + (($iX - $x1) * $ci) + ($xv * $co)
		$cy = $y1 + (($iY - $y1) * $ci) + ($yv * $co)
		MouseMove ($cx, $cy, 1)
	Next
EndFunc