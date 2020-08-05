extends "Enemy.gd"

var idle = true
var attacking = false
var delay = false
var playerIsLeft = false
var playerIsRight = false
var attackingLeft = false

func _physics_process(delta):
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
		$AnimatedSprite.animation = "idleAwake"

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "attack":
		attacking = false
		delay = true
		$Delay.start()


func _on_Delay_timeout():
	delay = false


func _on_Trigger_body_entered(body):
	idle = false
	
func attackLeft():
	if !delay:
		attackingLeft = true
		attacking = true
		if $AnimatedSprite.offset.x == 0:
			$AnimatedSprite.offset.x = -62

func attackRight():
	if !delay:
		attacking = true
		attackingLeft = false
		if $AnimatedSprite.offset.x != 0:
			$AnimatedSprite.offset.x = 0

func _on_AttackShapeLeft_body_entered(body):
	playerIsLeft = true

func _on_AttackShapeRight_body_entered(body):
	playerIsRight = true
	
func _on_AttackShapeLeft_body_exited(body):
	playerIsLeft = false


func _on_AttackShapeRight_body_exited(body):
	playerIsRight = false
