extends Node2D

@onready var hp = $Display/hp
@onready var coins = $Display/coins


func update_hp(curr: int, max_hp: int):
	hp.text = ""
	for i in range(curr):
		hp.text += "❤️"
	for i in range(max_hp - curr):
		hp.text += "🖤"

func update_coins(c: int):
	coins.text = ""
	coins.text = "🪙x" + str(c)
