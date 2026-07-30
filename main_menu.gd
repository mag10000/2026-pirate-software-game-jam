extends Control

@export var MusicPlayer: AudioStreamPlayer

func _ready():
	MusicPlayer.play()
	cycle_leaderboard()

func _on_button_pressed():
	get_tree().change_scene_to_file("res://story_beat.tscn")


func _on_setttings_pressed():
	$settings.show()


func cycle_leaderboard():
	await get_tree().create_timer(5).timeout
	$LeaderBoard.show()
	await get_tree().create_timer(5).timeout
	$LeaderBoard.hide()
	cycle_leaderboard()


func _input(event):
	$LeaderBoard.hide()
