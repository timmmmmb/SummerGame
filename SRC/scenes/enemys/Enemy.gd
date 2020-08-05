extends KinematicBody2D

var dying = false
var health = 5

func _ready():
	pass # Replace with function body.

func death():
	dying = true
	
func hit(damage):
	health -= damage
	if health <= 0:
		death()
