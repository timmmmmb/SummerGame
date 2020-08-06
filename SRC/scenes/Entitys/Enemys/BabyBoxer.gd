extends "res://scenes/Entitys/Entity.gd"

var idle = true
var attacking = false
var delay = false
var playerIsLeft = false
var playerIsRight = false
var attackingLeft = false
export (int) var gravity = 2400
var velocity = Vector2()

func _physics_process(delta):
	velocity.y += gravity * delta
	if playerIsLeft:
		attackLeft()
	elif playerIsRight: 
		attackRight()
		
	if idle:
		$AnimatedSprite.animation = "idle"
	elif dying:
		$AnimatedSprite.animation = "death"
	elif hit:
		$AnimatedSprite.animation = "hit"
	elif attacking:
		$AnimatedSprite.flip_h = attackingLeft
		$AnimatedSprite.animation = "attack"
	else:
		$AnimatedSprite.flip_h = get_parent().get_node("Player").position.x < position.x
		if $AnimatedSprite.flip_h:
			$AnimatedSprite.offset.x = -62
		else:
			$AnimatedSprite.offset.x = 0
		$AnimatedSprite.animation = "idleAwake"
	
	velocity = move_and_slide(velocity, Vector2(0, -1))

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "attack":
		attacking = false
		delay = true
		$Delay.start()
	elif $AnimatedSprite.animation == "death":
		get_parent().remove_child(self)
	elif $AnimatedSprite.animation == "hit": 
		hit = false
		
func _on_Delay_timeout():
	delay = false
	$AttackShapeLeft.monitoring = false
	$AttackShapeRight.monitoring = false
	
	$AttackShapeLeft.monitoring = true
	$AttackShapeRight.monitoring = true

func _on_Trigger_body_entered(_body):
	idle = false

func attackLeft():
	if !delay && !attacking && !dying:
		attackingLeft = true
		attacking = true
		$AnimatedSprite.offset.x = -62

func attackRight():
	if !delay && !attacking && !dying:
		attacking = true
		attackingLeft = false
		$AnimatedSprite.offset.x = 0

func _on_AttackShapeLeft_body_entered(body):
	attackLeft()

func _on_AttackShapeRight_body_entered(body):
	attackRight()

func _on_AnimatedSprite_frame_changed():
	if $AnimatedSprite.animation == "attack": 
		if $AnimatedSprite.frame == 12:
			$Attack.play(0.0)
			if attackingLeft:
				$AttackHitboxLeft.monitoring = true
			else:
				$AttackHitboxRight.monitoring = true
		elif $AnimatedSprite.frame == 13:
			$AttackHitboxRight.monitoring = false
			$AttackHitboxLeft.monitoring = false
		
func _HitDetection(body):
	body.hit(damage)
