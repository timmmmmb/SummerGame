extends "res://scenes/Entitys/Entity.gd"

var attackCount = 0
	
func _physics_process(_delta):
	velocity.x = 0
	if state == STATE.SLEEPING:
		return
	if state == STATE.IDLE && $Delay.time_left == 0 :
		attackCount = (attackCount + 1) % 10
		state = STATE.ATTACKING
	if dying:
		$AnimatedSprite.animation = "death"
	elif state == STATE.HIT:
		$AnimatedSprite.animation = "hit"
	elif state == STATE.IDLE:
		setDirection(get_parent().get_node("Player").position.x < position.x)
		if abs(get_parent().get_node("Player").position.x - position.x) > 80:
			state = STATE.RUNNING
		$AnimatedSprite.animation = "idle"
	elif state == STATE.RUNNING:
		setDirection(get_parent().get_node("Player").position.x < position.x)
		if abs(get_parent().get_node("Player").position.x - position.x) < 30:
			state = STATE.IDLE
		if direction:
			velocity.x = -run_speed
		else:
			velocity.x = run_speed
		$AnimatedSprite.animation = "right"
	elif attackCount == 9 && state == STATE.ATTACKING:
		$AnimatedSprite.animation = "attack2"
	elif (attackCount == 3 || attackCount == 6) && state == STATE.ATTACKING:
		$AnimatedSprite.animation = "attack1"
	elif state == STATE.ATTACKING:
		$AnimatedSprite.animation = "attack0"
	velocity = move_and_slide(velocity, Vector2(0, -1))

func _HitDetection0(body):
	if body.is_in_group("Player"):
		body.hit(damage)

func _HitDetection1(body):
	if body.is_in_group("Player"):
		body.hit(damage * 2)

func _HitDetection2(body):
	if body.is_in_group("Player"):
		body.hit(damage * 5)

func _on_AnimatedSprite_animation_finished():
	if state == STATE.ATTACKING: 
		state = STATE.IDLE
		$Delay.start(0.0)
	if $AnimatedSprite.animation == "hit":
		afterHit()
	elif $AnimatedSprite.animation == "death":
		get_parent().remove_child(self)
	$HitboxAttack2.monitoring = false
	$HitboxAttack1_1.monitoring = false
	$HitboxAttack1_2.monitoring = false
	$HitboxAttack0.monitoring = false
		
func _on_AnimatedSprite_frame_changed():
	if $AnimatedSprite.animation == "attack0":
		if $AnimatedSprite.frame == 1 || $AnimatedSprite.frame == 4:
			$SlashSound.play()
			$HitboxAttack0.monitoring = true
		elif $AnimatedSprite.frame == 2 || $AnimatedSprite.frame == 5:
			$HitboxAttack0.monitoring = false
	elif $AnimatedSprite.animation == "attack1":
		if $AnimatedSprite.frame == 4:
			$SlashSound.play()
			$HitboxAttack1_1.monitoring = true
		elif $AnimatedSprite.frame == 8:
			$SlashSound.play()
			$HitboxAttack1_2.monitoring = true
		elif $AnimatedSprite.frame == 5 || $AnimatedSprite.frame == 9:
			$HitboxAttack1_1.monitoring = false
			$HitboxAttack1_2.monitoring = false
	elif $AnimatedSprite.animation == "attack2":
		if $AnimatedSprite.frame == 4:
			$SlashSound.play()
			$HitboxAttack2.monitoring = true
		elif $AnimatedSprite.frame == 5:
			$HitboxAttack2.monitoring = false


func _on_TriggerArea_body_entered(body):
	if body.is_in_group("Player"):
		state = STATE.IDLE

