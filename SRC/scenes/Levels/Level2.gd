extends Node2D

func _on_BabyBoxer_death():
	get_parent().remove_child($Door)
