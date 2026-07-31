extends Control

var scroll = false

@export var scoreLabel: Label

var earnedScore
var profitScore

func _ready():
	earnedScore = str(Global.money_earned)
	profitScore = str(Global.money)
	scoreLabel.text = "PROFIT: " + "
$"+ profitScore + "
TOTAL EARNED: " + "
$" + earnedScore

func _on_button_pressed():
	$Button.disabled = true
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
