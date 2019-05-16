#include <Misc.au3>

; public
Global Const $EVENT_MOUSE_IDLE			= 0x1000
Global Const $EVENT_MOUSE_MOVE			= 0x1001
Global Const $EVENT_PRIMARY_CLICK		= 0x1002
Global Const $EVENT_PRIMARY_DBLCLICK	= 0x1003
Global Const $EVENT_PRIMARY_RELEASED	= 0x1004
Global Const $EVENT_PRIMARY_DOWN		= 0x1005
Global Const $EVENT_PRIMARY_UP			= 0x1006
Global Const $EVENT_SECONDARY_CLICK		= 0x1007
Global Const $EVENT_SECONDARY_DBLCLICK	= 0x1008
Global Const $EVENT_SECONDARY_RELEASED	= 0x1009
Global Const $EVENT_SECONDARY_DOWN		= 0x1010
Global Const $EVENT_SECONDARY_UP		= 0x1011
Global Const $EVENT_MIDDLE_CLICK		= 0x1012
Global Const $EVENT_MIDDLE_DBLCLICK		= 0x1013
Global Const $EVENT_MIDDLE_RELEASED		= 0x1014
Global Const $EVENT_MIDDLE_DOWN			= 0x1015
Global Const $EVENT_MIDDLE_UP			= 0x1016
Global Const $EVENT_X1_CLICK			= 0x1017
Global Const $EVENT_X1_DBLCLICK			= 0x1018
Global Const $EVENT_X1_RELEASED			= 0x1019
Global Const $EVENT_X1_DOWN				= 0x1020
Global Const $EVENT_X1_UP				= 0x1021
Global Const $EVENT_X2_CLICK			= 0x1022
Global Const $EVENT_X2_DBLCLICK			= 0x1023
Global Const $EVENT_X2_RELEASED			= 0x1024
Global Const $EVENT_X2_DOWN				= 0x1025
Global Const $EVENT_X2_UP				= 0x1026

Global Const $COLOR_DEC					= 0x2000
Global Const $COLOR_HEX					= 0x2001
Global Const $COLOR_RGB					= 0x2002

Global $MOUSE_X = 0, $MOUSE_Y = 0
Global $MOUSE_PREV_X = 0, $MOUSE_PREV_Y = 0
Global $MOUSE_VEL_X = 0, $MOUSE_VEL_Y = 0

; private
Global $Q__avRegisteredEvents[1][3]
$Q__avRegisteredEvents[0][0] = -1

Global $Q__iRunTimer = TimerInit()
Global $Q__abOldStates[5], $Q__abNewStates[5]
Global $Q__aiFirstClicks[5], $Q__aiSecondClicks[5]
Global $Q__abFirstSecondSwitches[5]

Global $Q__iDoubleClickDelay = 400

; forced init
Q__Initialize()

Func Q__Initialize()
	Local $Q__aiMousePos = MouseGetPos()
	$MOUSE_X = $Q__aiMousePos[0]
	$MOUSE_Y = $Q__aiMousePos[1]

	For $i = 0 To 4
		$Q__abOldStates[$i] = False
		$Q__abNewStates[$i] = False
		$Q__aiFirstClicks[$i] = -1
		$Q__aiSecondClicks[$i] = -1
		$Q__abFirstSecondSwitches[$i] = True
	Next
EndFunc

