extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	$Control/Debt.value = Global.debt
	$Control/Day.value = Global.day
	$Control/Hour.value = Global.hour
	$Control/Money.value = $"..".money


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Button/Label.text = str(DirAccess.get_files_at("res://inventory/items/")).replace("[","").replace("]","").replace(".tres","").replace("\"","")
	if not visible:
		$Control/Debt.value = Global.debt
		$Control/Day.value = Global.day
		$Control/Hour.value = Global.hour
		$Control/Money.value = $"..".money

func _on_debt_value_changed(value):
	if visible:
			Global.debt = $Control/Debt.value


func _on_day_value_changed(value):
	if visible:
			Global.day = $Control/Day.value


func _on_hour_value_changed(value):
	if visible:
			Global.hour = $Control/Hour.value


func _on_money_value_changed(value):
	if visible:
		$"..".money = $Control/Money.value


func _on_pause_timer_pressed():
	if $"..".time > 30:
		$"..".time = $Control/Hour.value


func _on_button_pressed():
	InventoryManager.grant_item("res://inventory/items/" + $Button/LineEdit.text + ".tres")
