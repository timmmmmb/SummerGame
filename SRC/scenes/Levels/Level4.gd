extends Node2D

func _on_Trash_Monster_death():
	remove_child(get_node("Door"))
