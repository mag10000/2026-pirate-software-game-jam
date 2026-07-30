extends Control

@export var MusicPlayer: AudioStreamPlayer

func _ready():
	$LeaderBoard.get_scores()
	MusicPlayer.play()
	cycle_leaderboard()
	Global.clear_data()

func _on_button_pressed():
	get_tree().change_scene_to_file("res://story_beat.tscn")


func _on_setttings_pressed():
	$LeaderBoard.get_scores()
	$settings.show()


func cycle_leaderboard():
	$LeaderBoard.get_scores()
	await get_tree().create_timer(5).timeout
	$Tutorial.hide()
	$LeaderBoard.get_scores()
	$LeaderBoard.show()
	await get_tree().create_timer(5).timeout
	$LeaderBoard.get_scores()
	$LeaderBoard.hide()
	$Tutorial.show()
	await get_tree().create_timer($Tutorial.total_time).timeout
	cycle_leaderboard()


func _input(event):
	$LeaderBoard.hide()
	$Tutorial.hide()
