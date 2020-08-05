extends KinematicBody2D

export (int) var run_speed = 300
export (int) var run_attack_distance = 200
export (int) var jump_speed = -600
export (int) var gravity = 2400

var velocity = Vector2()
var jumping = false
var attacking = false
var attackCount = 0
var dashAttack = false
var dying = false

func get_input():
	velocity.x = 0
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var jump = Input.is_action_just_pressed('ui_up')
	var attack = Input.is_action_just_pressed("ui_attack")

	if jump and is_on_floor():
		jumping = true
		velocity.y = jump_speed
	if attack:
		attackCount = (attackCount+1)%3
		attacking = true
		get_node("AttackTimer").start()
	if attacking:
		if right:
			velocity.x += run_speed/4
		if left:
			velocity.x -= run_speed/4
	else:
		if right && !dashAttack:
			velocity.x += run_speed
		if left && !dashAttack:
			velocity.x -= run_speed
#	if attack && (right||left):
#		dashAttack = true
#		velocity.x = 0
#		get_node("AttackTimer").start()
#	elif attack:

func _physics_process(delta):
	get_input()
	velocity.y += gravity * delta
	if jumping and is_on_floor():
		jumping = false
	if velocity.x != 0 || velocity.y < 0 || attacking || dashAttack:
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.animation = "idle"
		$AnimatedSprite.stop()
	if dying:
		$AnimatedSprite.animation = "death"
	elif attacking:
		if velocity.x != 0:
			$AnimatedSprite.flip_h = velocity.x < 0
		$AnimatedSprite.animation = "attack"+str(attackCount)
#	elif dashAttack:
#		$AnimatedSprite.animation = "runAttack"
	elif velocity.y < 0:
		$AnimatedSprite.animation = "up"
	elif velocity.x != 0:
		$AnimatedSprite.animation = "right"
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x < 0
	velocity = move_and_slide(velocity, Vector2(0, -1))


func _on_AttackTimer_timeout():
	attacking = false
	dashAttack = false
	attackCount = 0
