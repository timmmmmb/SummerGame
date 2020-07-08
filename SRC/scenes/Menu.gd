extends Control

func _on_Singleplayer_pressed():
	get_node("MainMenu").visible = false
	get_node("LevelSelect").visible = true
	pass # Replace with function body.


func _on_Quit_pressed():
	get_tree().quit()
	pass # Replace with function body.


func _on_Back_pressed():
	get_node("LevelSelect").visible = false
	get_node("MainMenu").visible = true
	pass # Replace with function body.