Func _Mouse_Update()
	Local $aiMousePosition = MouseGetPos()

	$MOUSE_PREV_X = $MOUSE_X
	$MOUSE_PREV_Y = $MOUSE_Y
	$MOUSE_X = $aiMousePosition[0]
	$MOUSE_Y = $aiMousePosition[1]
	$MOUSE_VEL_X = ($MOUSE_X - $MOUSE_PREV_X)
	$MOUSE_VEL_Y = ($MOUSE_Y - $MOUSE_PREV_Y)

	Local $j = 1
	For $i = 0 To 4
		$Q__abOldStates[$i] = $Q__abNewStates[$i]
		$Q__abNewStates[$i] = _IsPressed($j)

		If (__CheckMouseClick($i)) Then
			If ($Q__abFirstSecondSwitches[$i]) Then
				$Q__aiFirstClicks[$i] = TimerDiff($Q__iRunTimer)
			Else
				$Q__aiSecondClicks[$i] = TimerDiff($Q__iRunTimer)
			EndIf

			$Q__abFirstSecondSwitches[$i] = Not $Q__abFirstSecondSwitches[$i]
		EndIf

		$j += 1
		If ($j == 3) Then $j += 1
	Next

	For $i = 0 To UBound($Q__avRegisteredEvents) - 1
		If ($i == UBound($Q__avRegisteredEvents)) Then ExitLoop

		If ($Q__avRegisteredEvents[$i][0] <> -1) Then
			__HandleEvent($i)
		EndIf
	Next

	Return 1
EndFunc

Func _Mouse_RegisterEvent($iEventType, $sCallBack, $avArgs = -1)
	If (Not IsInt($iEventType)) Then Return SetError(1, 0, -1)
	If (($iEventType < 0x1000) Or ($iEventType > 0x1026)) Then Return SetError(2, 0, -1)
	If (Not __IsValidFunction($sCallBack)) Then Return SetError(3, 0, -1)

	Local $iLength = UBound($Q__avRegisteredEvents)
	$Q__avRegisteredEvents[$iLength - 1][0] = $iEventType
	$Q__avRegisteredEvents[$iLength - 1][1] = $sCallBack
	$Q__avRegisteredEvents[$iLength - 1][2] = $avArgs

	ReDim $Q__avRegisteredEvents[$iLength + 1][3]
	$Q__avRegisteredEvents[$iLength][0] = -1

	Return 1
EndFunc

Func _Mouse_UnRegisterEvent($iEventType)
	If (Not IsInt($iEventType)) Then Return SetError(1, 0, -1)
	If (($iEventType < 0x1000) Or ($iEventType > 0x1026)) Then Return SetError(2, 0, -1)

	Local $iIndex = 0
	Local $iLength = UBound($Q__avRegisteredEvents)
	For $i = 0 To $iLength - 1
		If ($Q__avRegisteredEvents[$i][0] == $iEventType) Then $iIndex = $i
	Next

	Local $iSubLength = UBound($Q__avRegisteredEvents, 2)
	For $i = $iIndex To $iLength - 2
		For $j = 0 To $iSubLength - 1
			$Q__avRegisteredEvents[$i][$j] = $Q__avRegisteredEvents[$i + 1][$j]
		Next
	Next

	ReDim $Q__avRegisteredEvents[$iLength - 1][$iSubLength]

	Return 1
EndFunc

Func _Mouse_GetColor($iColorType, $hWnd = Default)
	If (($iColorType < 0x2000) Or ($iColorType > 0x2002)) Then Return SetError(1, 0, -1)

	Local $iDec = PixelGetColor($MOUSE_X, $MOUSE_Y, $hWnd)
	Local $iHex = "0x" & Hex($iDec, 6)
	Local $aiRGB[3] = [BitAND(BitShift($iHex, 16), 0xFF), BitAND(BitShift($iHex, 8), 0xFF), BitAND($iHex, 0xFF)]

	Switch ($iColorType)
		Case $COLOR_DEC
			Return $iDec

		Case $COLOR_HEX
			Return $iHex

		Case $COLOR_RGB
			Return $aiRGB

	EndSwitch
EndFunc

; === internal use ===
Func __IsValidFunction($sFunction)
	If (Not IsString($sFunction)) Then Return False
	If (Not StringRegExp($sFunction, "^[a-zA-Z_][a-zA-Z0-9_]*$")) Then Return False

	Return True
EndFunc

