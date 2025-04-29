extends TextureRect

var Backwards = false;
var timer = 0.0;

var mouseFocus = "";

var branchmenu = false;

var realmenu = null;

var type = "";

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
		$Text.grab_focus();
		changeFocus();
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	if (Global.CurrentInput == "Gamepad"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);
	changeFocus();

func changeFocus():
	if (Global.CurrentInput == "Gamepad"):
		$OkButton.grab_focus();
		updateFocusSprite();
	else:
		updateFocusSprite();

func updateFocusSprite():
	var nodes = get_tree().get_nodes_in_group("Button");
	for node in nodes:
		if (node.has_focus() || get_node(mouseFocus) == node):
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
	
	if (get_parent().get_name() == "Editor"):
		get_parent().editingText = true;
	changeInput();
	
	#Connect button focus signals
	var nodes = get_tree().get_nodes_in_group("Button");
	for node in nodes:
		node.connect("focus_entered", self, "focus_change");
	
	if ("CurrentMenu" in get_parent()):
		if (get_parent().CurrentMenu == "SideMenu"):
			rect_position.x += 610;
			
	yield(get_tree().create_timer(0.125), "timeout");
	$AnimationPlayer.play("in");
	
func _process(delta):
	if (!visible):
		timer += delta;
		if (timer >= 2):
			queue_free();

func setText(text):
	$Text.text = text;

#General
func button_mouse_entered():
	#$AudioSelectButton.pitch_scale = randf_range(0.9, 1.1)
	$AudioSelectButton.play()
	get_node(mouseFocus+"/Selection/AnimationPlayer").play("idle")
	changeFocus()
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
	$Text.grab_focus();
	if (mouseFocus != ""):
		get_node(mouseFocus+"/Selection/AnimationPlayer").play("RESET");
		get_node(mouseFocus).rect_pivot_offset.x = get_node(mouseFocus).rect_size.x/2;
		get_node(mouseFocus).rect_pivot_offset.y = get_node(mouseFocus).rect_size.y/2;
		var tween = get_tree().create_tween();
		var scale: Vector2 = str2var(get_node(mouseFocus).editor_description);
		tween.tween_property(get_node(mouseFocus), "rect_scale", scale, 0.0625);
	changeFocus();
	#Input.set_custom_mouse_cursor(load("res://sprites/ui/cursor_editor.png"));

func _on_OkButton_pressed():
	if (!Backwards):
		$AudioButton.play();
		$AnimationPlayer.play_backwards("in");
		Backwards = true;
		changeFocus();
func _on_OkButton_mouse_entered():
	if (!Backwards):
		mouseFocus = "OkButton"; button_mouse_entered(); changeFocus();
func _on_OkButton_mouse_exited():
	if (!Backwards):
		button_mouse_exited(); mouseFocus = ""; changeFocus();
	
func _on_AnimationPlayer_animation_finished(anim_name):
	if (Backwards):
		hide();
		if ("savedFocus" in get_parent()):
			if (Global.CurrentInput == "Gamepad"):
				if (realmenu == null):
					if (get_parent().savedFocus != null):
						get_parent().savedFocus.grab_focus();
					get_parent().updateFocusSprite();
				else:
					if (realmenu.savedFocus != null):
						realmenu.savedFocus.grab_focus();
					realmenu.updateFocusSprite();
			get_parent().savedFocus = null;
		if (get_parent().get_name() == "Editor"):
			get_parent().editingText = false;
		
		if (get_parent().has_method("messageBoxFinished")):
			get_parent().messageBoxFinished(type);
