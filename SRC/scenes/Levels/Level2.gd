extends Node2D

func _on_BabyBoxer_death():
	remove_child(get_node("Door"))