Func __HandleEvent($iIndex)
	Switch ($Q__avRegisteredEvents[$iIndex][0])
		Case $EVENT_MOUSE_IDLE
			If (__CheckMouseIdle()) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_MOUSE_MOVE
			If (__CheckMouseMove()) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_PRIMARY_CLICK
			If (__CheckMouseClick(0)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_PRIMARY_DBLCLICK
			If (__CheckMouseDblClick(0)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_PRIMARY_RELEASED
			If (__CheckMouseReleased(0)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_PRIMARY_DOWN
			If (__CheckMouseDown(0)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_PRIMARY_UP
			If (__CheckMouseUp(0)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_SECONDARY_CLICK
			If (__CheckMouseClick(1)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_SECONDARY_DBLCLICK
			If (__CheckMouseDblClick(1)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_SECONDARY_RELEASED
			If (__CheckMouseReleased(1)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_SECONDARY_DOWN
			If (__CheckMouseDown(1)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_SECONDARY_UP
			If (__CheckMouseUp(1)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_MIDDLE_CLICK
			If (__CheckMouseClick(2)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_MIDDLE_DBLCLICK
			If (__CheckMouseDblClick(2)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_MIDDLE_RELEASED
			If (__CheckMouseReleased(2)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_MIDDLE_DOWN
			If (__CheckMouseDown(2)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_MIDDLE_UP
			If (__CheckMouseUp(2)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_X1_CLICK
			If (__CheckMouseClick(3)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_X1_DBLCLICK
			If (__CheckMouseDblClick(3)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_X1_RELEASED
			If (__CheckMouseReleased(3)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_X1_DOWN
			If (__CheckMouseDown(3)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_X1_UP
			If (__CheckMouseUp(3)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_X2_CLICK
			If (__CheckMouseClick(4)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_X2_DBLCLICK
			If (__CheckMouseDblClick(4)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_X2_RELEASED
			If (__CheckMouseReleased(4)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_X2_DOWN
			If (__CheckMouseDown(4)) Then
				__CallFunction($iIndex)
			EndIf

		Case $EVENT_X2_UP
			If (__CheckMouseUp(4)) Then
				__CallFunction($iIndex)
			EndIf
	EndSwitch
EndFunc

Func __CallFunction($iIndex)
	If ($Q__avRegisteredEvents[$iIndex][2] == -1) Then
		Call($Q__avRegisteredEvents[$iIndex][1])
	Else
		Call($Q__avRegisteredEvents[$iIndex][1], $Q__avRegisteredEvents[$iIndex][2])
	EndIf
EndFunc

Func __CheckMouseIdle()
	Return (($MOUSE_PREV_X == $MOUSE_X) And ($MOUSE_PREV_Y == $MOUSE_Y))
EndFunc

Func __CheckMouseMove()
	Return (($MOUSE_PREV_X <> $MOUSE_X) Or ($MOUSE_PREV_Y <> $MOUSE_Y))
EndFunc

Func __CheckMouseClick($iIndex)
	Return ($Q__abNewStates[$iIndex] And (Not $Q__abOldStates[$iIndex]))
EndFunc

Func __CheckMouseDblClick($iIndex)
	If (($Q__aiFirstClicks[$iIndex] == -1) Or ($Q__aiSecondClicks[$iIndex] == -1)) Then Return False

	If ((Abs($Q__aiSecondClicks[$iIndex] - $Q__aiFirstClicks[$iIndex]) < $Q__iDoubleClickDelay) Or (Abs($Q__aiFirstClicks[$iIndex] - $Q__aiSecondClicks[$iIndex]) < $Q__iDoubleClickDelay)) Then
		$Q__aiFirstClicks[$iIndex] = -1
		$Q__aiSecondClicks[$iIndex] = -1
		$Q__iRunTimer = TimerInit()

		Return True
	EndIf

	Return False
EndFunc

Func __CheckMouseReleased($iIndex)
	Return ((Not $Q__abNewStates[$iIndex]) And $Q__abOldStates[$iIndex])
EndFunc

Func __CheckMouseDown($iIndex)
	Return $Q__abNewStates[$iIndex]
EndFunc

Func __CheckMouseUp($iIndex)
	Return (Not $Q__abNewStates[$iIndex])
EndFunc