extends KinematicBody2D

var dying = false
export (int) var max_health = 5
var health = max_health
export (int) var damage = 2

func _ready():
	health = max_health

func death():
	dying = true
	
func hit(incomingDamage):
	health -= incomingDamage
	if health <= 0:
		death()
