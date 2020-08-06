extends Node2D

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		body.attackingEnabled = true


func _on_Area2D2_body_entered(body):
	if body.is_in_group("Player"):
		body.jetpackfuel = 500
