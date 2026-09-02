extends Control

@export var MusicPlayer: AudioStreamPlayer

var launcher_path = ""

func _ready():
	$Start.grab_focus()
	#if FileAccess.file_exists("user://launcher.txt"):
		#var file = FileAccess.open("user://launcher.txt", FileAccess.READ)
		#launcher_path = file.get_as_text()
		#print(launcher_path)
	launcher_path = "/home/deck/Desktop/SanJapan2026/sanjapanlauncher.x86_64"
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
	await get_tree().create_timer(5).timeout
	$Tutorial.show()
	await get_tree().create_timer($Tutorial.total_time + 10).timeout
	$LeaderBoard.get_scores()
	$LeaderBoard.show()
	await get_tree().create_timer(5).timeout
	$LeaderBoard.hide()
	$Tutorial.show()
	cycle_leaderboard()

func _input(event):
	if event is InputEventMouseMotion:
		return
	else:
		$LeaderBoard.hide()
		$Tutorial.hide()


func _on_quit_pressed():
	OS.create_process(launcher_path,[])
	$MusicPlayer.stop()
	await get_tree().create_timer(1.5).timeout
	get_tree().quit()
