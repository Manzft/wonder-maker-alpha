extends CanvasLayer

var savedFocus;
var mouseFocus = "";

var branchmenu = true;

var finishing = false;

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
	if (get_parent().CurrentMenu == "SideMenu"):
		var nodes = get_tree().get_nodes_in_group("Button");
		if (Global.CurrentInput == "Mouse"):
			mouseFocus = "";
			$TextureRect.grab_focus();
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
		if (Global.CurrentInput == "Gamepad"):
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);
		if (savedFocus == null):
			changeFocus();

func changeFocus():
	if (Global.CurrentInput == "Gamepad"):
		$BaseContainer/Base/Reset.grab_focus();
		updateFocusSprite();
	else:
		updateFocusSprite();

func updateFocusSprite():
	var nodes = get_tree().get_nodes_in_group("Button");
	var a;
	if (mouseFocus != ""):
		a = get_node(mouseFocus);
	else:
		a = $TextureRect;
	for node in nodes:
		if (node.has_focus() || a == node):
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
	
	get_parent().get_node("GameMusic").pause_mode = PAUSE_MODE_INHERIT;
	get_tree().paused = true;
	$BaseContainer/AnimationPlayer.play("in");
	$AudioPause.play();
	
	var user = ""
	if (Online.playing_online):
		user = Online.local_loaded_level.author
		$Separator/Icon.hide()
		$Separator/Label.hide()
		$Separator/CourseWorldIcon.show()
		$Separator/CourseWorldLabel.show()
		
		$Separator2/MarginContainer.show()
		
		#Likes
		var likes_node = find_node("LikeLabel")
		likes_node.text = str(Online.local_loaded_level.likes)
		
		#Dislikes
		var dislikes_node = find_node("DislikeLabel")
		dislikes_node.text = str(Online.local_loaded_level.dislikes)
		
		#Played
		var played_node = find_node("PlayedLabel")
		played_node.text = str(Online.local_loaded_level.played)
	else:
		user = Global.courseGetUser(Global.currentlevel)
	
	$Separator/Label2.text = Global.currentCourseName;
	$Separator/Author.text = user;
	
	changeFocus();
	
	if (Online.playing_online):
		$BaseContainer/Base/LikeButton.show()
		$BaseContainer/Base/DislikeButton.show()
		$BaseContainer/Base/Reset.rect_position.y += 124;
		$BaseContainer/Base/Exit.rect_position.y += 124;
		$BaseContainer/Base/Edit.hide();
		var dict: Dictionary
		for us in range(Online.local_accounts_data.size()):
			var e = Online.local_accounts_data[us]
			if (e.nick == Online.user_name):
				dict = e.levels_interacted[str(int(Online.local_loaded_level_data.id))]
		if (user == Online.user_name):
			$BaseContainer/Base/DislikeButton.modulate = Color("#999999")
			$BaseContainer/Base/LikeButton.modulate = Color("#999999")
			$BaseContainer/Base/DislikeButton.disabled = true
			$BaseContainer/Base/LikeButton.disabled = true
		else:
			if ("reacted" in dict):
				if (dict["reacted"] == "like"):
					$BaseContainer/Base/DislikeButton.modulate = Color("#999999")
					$BaseContainer/Base/LikeButton.self_modulate = Color("#eb625c")
					$BaseContainer/Base/LikeButton/Label.modulate = Color("#ffffff")
					$BaseContainer/Base/LikeButton/Icon.modulate = Color("#ffffff")
				elif (dict["reacted"] == "dislike"):
					$BaseContainer/Base/LikeButton.modulate = Color("#999999")
					$BaseContainer/Base/DislikeButton.self_modulate = Color("#5D56BE")
					$BaseContainer/Base/DislikeButton/Label.modulate = Color("#ffffff")
					$BaseContainer/Base/DislikeButton/Icon.modulate = Color("#ffffff")
				$BaseContainer/Base/DislikeButton.disabled = true
				$BaseContainer/Base/LikeButton.disabled = true
	elif (user != Global.USER_NAME || Global.toPublish):
		$BaseContainer/Base/Reset.rect_position.y += 62;
		$BaseContainer/Base/Exit.rect_position.y += 62;
		$BaseContainer/Base/Edit.hide();

