HotKeySet("t", "_UntogglePause")

$Paused = True

Func _TogglePause()
   $Paused = True
    While $Paused
        sleep(100)
    WEnd
 EndFunc

Func _UntogglePause()
   $Paused = False
EndFunc