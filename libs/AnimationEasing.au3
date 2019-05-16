#include-once

;===============================================================================
;
; Description:      Ease In - Used in animations that starts smoothly.
; Parameter(s):     $nPosition   - Animation position: A number between 0 and 1.
;                   $nSmoothness - Smoothness: A number that is not less than 1.
;                                  The default is 2, and is the recommended value.
; Requirement(s):   None
; Return Value(s):  The calculated position: A number between 0 and 1.
; Author(s):        the DtTvB
; Note(s):          This function is required for _AnimEaseInOut and _AnimEaseBackward to work properly.
;
;===============================================================================
Func _AnimEaseIn($nPosition, $nSmoothness = 2)
	Return $nPosition ^ $nSmoothness;
EndFunc

;===============================================================================
;
; Description:      Ease Out - Used in animations that ends smoothly.
; Parameter(s):     $nPosition   - Animation position: A number between 0 and 1.
;                   $nSmoothness - Smoothness: A number that is not less than 1.
;                                  The default is 2, and is the recommended value.
; Requirement(s):   None
; Return Value(s):  The calculated position: A number between 0 and 1.
; Author(s):        the DtTvB
; Note(s):          This function is required for _AnimEaseInOut and _AnimEaseBackward to work properly.
;
;===============================================================================
Func _AnimEaseOut($nPosition, $nSmoothness = 2)
	Return 1 - ((1 - $nPosition) ^ $nSmoothness)
EndFunc

;===============================================================================
;
; Description:      Ease In-Out - Used in animations that starts and ends smoothly.
; Parameter(s):     $nPosition   - Animation position: A number between 0 and 1.
;                   $nSmoothness - Smoothness: A number that is not less than 1.
;                                  The default is 2, and is the recommended value.
; Requirement(s):   The _AnimEaseIn and _AnimEaseOut function.
; Return Value(s):  The calculated position: A number between 0 and 1.
; Author(s):        the DtTvB
; Note(s):          This function is required for _AnimEaseBackward to work properly.
;
;===============================================================================
Func _AnimEaseInOut($nPosition, $nSmoothness = 2)
	If ($nPosition < 0.5) then
		Return _AnimEaseIn($nPosition * 2, $nSmoothness) / 2
	Else
		Return (_AnimEaseOut(($nPosition - 0.5) * 2, $nSmoothness) / 2) + 0.5
	EndIf
EndFunc

;===============================================================================
;
; Description:      Ease Backward - Used in animations that starts and and at the same point with some smoothness.
; Parameter(s):     $nPosition   - Animation position: A number between 0 and 1.
;                   $nSmoothness - Smoothness: A number that is not less than 1.
;                                  The default is 2, and is the recommended value.
; Requirement(s):   The _AnimEaseIn, _AnimEaseOut, and _AnimEaseInOut function.
; Return Value(s):  The calculated position: A number between 0 and 1.
; Author(s):        the DtTvB
; Note(s):
;
;===============================================================================
Func _AnimEaseBackward($nPosition, $nSmoothness = 2)
	If ($nPosition < 0.5) then
		Return _AnimEaseInOut($nPosition * 2, $nSmoothness)
	Else
		Return _AnimEaseInOut((1 - $nPosition) * 2, $nSmoothness)
	EndIf
EndFunc