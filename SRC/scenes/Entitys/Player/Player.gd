extends "res://scenes/Entitys/Entity.gd"

export (int) var run_speed = 200
export (int) var run_attack_distance = 200
export (int) var jump_speed = -400
export (int) var gravity = 2400

var velocity = Vector2()
var jumping = false
var attacking = false
var attackCount = 0
var dashAttack = false
export var respawnPosition = Vector2(0,0)

func get_input():
	velocity.x = 0
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var jump = Input.is_action_just_pressed('ui_up')
	var attack = Input.is_action_just_pressed("ui_attack")
	var respawn = Input.is_action_just_pressed("ui_respawn")
	if respawn && dying:
		respawn()
	if dying:
		return
	if jump and is_on_floor():
		jumping = true
		velocity.y = jump_speed
	if attack && !attacking:
		attackCount = (attackCount+1)%3
		attacking = true
		get_node("AttackTimer").start()
		$SlashPlayer.play(0.0)
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
	if velocity.x != 0 || velocity.y < 0 || attacking || dashAttack || dying || hit:
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.animation = "idle"
		$AnimatedSprite.stop()
	if dying:
		$AnimatedSprite.animation = "death"
	elif hit:
		$AnimatedSprite.animation = "hit"
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
	if $AnimatedSprite.flip_h:
		$AnimatedSprite.offset.x = -21
	else:
		$AnimatedSprite.offset.x = 0
	velocity = move_and_slide(velocity, Vector2(0, -1))


func _on_AttackTimer_timeout():
	dashAttack = false
	attackCount = 0


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "attack0" || $AnimatedSprite.animation == "attack1" || $AnimatedSprite.animation == "attack2":
		attacking = false
	elif $AnimatedSprite.animation == "hit":
		hit = false
		
func _HitDetection(body):
	body.hit(damage)


func _on_AnimatedSprite_frame_changed():
	if ($AnimatedSprite.animation == "attack0" || $AnimatedSprite.animation == "attack1" || $AnimatedSprite.animation == "attack2"):
		if $AnimatedSprite.frame == 3:
			if $AnimatedSprite.flip_h:
				$AttackHitboxLeft.monitoring = true
			else:
				$AttackHitboxRight.monitoring = true
		elif $AnimatedSprite.frame == 4:
			$AttackHitboxRight.monitoring = false
			$AttackHitboxLeft.monitoring = false
			
func respawn():
	position = respawnPosition
	dying = false
	health = max_health
