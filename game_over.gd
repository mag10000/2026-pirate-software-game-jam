extends Control


func _on_button_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
	# Logic to reset all amounts to default
	Global.current_work_time_id = 0
	Global.current_break_time_id = 0
	Global.work_time_started = false
	Global.break_time_started = false
	Global.phase = 0
	Global.debt = 1000
	Global.minimumPay = 7
