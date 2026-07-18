extends Control

# Export Variables
@export var earningsAmountDisplay: Label
@export var debtAmountDisplay: Label
@export var debtMinimumPayDisplay: Label
@export var scrollAlertText: Label

@export var workTimer: Timer
@export var breakTimer: Timer
@export var depositFlickerTimer: Timer

@export var workWindow: Window
@export var bankWindow: Window
@export var itemWindow: Window

@export var depositButton: Button

@export var scrollAlertTextAnimation: AnimationPlayer

# The Amount of Money the Player Has
var money = 0.00

# Time Remaining in a Counter
var time = 0

# Whether the Break Text is Shown
var break_text_shown = false

# Deposited?
var deposited_in_round = 0


# Runs every frame
func _process(delta):
	earningsAmountDisplay.text = "$" + str(money)
	
	if not Global.work_time_started && Global.phase == 0:
		Global.break_time_started = false
		Global.work_time_started = true
		time = Global.times[Global.current_time_id] + randi_range(1,5)
		workTimer.start()
		breakTimer.stop()
		scrollAlertText.text = "It's Work Time!!!"
		bankWindow.title = "Bank Account"
		depositButton.hide()
		debtMinimumPayDisplay.hide()
		scrollAlertTextAnimation.play()
	if Global.work_time_started && Global.phase == 0:
		if time == 0:
			workTimer.stop()
			Global.work_time_started = false
			if Global.times.size() - 1 == Global.current_time_id:
				Global.current_time_id = 0
			Global.current_time_id += 1
			Global.phase = 1
			workWindow.title = "Work - Time Up!"
			await get_tree().create_timer(0.5).timeout
			workWindow.hide()
			depositButton.show()
			debtMinimumPayDisplay.show()
		else:
			workWindow.title = "Work - " + seconds2hhmmss(time)
	
	if Global.phase == 1:
		if not Global.break_time_started:
			Global.break_time_started = true
			time = Global.times[Global.current_time_id] + randi_range(1,5)
			deposited_in_round = 0
			breakTimer.start()
			scrollAlertText.text = "It's Break Time!!!"
			scrollAlertTextAnimation.play()
		earningsAmountDisplay.text = "$" + str(Global.debt)
		depositButton.show()
		debtMinimumPayDisplay.show()
		if time == 0:
			if deposited_in_round < 7:
				get_tree().change_scene_to_file("res://game_over.tscn")
			else:
				Global.work_time_started = false
				Global.phase = 0
				breakTimer.stop()
				workWindow.show()
		else:
			bankWindow.title = "Bank Account - " + seconds2hhmmss(time)



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
	if depositButton.disabled:
		depositButton.disabled = false
	else:
		depositButton.disabled = true


func _on_break_timer_timeout():
	time -= 1
