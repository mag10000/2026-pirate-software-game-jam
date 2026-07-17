extends Control

var money = 0.00

var time = 0

func _process(delta):
	if ("$" + str(money)).length() == 4:
		$"bank account window/Money Display".text = "$" + str(money) + "0"
	else:
		$"bank account window/Money Display".text = "$" + str(money)
	
	if not Global.current_time_started && Global.phase == 0:
		Global.current_time_started = true
		time = Global.times[Global.current_time_id]
		$"work timer".start()
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
		else:
			$"work window".title = "Work - " + seconds2hhmmss(time)
	if Global.phase == 1:
		$"payoff debt/Money Display".text = "$" + str(Global.debt)
		$"payoff debt".show()



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
	if $"bank account deposit window".visible == true:
		return
	else:
		$"bank account deposit window".show()
		$"bank account deposit window/SpinBox".max_value = money


func _on_deposit_from_bank_pressed():
	money -= $"bank account deposit window/SpinBox".value
	Global.debt -= $"bank account deposit window/SpinBox".value
	$"bank account deposit window".hide()
	$"payoff debt".hide()
	$"work window".show()
	Global.phase = 0
	
