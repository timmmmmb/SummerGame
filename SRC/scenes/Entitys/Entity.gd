extends KinematicBody2D

var dying = false
export (int) var max_health = 5
var health = max_health
export (int) var damage = 2
var isHit = false
export (int) var run_speed = 200
var directionDistance = 0
var direction = true
signal death

# possible states idle, running and attacking
enum STATE{
	SLEEPING,
	IDLE,
	RUNNING,
	ATTACKING
}

func _ready():
	health = max_health

func die():
	dying = true
	health = 0
	emit_signal("death")
	
func hit(incomingDamage):
	health -= incomingDamage
	if health <= 0:
		die()
	else:
		isHit = true
		$HitEffect.play(0.0)

func setDirection(newDirection):
	if direction == newDirection:
		return
	else:
		scale.x = -1
		direction = newDirection


