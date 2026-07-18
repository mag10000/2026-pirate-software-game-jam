extends Control

var money = 0.00

var time = 0

var break_text_shown = false

var deposited_in_round = 0

func _process(delta):
	if ("$" + str(money)).length() == 4:
		$"bank account window/Money Display".text = "$" + str(money) + "0"
	else:
		$"bank account window/Money Display".text = "$" + str(money)
	
	if not Global.current_time_started && Global.phase == 0:
		Global.current_time_started = true
		time = Global.times[Global.current_time_id] + randi_range(1,5)
		$"work timer".start()
		$Label.text = "It's Work Time!!!"
		$"break timer".stop()
		$"bank account window".title = "Bank Account"
		$"bank account window/debt/deposit".hide()
		$"bank account window/debt/Min Debt".hide()
		print("TEST")
		$Label/AnimationPlayer.play()
	if Global.current_time_started && Global.phase == 0:
		if time == 0:
			$"work timer".stop()
			Global.current_time_started = false
			if Global.times.size() - 1 == Global.current_time_id:
				Global.current_time_id = 0
			Global.current_time_id += 1
			Global.phase = 1
			$"work window".title = "Work - Time Up!"
			await get_tree().create_timer(0.5).timeout
			$"work window".hide()
			$"bank account window/debt/deposit".show()
			$"bank account window/debt/Min Debt".show()
		else:
			
			$"work window".title = "Work - " + seconds2hhmmss(time)
	if Global.phase == 1:
		print("Hello") 
		if not break_text_shown:
			time = Global.times[Global.current_time_id] + randi_range(1,5)
			deposited_in_round = 0
			$"break timer".start()
			print("hi")
			
			$Label.text = "It's Break Time!!!"
			$Label/AnimationPlayer.play()
			break_text_shown = true
		$"bank account window/debt/Money Display".text = "$" + str(Global.debt)
		$"bank account window/debt/deposit".show()
		$"bank account window/debt/Min Debt".show()
		print("Hello")
		if time == 0:
			print("Hello")
			if deposited_in_round < 7:
				get_tree().change_scene_to_file("res://game_over.tscn")
			else:
				Global.current_time_started = false
				Global.phase = 0
				$"break timer".stop()
				$"work window".show()
		else:
			print("Hello")
			$"bank account window".title = "Break - " + seconds2hhmmss(time)



func seconds2hhmmss(total_seconds: float) -> String:
	#total_seconds = 12345
	var seconds:float = fmod(total_seconds , 60.0)
	var minutes:int   =  int(total_seconds / 60.0) % 60
	var hours:  int   =  int(total_seconds / 3600.0)
	var hhmmss_string:String = "%02d:%02d:%05.2f" % [hours, minutes, seconds]
	return hhmmss_string.replace(".00","")


func _on_work_timer_timeout():
	time -= 1


func _on_deposit_pressed():
	if money != 0:
		money -= 1
		Global.debt -= 1
		deposited_in_round += 1


func _on_timer_timeout():
	if $"bank account window/debt/deposit".disabled:
		$"bank account window/debt/deposit".disabled = false
	else:
		$"bank account window/debt/deposit".disabled = true


func _on_break_timer_timeout():
	time -= 1
