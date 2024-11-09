extends Area2D

@onready var animation_player = $AnimationPlayer
@onready var game_manager = %GameManager
@onready var insufficientfunds = $insufficientfunds


const COST = 8
const SPEED_INC = 50
var player = null

func _on_body_entered(body):
	player = body
	player.buy = false

func _process(delta):
	if player and player.buy and game_manager.score >= COST:
		game_manager.score -= COST
		player.coins -= COST
		player.speed += SPEED_INC
		animation_player.play("pickup")
		player = null
	elif player and player.buy and game_manager.score < COST:
		insufficientfunds.play()
		
func _on_body_exited(body):
	player = null
	



