extends Node2D

func _on_SpiritBoxer_death():
	remove_child(get_node("Door"))
