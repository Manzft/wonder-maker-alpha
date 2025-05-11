extends CanvasLayer

var CurrentMenu: String = "FinishLevelOnline";

var savedFocus;
var mouseFocus = "";

var branchmenu = false;

func _input(event):
	if (Global.CurrentInput == "Gamepad"):
		updateFocusSprite();

func getFocusNode():
	var nodes = get_tree().get_nodes_in_group("Button");
	for node in nodes:
		if (node.has_focus() || get_node(mouseFocus) == node):
			return node;

func focus_change():
	$AudioSelectButton.play();

func changeInput():
	var nodes = get_tree().get_nodes_in_group("Button");
	if (Global.CurrentInput == "Mouse"):
		mouseFocus = "";
		$FPS.grab_focus();
		changeFocus();
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	if (Global.CurrentInput == "Gamepad"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);
	changeFocus();

func changeFocus():
	if (Global.CurrentInput == "Gamepad"):
		match (CurrentMenu):
			"StartMenu":
				#$StartButton.grab_focus();
				pass
			"StartMenuAction":
				$ActionButtons/MakeButton.grab_focus();
			"StartMenuPlay":
				$PlayButtons/Coursebot.grab_focus();
		updateFocusSprite();
	else:
		updateFocusSprite();

func updateFocusSprite():
	var nodes = get_tree().get_nodes_in_group("Button");
	for node in nodes:
		var check;
		if (mouseFocus != "" && Global.CurrentInput != "Gamepad"):
			check = node.has_focus() || get_node(mouseFocus) == node;
		else:
			check = node.has_focus()
		if (check):
			node.get_node("Selection").show();
			node.get_node("Selection/AnimationPlayer").play("idle");
			#node.texture_normal = node.texture_hover;
		else:
			#node.texture_normal = node.texture_disabled;
			node.get_node("Selection").hide();
			node.get_node("Selection/AnimationPlayer").play("RESET");

func _ready():
	#Fix Selection Corners
	for node in get_tree().get_nodes_in_group("Selection"):
		node.get_node("UpRight").rect_rotation = 90.0
		node.get_node("DownRight").rect_rotation = 180.0
		node.get_node("DownLeft").rect_rotation = 270.0
		
		node.get_node("UpLeft").rect_scale = Vector2(0.5, 0.5)
		node.get_node("UpRight").rect_scale = Vector2(0.5, 0.5)
		node.get_node("DownRight").rect_scale = Vector2(0.5, 0.5)
		node.get_node("DownLeft").rect_scale = Vector2(0.5, 0.5)
		
		node.get_node("UpLeft").stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		node.get_node("UpRight").stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		node.get_node("DownRight").stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		node.get_node("DownLeft").stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		node.get_node("AnimationPlayer").playback_speed = 1.0
	
	#Transition
	Global.transition();
	
	#Connect button focus signals
	var nodes = get_tree().get_nodes_in_group("Button");
	for node in nodes:
		node.connect("focus_entered", self, "focus_change");
	
	var user = Global.courseGetUser(Online.local_loaded_level_data.data)
	
	$ColorRect/Control/Separator/Label.text = Online.local_loaded_level_data.name
	$ColorRect/Control/Separator/Author.text = user
	
	var dict: Dictionary
	for us in range(Online.local_accounts_data.size()):
		var e = Online.local_accounts_data[us]
		if (e.nick == Online.user_name):
			dict = e.levels_interacted[str(int(Online.local_loaded_level_data.id))]
	if (user == Online.user_name):
		$ColorRect/Control/DislikeButton.modulate = Color("#999999")
		$ColorRect/Control/LikeButton.modulate = Color("#999999")
		$ColorRect/Control/DislikeButton.disabled = true
		$ColorRect/Control/LikeButton.disabled = true
	else:
		if ("reacted" in dict):
			if (dict["reacted"] == "like"):
				$ColorRect/Control/DislikeButton.modulate = Color("#999999")
				$ColorRect/Control/LikeButton.self_modulate = Color("#eb625c")
				$ColorRect/Control/LikeButton/Label.modulate = Color("#ffffff")
				$ColorRect/Control/LikeButton/Icon.modulate = Color("#ffffff")
			elif (dict["reacted"] == "dislike"):
				$ColorRect/Control/LikeButton.modulate = Color("#999999")
				$ColorRect/Control/DislikeButton.self_modulate = Color("#5D56BE")
				$ColorRect/Control/DislikeButton/Label.modulate = Color("#ffffff")
				$ColorRect/Control/DislikeButton/Icon.modulate = Color("#ffffff")
			$ColorRect/Control/DislikeButton.disabled = true
			$ColorRect/Control/LikeButton.disabled = true
	
	yield(get_tree().create_timer(1.0), "timeout")
	$AnimationPlayer2.play("start")
	$AudioCourseClear.play()
	Online.playing_online = false

#General
func button_mouse_entered():
	#$AudioSelectButton.pitch_scale = randf_range(0.9, 1.1)
	$AudioSelectButton.play()
	get_node(mouseFocus+"/Selection/AnimationPlayer").play("idle")
	changeFocus()
	if (get_node(mouseFocus).is_in_group("LevelPanel") ||
	get_node(mouseFocus).is_in_group("IgnoreSelection")):
		return
	#Input.set_custom_mouse_cursor(load("res://sprites/ui/cursor.png"))
	get_node(mouseFocus).rect_pivot_offset.x = get_node(mouseFocus).rect_size.x/2
	get_node(mouseFocus).rect_pivot_offset.y = get_node(mouseFocus).rect_size.y/2
	var scale: Vector2 = Vector2(0, 0)
	if (get_node(mouseFocus).editor_description == ""):
		scale = get_node(mouseFocus).rect_scale
	else:
		scale = str2var(get_node(mouseFocus).editor_description)
	get_node(mouseFocus).editor_description = var2str(scale)
	var tween = get_tree().create_tween()
	tween.tween_property(get_node(mouseFocus), "rect_scale", Vector2(scale.x*1.1, scale.y*1.1), 0.0625)

