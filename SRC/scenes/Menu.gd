extends Control

var _player_name = ""
var Network = load("res://scenes/Network.gd").new()
var currentSong = 2
const maxSongs = 4

func _on_Singleplayer_pressed():
	get_node("MainMenu").visible = false
	get_node("LevelSelect").visible = true

func _on_Quit_pressed():
	get_tree().quit()

func _on_Back_pressed():
	get_node("MultiplayerLobby").visible = false
	get_node("LevelSelect").visible = false
	get_node("Credits").visible = false
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


func _on_Credits_pressed():
	get_node("MainMenu").visible = false
	get_node("Credits").visible = true


func _on_Level1_pressed():
	get_tree().change_scene("res://scenes/Levels/Level1.tscn")


func _on_MenuMusic_finished():
	currentSong = (currentSong+1)%maxSongs
	get_node("MenuMusic"+str(currentSong)).play()


func _on_Level2_pressed():
	get_tree().change_scene("res://scenes/Levels/Level2.tscn")


func _on_Level3_pressed():
	get_tree().change_scene("res://scenes/Levels/Level3.tscn")
