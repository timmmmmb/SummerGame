extends "res://scenes/Entitys/Entity.gd"

export (int) var run_speed = 200
export (int) var fly_speed = -200
export (int) var run_attack_distance = 200
export (int) var jump_speed = -400
export (int) var gravity = 2400

var velocity = Vector2()
var jumping = false
var attacking = false
var attackCount = 0
var dashAttack = false
var flying = false
export var jetpackfuel = 100
export var respawnPosition = Vector2(0,0)

func get_input():
	if !dashAttack:
		velocity.x = 0
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var jump = Input.is_action_just_pressed('ui_up')
	var attack = Input.is_action_just_pressed("ui_attack")
	var respawn = Input.is_action_just_pressed("ui_respawn")
	var fly = Input.is_key_pressed(KEY_W)
	if respawn && dying:
		respawn()
	if dying:
		return
	if jump and is_on_floor():
		jumping = true
		velocity.y = jump_speed
	elif fly and !is_on_floor() and jetpackfuel > 0 and velocity.y > -50:
		flying = true
		velocity.y = fly_speed
	if attack && (right||left) && !attacking && !dashAttack:
		dashAttack = true
	elif attack && !attacking && !dashAttack:
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


func _physics_process(delta):
	get_input()
	velocity.y += gravity * delta
	if (jumping or flying) and is_on_floor():
		jumping = false
		flying = false
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
	elif dashAttack:
		$AnimatedSprite.animation = "runAttack"
	elif velocity.y < 0 && flying:
		$AnimatedSprite.animation = "jetpackUp"
		if !$JetpackSound.playing:
			$JetpackSound.play(0.0)
		jetpackfuel -= 50*delta
	elif velocity.y > 0 && flying:
		$AnimatedSprite.animation = "jetpackDown"
		if $JetpackSound.playing:
			$JetpackSound.stop()
	elif velocity.y < 0:
		$AnimatedSprite.animation = "up"
	elif velocity.x != 0:
		$AnimatedSprite.animation = "right"
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x < 0
	if !dashAttack:
		resetOffset()
	velocity = move_and_slide(velocity, Vector2(0, -1))


func _on_AttackTimer_timeout():
	dashAttack = false
	attackCount = 0
	
func resetOffset():
	if $AnimatedSprite.flip_h:
		$AnimatedSprite.offset.x = -21
	else:
		$AnimatedSprite.offset.x = 0

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "attack0" || $AnimatedSprite.animation == "attack1" || $AnimatedSprite.animation == "attack2":
		attacking = false
	elif $AnimatedSprite.animation == "hit":
		hit = false
	elif $AnimatedSprite.animation == "runAttack":
		resetOffset()
		dashAttack = false

func _HitDetection(body):
	body.hit(damage)

func _on_AnimatedSprite_frame_changed():
	if ($AnimatedSprite.animation == "attack0" || $AnimatedSprite.animation == "attack1" || $AnimatedSprite.animation == "attack2"):
		if $AnimatedSprite.frame == 3:
			$SlashPlayer.play(0.0)
			if $AnimatedSprite.flip_h:
				$AttackHitboxLeft.monitoring = true
			else:
				$AttackHitboxRight.monitoring = true
		elif $AnimatedSprite.frame == 4:
			$AttackHitboxRight.monitoring = false
			$AttackHitboxLeft.monitoring = false
	elif $AnimatedSprite.animation == "runAttack":
		if $AnimatedSprite.frame == 1:	
			if $AnimatedSprite.flip_h:
				$DashHitboxLeft.monitoring = true
				$AnimatedSprite.offset.x += 20
				velocity.x -= 400
			else:
				$AnimatedSprite.offset.x -= 20
				velocity.x += 400
				$DashHitboxRight.monitoring = true
		elif $AnimatedSprite.frame == 2:
			$SlashPlayer.play(0.0)
			if $AnimatedSprite.flip_h:
				$AnimatedSprite.offset.x += 10
			else:
				$AnimatedSprite.offset.x -= 10
			$DashHitboxRight.monitoring = false
			$DashHitboxLeft.monitoring = false
		elif $AnimatedSprite.frame == 4:
			velocity.x = 0

func respawn():
	position = respawnPosition
	dying = false
	health = max_health