func _process(_delta):
	if (Input.is_action_just_pressed("start")):
		_on_Close_pressed();

#Buttons
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
	tween.set_pause_mode(PAUSE_MODE_PROCESS)
	tween.tween_property(get_node(mouseFocus), "rect_scale", Vector2(scale.x*1.1, scale.y*1.1), 0.0625)

func button_mouse_exited():
	$Bg.grab_focus();
	if (mouseFocus != ""):
		if (!get_node(mouseFocus).is_in_group("LevelPanel") && !get_node(mouseFocus).is_in_group("IgnoreSelection")):
			get_node(mouseFocus+"/Selection/AnimationPlayer").play("RESET");
			get_node(mouseFocus).rect_pivot_offset.x = get_node(mouseFocus).rect_size.x/2;
			get_node(mouseFocus).rect_pivot_offset.y = get_node(mouseFocus).rect_size.y/2;
			var tween = get_tree().create_tween();
			var scale: Vector2 = str2var(get_node(mouseFocus).editor_description);
			tween.set_pause_mode(PAUSE_MODE_PROCESS)
			tween.tween_property(get_node(mouseFocus), "rect_scale", scale, 0.0625);
	changeFocus();
	#Input.set_custom_mouse_cursor(load("res://sprites/ui/cursor_editor.png"));


func _on_Close_pressed():
	if (!finishing):
		finishing = true;
		$AudioOpenMenu.play();
		$BaseContainer/AnimationPlayer.play("out");
func _on_Close_mouse_entered():
	mouseFocus = "BaseContainer/Base/Close"; button_mouse_entered(); changeFocus();
func _on_Close_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Reset_pressed():
	$AudioButton.play();
	get_node("../Editor")._on_Edit_pressed();
	$BaseContainer/AnimationPlayer.play("out");
	get_node("../GameUI").hide();
	get_tree().paused = false;
	
	#Restart Checkpoint
	Global.CheckpointGrid = Vector2(0, 0);
func _on_Reset_mouse_entered():
	mouseFocus = "BaseContainer/Base/Reset"; button_mouse_entered(); changeFocus();
func _on_Reset_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Exit_pressed():
	$AudioButton.play();
	if (Online.playing_online):
		Global.changeScene("res://scenes/ui/online.tscn", get_parent())
	else:
		Global.changeScene("res://scenes/ui/coursebot.tscn", get_parent())
	Global.coursePlaying = false;
	Global.toPublish = false
	Online.playing_online = false
	#get_tree().paused = false;
	get_parent().get_node("GameMusic").pause_mode = PAUSE_MODE_PROCESS;
	$BaseContainer/AnimationPlayer.play("out");
	get_node("../GameUI").hide();
func _on_Exit_mouse_entered():
	mouseFocus = "BaseContainer/Base/Exit"; button_mouse_entered(); changeFocus();
func _on_Exit_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Edit_pressed():
	$AudioButton.play();
	Global.changeScene("res://scenes/Level.tscn", get_parent())
	Global.coursePlaying = false;
	Global.toLoad = true;
	get_tree().paused = false;
	$BaseContainer/AnimationPlayer.play("out");
	get_node("../GameUI").hide();
func _on_Edit_mouse_entered():
	mouseFocus = "BaseContainer/Base/Edit"; button_mouse_entered(); changeFocus();
func _on_Edit_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "out"):
		get_tree().paused = false;
		queue_free();

func _on_Settings_pressed():
	Global.spawnSettings(self);
	$AudioButton.play();
func _on_Settings_mouse_entered():
	mouseFocus = "BaseContainer/Base/Settings"; button_mouse_entered(); changeFocus();
func _on_Settings_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Discord_pressed():
	savedFocus = getFocusNode();
	Global.showMessage("Wonder Cave\nServidor de Discord Oficial del Fangame\n(Copiado al portapapeles)", self);
	OS.set_clipboard("https://discord.gg/csGS3eKxvD");
	$AudioButton.play();
