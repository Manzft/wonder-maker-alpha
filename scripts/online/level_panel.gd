extends TextureButton

onready var death_porcentage_node = $MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/ClearRatePanel/VBoxContainer
onready var death_clear_rate_count_node = $MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/ClearRatePanel/VBoxContainer2
onready var like_count_node = $MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer/HBoxContainer
onready var dislike_count_node = $MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer/HBoxContainer3

onready var sel_upleft = $Selection/UpLeft
onready var sel_upright = $Selection/UpRight
onready var sel_downleft = $Selection/DownLeft
onready var sel_downright = $Selection/DownRight

onready var download_button = $MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer2/DownloadButton
onready var play_button = $MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer2/PlayButton

onready var tree = $"../../../../.."

var selbox_interval: float = 0.25

var level_data: Dictionary

func _ready():
	connect("pressed", self, "_on_pressed")
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	
	$Timer.connect("timeout", self, "_on_timer_timeout")
	
	download_button.connect("pressed", self, "_on_download_button_pressed")
	download_button.connect("mouse_entered", self, "_on_download_button_mouse_entered")
	download_button.connect("mouse_exited", self, "_on_download_button_mouse_exited")
	
	play_button.connect("pressed", self, "_on_play_button_pressed")
	play_button.connect("mouse_entered", self, "_on_play_button_mouse_entered")
	play_button.connect("mouse_exited", self, "_on_play_button_mouse_exited")

func _on_timer_timeout() -> void:
	if (death_porcentage_node.visible):
		death_porcentage_node.hide()
		death_clear_rate_count_node.show()
		if (tree.selected_level_panel == self):
			like_count_node.hide()
			dislike_count_node.show()
		else:
			like_count_node.show()
			dislike_count_node.hide()
	else:
		death_porcentage_node.show()
		death_clear_rate_count_node.hide()
		if (tree.selected_level_panel == self):
			like_count_node.show()
			dislike_count_node.hide()
		else:
			like_count_node.show()
			dislike_count_node.hide()

func _on_pressed() -> void:
	if (tree.selected_level_panel != self):
		tree.update_selected_level_panel(self)
		_on_mouse_exited()
		$"../../../../../AudioButton".play();
func _on_mouse_entered() -> void:
	if (tree.selected_level_panel != self):
		tree.mouseFocus = str(get_path()); tree.button_mouse_entered(); tree.changeFocus();
func _on_mouse_exited() -> void:
	tree.button_mouse_exited(); tree.mouseFocus = ""; tree.changeFocus();

func _on_download_button_pressed() -> void:
	$"../../../../../AudioButton".play();
func _on_download_button_mouse_entered() -> void:
	tree.mouseFocus = str(download_button.get_path()); tree.button_mouse_entered(); tree.changeFocus();
func _on_download_button_mouse_exited() -> void:
	tree.button_mouse_exited(); tree.mouseFocus = ""; tree.changeFocus();

func _on_play_button_pressed() -> void:
	$"../../../../../AudioButton".play();
	
	Online.local_loaded_level_data = level_data
	Global.currentCourseName = find_node("LevelName").text
	
	Online.persistency_menu = tree.selected_tab.name
	
	Online.playing_online = true
	Global.coursePlaying = true;
	Global.changeScene("res://scenes/ui/playintro.tscn");
	Global.toLoad = true;
func _on_play_button_mouse_entered() -> void:
	tree.mouseFocus = str(play_button.get_path()); tree.button_mouse_entered(); tree.changeFocus();
func _on_play_button_mouse_exited() -> void:
	tree.button_mouse_exited(); tree.mouseFocus = ""; tree.changeFocus();
