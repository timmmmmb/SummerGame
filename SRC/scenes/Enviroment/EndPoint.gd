extends Area2D

func _on_EndPoint_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().change_scene("res://scenes/Menu.tscn")
