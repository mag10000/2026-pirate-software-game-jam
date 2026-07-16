extends Control

var money = 0.00

func _process(delta):
	if ("$" + str(money)).length() == 4:
		$"bank account window/Money Display".text = "$" + str(money) + "0"
	else:
		$"bank account window/Money Display".text = "$" + str(money)
