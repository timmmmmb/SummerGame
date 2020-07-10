extends Control

var _player_name = ""
var Network = load("res://scenes/Network.gd").new()

func _on_Singleplayer_pressed():
	get_node("MainMenu").visible = false
	get_node("LevelSelect").visible = true

func _on_Quit_pressed():
	get_tree().quit()

func _on_Back_pressed():
	get_node("MultiplayerLobby").visible = false
	get_node("LevelSelect").visible = false
	get_node("MainMenu").visible = true

func _on_TextField_text_changed(new_text):
	_player_name = new_text

func _on_Mulitplayer_pressed():
	get_node("MainMenu").visible = false
	get_node("MultiplayerLobby").visible = true

func _on_NameInput_text_changed(new_text):
	_player_name = new_text

func _on_Create_pressed():
	if _player_name == "":
		return
	Network.create_server(_player_name)
	_load_game()

func _on_Connect_pressed():
	if _player_name == "":
		return
	Network.connect_to_server(_player_name)
	_load_game()

func _load_game():
	get_tree().change_scene('res://Game.tscn')
