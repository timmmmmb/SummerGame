extends KinematicBody2D

var dying = false
export (int) var max_health = 5
var health = max_health
export (int) var damage = 2
export (int) var run_speed = 200
var directionDistance = 0
var direction = true
signal death
var velocity = Vector2()
var state = STATE.SLEEPING
# possible states idle, running and attacking
enum STATE{
	SLEEPING,
	IDLE,
	RUNNING,
	ATTACKING,
	HIT,
	SPECIAL,
	JUMPING,
	FLYING
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
		$HitEffect.play(0.0)
#		state = STATE.HIT
		
func afterHit():
	state = STATE.IDLE

func setDirection(newDirection):
	if direction == newDirection:
		return
	else:
		scale.x = -1
		direction = newDirection


