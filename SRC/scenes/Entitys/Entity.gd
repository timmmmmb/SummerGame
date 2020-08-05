extends KinematicBody2D

var dying = false
export (int) var max_health = 5
var health = max_health
export (int) var damage = 2
var hit = false

func _ready():
	health = max_health

func die():
	dying = true
	health = 0
	
func hit(incomingDamage):
	health -= incomingDamage
	if health <= 0:
		die()
	else:
		hit = true
		$HitEffect.play(0.0)

