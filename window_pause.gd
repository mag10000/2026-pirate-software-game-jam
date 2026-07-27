extends Window


func _unhandled_input(event):
	if Input.is_action_just_pressed("pause"):
		$"..".pause()
	if Input.is_action_just_pressed("debug"):
		$"..".debug()