func button_mouse_exited():
	$FPS.grab_focus();
	if (mouseFocus != ""):
		if (!get_node(mouseFocus).is_in_group("LevelPanel") && !get_node(mouseFocus).is_in_group("IgnoreSelection")):
			get_node(mouseFocus+"/Selection/AnimationPlayer").play("RESET");
			get_node(mouseFocus).rect_pivot_offset.x = get_node(mouseFocus).rect_size.x/2;
			get_node(mouseFocus).rect_pivot_offset.y = get_node(mouseFocus).rect_size.y/2;
			var tween = get_tree().create_tween();
			var scale: Vector2 = str2var(get_node(mouseFocus).editor_description);
			tween.tween_property(get_node(mouseFocus), "rect_scale", scale, 0.0625);
	changeFocus();
	#Input.set_custom_mouse_cursor(load("res://sprites/ui/cursor_editor.png"));

func _on_ExitButton_pressed() -> void:
	$AudioButton.play()
	Global.changeScene("res://scenes/ui/online.tscn", self)
func _on_ExitButton_mouse_entered() -> void:
	mouseFocus = "ColorRect/Control/ExitButton"; button_mouse_entered(); changeFocus();
func _on_ExitButton_mouse_exited() -> void:
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_ResetButton_pressed() -> void:
	$AudioButton.play()
	Online.playing_online = true
	Global.coursePlaying = true;
	Global.changeScene("res://scenes/ui/playintro.tscn", self);
	Global.toLoad = true;
func _on_ResetButton_mouse_entered() -> void:
	mouseFocus = "ColorRect/Control/ResetButton"; button_mouse_entered(); changeFocus();
func _on_ResetButton_mouse_exited() -> void:
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_LikeButton_pressed():
	if ($ColorRect/Control/LikeButton.disabled): return
	$UIBlocker.show()
	_on_LikeButton_mouse_exited()
	var node = $ColorRect/Control/LikeButton
	node.get_node("Selection").hide();
	node.get_node("Selection/AnimationPlayer").play("RESET");
	$FPS.grab_focus();
	$AudioLike.play();
	$ColorRect/Control/LikeButton/Loading.show()
	$ColorRect/Control/LikeButton/Icon.hide()
	$ColorRect/Control/LikeButton/Label.hide()
	var result = yield(Online.add_like(), "completed")
	if (result == "success"):
		$ColorRect/Control/DislikeButton.modulate = Color("#999999")
		$ColorRect/Control/LikeButton.self_modulate = Color("#eb625c")
		$ColorRect/Control/LikeButton/Label.modulate = Color("#ffffff")
		$ColorRect/Control/LikeButton/Icon.modulate = Color("#ffffff")
		$ColorRect/Control/DislikeButton.disabled = true
		$ColorRect/Control/LikeButton.disabled = true
	$ColorRect/Control/LikeButton/Icon.show()
	$ColorRect/Control/LikeButton/Label.show()
	$ColorRect/Control/LikeButton/Loading.hide()
	$UIBlocker.hide()
func _on_LikeButton_mouse_entered():
	if ($ColorRect/Control/LikeButton.disabled): return
	mouseFocus = "ColorRect/Control/LikeButton"; button_mouse_entered(); changeFocus();
func _on_LikeButton_mouse_exited():
	if ($ColorRect/Control/LikeButton.disabled): return
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_DislikeButton_pressed():
	if ($ColorRect/Control/DislikeButton.disabled): return
	$UIBlocker.show()
	_on_DislikeButton_mouse_exited()
	var node = $ColorRect/Control/DislikeButton
	node.get_node("Selection").hide();
	node.get_node("Selection/AnimationPlayer").play("RESET");
	$FPS.grab_focus();
	$AudioDislike.play();
	$ColorRect/Control/DislikeButton/Loading.show()
	$ColorRect/Control/DislikeButton/Icon.hide()
	$ColorRect/Control/DislikeButton/Label.hide()
	var result = yield(Online.add_dislike(), "completed")
	if (result == "success"):
		$ColorRect/Control/LikeButton.modulate = Color("#999999")
		$ColorRect/Control/DislikeButton.self_modulate = Color("#5D56BE")
		$ColorRect/Control/DislikeButton/Label.modulate = Color("#ffffff")
		$ColorRect/Control/DislikeButton/Icon.modulate = Color("#ffffff")
		$ColorRect/Control/DislikeButton.disabled = true
		$ColorRect/Control/LikeButton.disabled = true
	$ColorRect/Control/DislikeButton/Loading.hide()
	$ColorRect/Control/DislikeButton/Icon.show()
	$ColorRect/Control/DislikeButton/Label.show()
	$UIBlocker.hide()
func _on_DislikeButton_mouse_entered():
	if ($ColorRect/Control/DislikeButton.disabled): return
	mouseFocus = "ColorRect/Control/DislikeButton"; button_mouse_entered(); changeFocus();
func _on_DislikeButton_mouse_exited():
	if ($ColorRect/Control/DislikeButton.disabled): return
	button_mouse_exited(); mouseFocus = ""; changeFocus();
