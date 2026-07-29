extends Control

var scroll = false

func _on_button_pressed():
	$Button.disabled = true
	#TODO - Update this as we change things
	# Logic to reset all amounts to default
	InventoryManager.clear_inventory()
	Global.current_work_time_id = 0
	Global.current_break_time_id = 0
	Global.work_time_started = false
	Global.break_time_started = false
	Global.work_times = [23,25,21,22]
	Global.break_times = [10]
	Global.phase = 0
	Global.money_earned = 0
	Global.debt = 10000
	Global.minimumPay = 500
	Global.day = 1
	Global.hour = 1
	Global.story_beat = "start_cutscene"
	Global.item_pool = ["res://inventory/items/lightning_item.tres","res://inventory/items/time_add_item.tres","res://inventory/items/refresh_item.tres","res://inventory/items/bomb_item.tres"]
	Global.iconsForRound = [[],[1, 2, 3, 4, 5],[1, 2, 3, 4, 5, 6, 7],[1, 2, 3, 4, 5, 8, 9],[1, 2, 3, 4, 5, 10, 11],[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]]
	Global.regularIconsForRound = [[],[1, 2, 3, 4, 5],[1, 2, 3, 4, 5, 6],[1, 2, 3, 4, 5, 8],[1, 2, 3, 4, 5, 10],[1, 2, 3, 4, 5, 6, 8, 10]]
	Global.evilIconsForRound = [[],[],[7],[9],[11],[7,9,11]]
	Global.amt_earned_combos = 4
	Global.amt_earned_icon = 1
	Global.money_multiplier = 1
	$AnimationPlayer.play("fade")
	$LeaderBoard.get_scores()
	$ScrollTimer.start()
	scroll = true

func _physics_process(delta):
	if scroll:
		$Camera2D.position.y += 1
		$ColorRect.position.y += 1

func _on_timer_timeout():
	$LeaderBoard.get_scores()
	scroll = false
	$WaitTimer.start()


func _on_wait_timer_timeout():
	$LeaderBoard.get_scores()
	$LeaderBoard.show()
	$Camera2D.position = Vector2(320.0,180.0)
