extends Control

var scroll = false

func _on_button_pressed():
	$Button.disabled = true
	Global.clear_data()
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
