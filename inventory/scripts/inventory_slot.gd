extends Panel

@export var item : InventoryItem
@export var amount : int
signal show_discription(discription : String)

func _process(delta):
	if Global.phase == 0:
		$Button.disabled = false
	if Global.phase == 1:
		$Button.disabled = true
	if item:
		$border/item.texture = item.item_icon
		if amount > 1:
			$border/item/Label.text = str(amount)
		else:
			$border/item/Label.text = ""
	else:
		$border/item.texture = load("res://art/blank.tres")
		$border/item/Label.text = ""


func _on_button_pressed():
	$"../../..".item_clicked(self)
	amount -= 1
	if amount == 0:
		item = null
	
func reset_item_game_over():
	amount = 0
	item = null
