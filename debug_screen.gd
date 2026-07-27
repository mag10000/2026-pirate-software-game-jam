extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Button/Label.text = str(DirAccess.get_files_at("res://inventory/items/")).replace("[","").replace("]","").replace(".tres","").replace("\"","")
	if not updating_debt:
		$Control/Debt.value = Global.debt

func _on_button_pressed():
	Global.debt = $Control/Debt.value
