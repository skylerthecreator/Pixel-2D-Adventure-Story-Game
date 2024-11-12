extends Node

const MAX_HP = 5

var coins = 0
var amnova_unlocked = false
var fireball_unlocked = false
var amnova_ready = true
var hp = 1


func _process(delta):
	Hud.update_hp(hp, MAX_HP)
	Hud.update_coins(coins)
