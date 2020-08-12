extends "res://scenes/Entitys/Entity.gd"

func _physics_process(_delta):
	velocity.x = 0
	if state == STATE.SLEEPING:
		return
	if state == STATE.IDLE && $Delay.time_left == 0 && abs(get_parent().get_node("Player").position.x - position.x) <= 40:
		state = STATE.ATTACKING
	if dying:
		$AnimatedSprite.animation = "death"
	elif state == STATE.HIT:
		$AnimatedSprite.animation = "hit"
	elif state == STATE.IDLE:
		setDirection(get_parent().get_node("Player").position.x < position.x)
		if abs(get_parent().get_node("Player").position.x - position.x) > 40:
			state = STATE.RUNNING
		$AnimatedSprite.animation = "idle"
	elif state == STATE.RUNNING:
		setDirection(get_parent().get_node("Player").position.x < position.x)
		if abs(get_parent().get_node("Player").position.x - position.x) < 20:
			state = STATE.IDLE
		if direction:
			velocity.x = -run_speed
		else:
			velocity.x = run_speed
		$AnimatedSprite.animation = "right"
	elif state == STATE.ATTACKING:
		$AnimatedSprite.animation = "attack"
	velocity = move_and_slide(velocity, Vector2(0, -1))

func _HitDetection(body):
	if body.is_in_group("Player"):
		body.hit(damage)

func _on_AnimatedSprite_animation_finished():
	if state == STATE.ATTACKING: 
		state = STATE.IDLE
		$Delay.start(0.0)
	if $AnimatedSprite.animation == "hit":
		afterHit()
	elif $AnimatedSprite.animation == "death":
		get_parent().remove_child(self)
	$HitboxAttack.monitoring = false
		
func _on_AnimatedSprite_frame_changed():
	if $AnimatedSprite.animation == "attack":
		if $AnimatedSprite.frame == 3:
			$SlashSound.play()
			$HitboxAttack.monitoring = true
		elif $AnimatedSprite.frame == 4:
			$HitboxAttack.monitoring = false

func _on_TriggerArea_body_entered(body):
	if body.is_in_group("Player"):
		state = STATE.IDLE

