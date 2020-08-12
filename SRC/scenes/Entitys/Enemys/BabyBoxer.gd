extends "res://scenes/Entitys/Entity.gd"

export (int) var gravity = 2400

func _physics_process(delta):
	velocity.y += gravity * delta
	if state == STATE.SLEEPING:
		$AnimatedSprite.animation = "sleeping"
	elif state == STATE.RUNNING:
		$AnimatedSprite.animation = "running"
	elif dying:
		$AnimatedSprite.animation = "death"
	elif state == STATE.HIT:
		$AnimatedSprite.animation = "hit"
	elif state == STATE.ATTACKING:
		$AnimatedSprite.animation = "attack"
	else:
		$AnimatedSprite.animation = "idle"
		setDirection(get_parent().get_node("Player").position.x < position.x)
		if abs(get_parent().get_node("Player").position.x - position.x) > 50 && $DelayMovement.time_left == 0:
			state = STATE.RUNNING
	velocity = move_and_slide(velocity, Vector2(0, -1))

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "attack":
		state = STATE.IDLE
		$Delay.start()
	elif $AnimatedSprite.animation == "death":
		get_parent().remove_child(self)
	elif $AnimatedSprite.animation == "running": 
		$AnimatedSprite.animation = "idle"
		if direction:
			position.x -= 61
		else:
			position.x += 61
		state = STATE.IDLE
		$DelayMovement.start(0.0)
	elif $AnimatedSprite.animation == "hit":
		afterHit()
	$AttackHitbox.monitoring = false

func _on_Delay_timeout():
	$AttackShape.monitoring = false
	$AttackShape.monitoring = true
	
func _on_Trigger_body_entered(body):
	if body.is_in_group("Player"):
		state = STATE.IDLE

func attack():
	if !$Delay.time_left > 0 && state != STATE.ATTACKING && !dying:
		state = STATE.ATTACKING

func _on_Enemy_in_Range(body):
	if body.is_in_group("Player"):
		attack()

func _on_AnimatedSprite_frame_changed():
	if $AnimatedSprite.animation == "attack": 
		if $AnimatedSprite.frame == 12:
			$Attack.play(0.0)
			$AttackHitbox.monitoring = true
		elif $AnimatedSprite.frame == 13:
			$AttackHitbox.monitoring = false
		
func _HitDetection(body):
	body.hit(damage)