func _on_Discord_mouse_entered():
	mouseFocus = "BaseContainer/Base/Discord"; button_mouse_entered(); changeFocus();
func _on_Discord_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Youtube_pressed():
	savedFocus = getFocusNode();
	Global.showMessage("@Manzft27\nCanal de YouTube del creador del Fangame\n(Copiado al portapapeles)", self);
	OS.set_clipboard("https://youtube.com/@manzft27");
	$AudioButton.play();
func _on_Youtube_mouse_entered():
	mouseFocus = "BaseContainer/Base/Youtube"; button_mouse_entered(); changeFocus();
func _on_Youtube_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_LikeButton_pressed():
	if ($BaseContainer/Base/LikeButton.disabled): return
	$UIBlocker.show()
	_on_LikeButton_mouse_exited()
	var node = $BaseContainer/Base/LikeButton
	node.get_node("Selection").hide();
	node.get_node("Selection/AnimationPlayer").play("RESET");
	$Bg.grab_focus();
	$AudioLike.play();
	$BaseContainer/Base/LikeButton/Loading.show()
	$BaseContainer/Base/LikeButton/Icon.hide()
	$BaseContainer/Base/LikeButton/Label.hide()
	var result = yield(Online.add_like(), "completed")
	if (result == "success"):
		$BaseContainer/Base/DislikeButton.modulate = Color("#999999")
		$BaseContainer/Base/LikeButton.self_modulate = Color("#eb625c")
		$BaseContainer/Base/LikeButton/Label.modulate = Color("#ffffff")
		$BaseContainer/Base/LikeButton/Icon.modulate = Color("#ffffff")
		$BaseContainer/Base/DislikeButton.disabled = true
		$BaseContainer/Base/LikeButton.disabled = true
	$BaseContainer/Base/LikeButton/Icon.show()
	$BaseContainer/Base/LikeButton/Label.show()
	$BaseContainer/Base/LikeButton/Loading.hide()
	$UIBlocker.hide()
func _on_LikeButton_mouse_entered():
	if ($BaseContainer/Base/LikeButton.disabled): return
	mouseFocus = "BaseContainer/Base/LikeButton"; button_mouse_entered(); changeFocus();
func _on_LikeButton_mouse_exited():
	if ($BaseContainer/Base/LikeButton.disabled): return
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_DislikeButton_pressed():
	if ($BaseContainer/Base/DislikeButton.disabled): return
	$UIBlocker.show()
	_on_DislikeButton_mouse_exited()
	var node = $BaseContainer/Base/DislikeButton
	node.get_node("Selection").hide();
	node.get_node("Selection/AnimationPlayer").play("RESET");
	$Bg.grab_focus();
	$AudioDislike.play();
	$BaseContainer/Base/DislikeButton/Loading.show()
	$BaseContainer/Base/DislikeButton/Icon.hide()
	$BaseContainer/Base/DislikeButton/Label.hide()
	var result = yield(Online.add_dislike(), "completed")
	if (result == "success"):
		$BaseContainer/Base/LikeButton.modulate = Color("#999999")
		$BaseContainer/Base/DislikeButton.self_modulate = Color("#5D56BE")
		$BaseContainer/Base/DislikeButton/Label.modulate = Color("#ffffff")
		$BaseContainer/Base/DislikeButton/Icon.modulate = Color("#ffffff")
		$BaseContainer/Base/DislikeButton.disabled = true
		$BaseContainer/Base/LikeButton.disabled = true
	$BaseContainer/Base/DislikeButton/Loading.hide()
	$BaseContainer/Base/DislikeButton/Icon.show()
	$BaseContainer/Base/DislikeButton/Label.show()
	$UIBlocker.hide()
func _on_DislikeButton_mouse_entered():
	if ($BaseContainer/Base/DislikeButton.disabled): return
	mouseFocus = "BaseContainer/Base/DislikeButton"; button_mouse_entered(); changeFocus();
func _on_DislikeButton_mouse_exited():
	if ($BaseContainer/Base/DislikeButton.disabled): return
	button_mouse_exited(); mouseFocus = ""; changeFocus();

