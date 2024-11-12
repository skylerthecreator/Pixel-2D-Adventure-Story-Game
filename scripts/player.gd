extends CharacterBody2D


const ROLL_SPEED = 300
const SPEED = 100
const JUMP_VELOCITY = -225
const MAX_HP = 5
const PRIORITY_MOVEMENT = ["casting", "fireball", "skill1", "wake", "hit"]
const PREVENT_START = ["casting", "fireball"]
var speed = SPEED
var hp = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D
@onready var jump = $jump
@onready var hurt = $hurt
@onready var footsteps = $footsteps
@onready var game_manager = %GameManager
@onready var tracker = $Camera2D/tracker

@onready var s1_sound = $skill1sound
@onready var s1_cd = $skill1cd

@onready var fireball_bar = $fireball_bar
@onready var fireball_chargeup = $fireball_chargeup
@onready var fireball_sound = $fireball_sound
@onready var fireball_cast_time = $fireball_cast_time
@onready var fbspawn = $fbspawn
var fireball = load("res://scenes/fireball.tscn")

var buy = false
var areas1 = []

var dead = false
var hit = false
var coins = 0
var rolling = false
var waking_up = true
var attacking = false
var moving = false

var s0_casting = false
var skill0 = true

var s1_ready = true
var skill1 = false

var casting = false
var cast_dir = 1
	
func _physics_process(delta):
	if waking_up:
		_waking_up()
	#elif animated_sprite.animation == "wake" and animated_sprite.is_playing():
	#	pass
	elif hit:
		_hit()
	elif !dead:
		var direction = Input.get_axis("move_left", "move_right")
		if direction != 0:
			cast_dir = direction
		moving = direction != 0 or !(is_on_floor())
		if moving and casting:
			_interrupt_skill0()
		if casting:
			fireball_bar.visible = true
			fireball_bar.value += 5.0/3.0
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			jump.play()
			velocity.y = JUMP_VELOCITY
		if Input.is_action_just_pressed("skill0"):
			_skill0()
		if Input.is_action_just_pressed("skill1"):
			_skill1()
		if buy:
			buy = false
		if Input.is_action_just_pressed("pickup"):
			buy = true
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		
		# get input direction: -1, 0, 1
		
		# flip sprite
		_flip(direction)
		if direction != 0 and !footsteps.is_playing() and is_on_floor():
			footsteps.play()
		elif direction == 0 and footsteps.is_playing():
			footsteps.stop()
		if !is_on_floor():
			footsteps.stop()
		
		# play animations
		if (PRIORITY_MOVEMENT.count(animated_sprite.animation) != 0) and animated_sprite.is_playing():
			pass
		else:
			_play_movement_animations(direction)
			
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
		
		_update_tracker()
		if !(animated_sprite.animation == "wake" and animated_sprite.is_playing()):
			move_and_slide()
		
	else:
		tracker.text = "🖤🖤🖤🖤🖤" + "\n" + "🪙x" + str(game_manager.score)
		animated_sprite.play("death")

func _waking_up():
	animated_sprite.play("wake")
	waking_up = false
func _hit():
	hurt.play()
#	_interrupt_skill0()
	animated_sprite.play("hit")
	hit = false
func _update_tracker():
	tracker.text = ""
	for i in range(hp):
		tracker.text += "❤️"
	for i in range(MAX_HP - hp):
		tracker.text += "🖤"
	tracker.text += "\n"
	tracker.text += "🪙x" + str(game_manager.score)
func _flip(direction: int):
	if direction > 0:
		animated_sprite.flip_h = false
		fireball_chargeup.flip_h = false
		if fbspawn.position.x > 0:
			fbspawn.position.x *= -1
			fireball_chargeup.position.x *= -1
	elif direction < 0:
		animated_sprite.flip_h = true
		fireball_chargeup.flip_h = true
		fbspawn.scale.x = 1
		if fbspawn.position.x < 0:
			fbspawn.position.x *= -1
			fireball_chargeup.position.x *= -1
func _play_movement_animations(direction: int):
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
		

func _skill1():
	if !(animated_sprite.animation == "skill1" and animated_sprite.is_playing()) and s1_ready and skill1:
		s1_sound.play()
		animated_sprite.play("skill1")
		if areas1:
			for area in areas1:
				area.hit = true
		s1_ready = false
		s1_cd.start()
func _on_skill_1_outline_area_entered(area):
	if area.is_in_group("enemies"):
		areas1.append(area)
func _on_skill_1_outline_area_exited(area):
	var index = areas1.find(area,0)
	if (index != -1):
		areas1.remove_at(index)
func _on_skill_1_cd_timeout():
	s1_ready = true

func _skill0():
	if !(PREVENT_START.count(animated_sprite.animation) != 0 and animated_sprite.is_playing()) and skill0:
		casting = true
		animated_sprite.play("casting")
		fireball_sound.play()
		fireball_cast_time.start()
		fireball_chargeup.visible = true
		fireball_chargeup.play("default")

func _interrupt_skill0():
	casting = false
	animated_sprite.stop()
	fireball_sound.stop()
	fireball_cast_time.stop()
	fireball_chargeup.visible = false
	fireball_chargeup.stop()
	fireball_bar.visible = false
	fireball_bar.value = 0
	
func _on_fireball_cast_time_timeout():
	fireball_chargeup.visible = false
	var fb = fireball.instantiate()
	owner.add_child(fb)
	fb.transform = fbspawn.global_transform
	fb.cast_dir = cast_dir
	fb.charged = true
	animated_sprite.play("fireball")
	casting = false
	fireball_bar.visible = false
	fireball_bar.value = 0
