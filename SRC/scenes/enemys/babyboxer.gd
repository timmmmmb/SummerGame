extends "res://scenes/Entity.gd"

var idle = true
var attacking = false
var delay = false
var playerIsLeft = false
var playerIsRight = false
var attackingLeft = false

func _physics_process(_delta):
	if playerIsLeft:
		attackLeft()
	elif playerIsRight: 
		attackRight()
		
	if idle:
		$AnimatedSprite.animation = "idle"
	elif attacking:
		$AnimatedSprite.flip_h = attackingLeft
		$AnimatedSprite.animation = "attack"
	elif dying:
		$AnimatedSprite.animation = "death"
	else:
		$AnimatedSprite.flip_h = get_parent().get_node("Player").position.x < position.x
		if $AnimatedSprite.flip_h:
			$AnimatedSprite.offset.x = -62
		else:
			$AnimatedSprite.offset.x = 0
		$AnimatedSprite.animation = "idleAwake"

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "attack":
		attacking = false
		delay = true
		$Delay.start()
		#check if the player was here at the end of animation
		if attackingLeft:
			if playerIsLeft:
				damage
				get_parent().get_node("Player").hit(damage)
		else:
			if playerIsRight:
				get_parent().get_node("Player").hit(damage)
	elif $AnimatedSprite.animation == "death":
		get_parent().remove_child(self)
		
func _on_Delay_timeout():
	delay = false

func _on_Trigger_body_entered(_body):
	idle = false

func attackLeft():
	if !delay && !attacking && !dying:
		attackingLeft = true
		attacking = true
		if $AnimatedSprite.offset.x == 0:
			$AnimatedSprite.offset.x = -62

func attackRight():
	if !delay && !attacking && !dying:
		attacking = true
		attackingLeft = false
		if $AnimatedSprite.offset.x != 0:
			$AnimatedSprite.offset.x = 0

func _on_AttackShapeLeft_body_entered(_body):
	playerIsLeft = true

func _on_AttackShapeRight_body_entered(_body):
	playerIsRight = true
	
func _on_AttackShapeLeft_body_exited(_body):
	playerIsLeft = false

func _on_AttackShapeRight_body_exited(_body):
	playerIsRight = false
