extends "res://scenes/Entitys/Entity.gd"

export (int) var fly_speed = -200
export (int) var run_attack_distance = 200
export (int) var jump_speed = -400
export (int) var gravity = 2400

var attackCount = 0
var dashReady = false
export var jetpackfuel = 100
export var max_jetpackfuel = 100
export var respawnPosition = Vector2(0,0)
export var attackingEnabled = true

func _ready():
	health = max_health
	$GUI/HealthBar.max_value = max_health
	$GUI/HealthBar.value = health
	$GUI/FuelBar.max_value = max_jetpackfuel
	$GUI/FuelBar.value = jetpackfuel
	
func get_input():
	if !state == STATE.SPECIAL:
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
		state = STATE.JUMPING
		velocity.y = jump_speed
	elif fly and !is_on_floor() and jetpackfuel > 0 and velocity.y > -50:
		state = STATE.FLYING
		velocity.y = fly_speed
	if attack && (right||left) && state != STATE.ATTACKING && state != STATE.SPECIAL && dashReady && attackingEnabled:
		state = STATE.SPECIAL
	elif attack && state != STATE.ATTACKING && state != STATE.SPECIAL && attackingEnabled:
		attackCount = (attackCount+1)%3
		state = STATE.ATTACKING
		get_node("AttackTimer").start()
	if state == STATE.ATTACKING:
		if right:
			velocity.x += run_speed/4
		if left:
			velocity.x -= run_speed/4
	else:
		if right && state != STATE.SPECIAL:
			if $DashTimer.time_left == 0:
				$DashTimer.start()
			velocity.x += run_speed
		if left && state != STATE.SPECIAL:
			if $DashTimer.time_left == 0:
				$DashTimer.start()
			velocity.x -= run_speed


func _physics_process(delta):
	get_input()
	$GUI/FuelBar.value = jetpackfuel
	$GUI/HealthBar.value = health
	velocity.y += gravity * delta
	if (state == STATE.JUMPING or state == STATE.FLYING) and is_on_floor():
		state = STATE.IDLE
		$JetpackSound.stop()
	if !(velocity.x != 0 || velocity.y < 0 || state == STATE.ATTACKING || state == STATE.SPECIAL || dying):
		state = STATE.IDLE
	if dying:
		$AnimatedSprite.animation = "death"
	elif state == STATE.HIT:
		$AnimatedSprite.animation = "hit"
	elif state == STATE.ATTACKING:
		$AnimatedSprite.animation = "attack"+str(attackCount)
	elif state == STATE.SPECIAL:
		$AnimatedSprite.animation = "runAttack"
	elif velocity.y < 0 && state == STATE.FLYING:
		$AnimatedSprite.animation = "jetpackUp"
		setDirection(velocity.x >= 0)
		if !$JetpackSound.playing:
			$JetpackSound.play(0.0)
		jetpackfuel -= 50*delta
	elif velocity.y > 0 && state == STATE.FLYING:
		$AnimatedSprite.animation = "jetpackDown"
		setDirection(velocity.x >= 0)
		if $JetpackSound.playing:
			$JetpackSound.stop()
	elif velocity.y < 0:
		$AnimatedSprite.animation = "up"
	elif velocity.x != 0:
		$AnimatedSprite.animation = "right"
		setDirection(velocity.x >= 0)
	elif state == STATE.IDLE:
		$AnimatedSprite.animation = "idle"
	if velocity.x == 0 || state == STATE.ATTACKING:
		$DashTimer.stop()
		dashReady = false
	if !direction:
		$GUI.rect_scale.x = -1
	else:
		$GUI.rect_scale.x = 1
	velocity = move_and_slide(velocity, Vector2(0, -1))

func _on_AttackTimer_timeout():
	attackCount = 0

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "attack0" || $AnimatedSprite.animation == "attack1" || $AnimatedSprite.animation == "attack2":
		state = STATE.IDLE
	elif $AnimatedSprite.animation == "hit":
		afterHit()
	elif $AnimatedSprite.animation == "runAttack":
		if direction:
			position.x += 29
		else:
			position.x -= 29
		state = STATE.IDLE
	
	$DashHitbox.monitoring = false
	$AttackHitbox.monitoring = false

func _HitDetection(body):
	body.hit(damage)

func _on_AnimatedSprite_frame_changed():
	if ($AnimatedSprite.animation == "attack0" || $AnimatedSprite.animation == "attack1" || $AnimatedSprite.animation == "attack2"):
		if $AnimatedSprite.frame == 3:
			$SlashPlayer.play(0.0)
			$AttackHitbox.monitoring = true
		elif $AnimatedSprite.frame == 4:
			$AttackHitbox.monitoring = false
	elif $AnimatedSprite.animation == "runAttack":
		if $AnimatedSprite.frame == 1:	
				$DashHitbox.monitoring = true
		elif $AnimatedSprite.frame == 2:
			$SlashPlayer.play(0.0)
			$DashHitbox.monitoring = false

func respawn():
	position = respawnPosition
	dying = false
	health = max_health

func _on_DashTimer_timeout():
	dashReady = true
