extends Node2D

func _on_SpiritBoxer_death():
	get_parent().remove_child($Door)
