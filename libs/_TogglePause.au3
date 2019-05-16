HotKeySet("t", "_UntogglePause")

$Paused = True

Func _TogglePause()
    While $Paused
        sleep(100)
        ToolTip('Script is "Paused"',0,0)
    WEnd
    ToolTip("")
 EndFunc

Func _UntogglePause()
   $Paused = False
EndFunc