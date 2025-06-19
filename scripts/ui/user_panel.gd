extends TextureButton

var tree

var account_id: String = ""

func _set_account_id(_account_id: String) -> void:
	account_id = _account_id
	tree = get_tree().current_scene


func _on_ProfileButton_pressed() -> void:
	tree.get_node("AudioButton").play()
	tree.changeFocus()
	Global.showProfile(account_id, tree)
	
func _on_ProfileButton_mouse_entered() -> void:
	tree.mouseFocus = "LeaderboardsMenu/ScrollContainer/MarginContainer/VBoxContainer/"+name+"/ProfileButton"
	tree.button_mouse_entered(); tree.changeFocus();
func _on_ProfileButton_mouse_exited() -> void:
	tree.button_mouse_exited(); tree.mouseFocus = ""; tree.changeFocus();
