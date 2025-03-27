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
		$Background.grab_focus();
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
	$ControlsTransparency/HSlider.min_value = Global.min_controls_transparency;
	$ControlsTransparency/HSlider.max_value = Global.max_controls_transparency;
	
	$PhysicsSpeed/HSlider.min_value = Global.min_entity_physics_speed;
	$PhysicsSpeed/HSlider.max_value = Global.max_entity_physics_speed;
	
	$PhysicsSpeed/HSlider.value = int(Global.ENTITY_PHYSICS_SPEED);
	$ControlsTransparency/HSlider.value = int(Global.CONTROLS_TRANSPARENCY);
	
	yield(get_tree().create_timer(0.125), "timeout");
	$AnimationPlayer.play("in");
	
func setState(node : Node, value : bool = false):
	if (value):
		node.get_node("StateIcon").texture = load("res://sprites/ui/settings/check_icon.png")
	else:
		node.get_node("StateIcon").texture = load("res://sprites/ui/settings/x.png")
	
func _process(delta):
	if (!visible):
		timer += delta;
		if (timer >= 2):
			queue_free();
			
	$ControlsTransparency/HSlider/Text.text = str($ControlsTransparency/HSlider.value)+"%"
	$PhysicsSpeed/HSlider/Text.text = str($PhysicsSpeed/HSlider.value)+"%"
	
	Global.CONTROLS_TRANSPARENCY = $ControlsTransparency/HSlider.value;
	Global.ENTITY_PHYSICS_SPEED = $PhysicsSpeed/HSlider.value
	
	setState($VSync, Global.VSYNC)
	setState($ShowFPS, Global.SHOW_FPS)
	setState($ShowPauseButton, Global.SHOW_PAUSE_BUTTON)
	setState($AutoSaving, Global.AUTO_SAVING)
	setState($Force169, Global.SCREEN_16_9)
	setState($SnowParticles, Global.SNOW_FALLING_PARTICLES)
	setState($PhysicsInterpolation, Global.PHYSICS_INTERPOLATION)

#General
func button_mouse_entered():
	$AudioSelectButton.play();
	get_node(mouseFocus+"/Selection/AnimationPlayer").play("idle");
	changeFocus();

func button_mouse_exited():
	$Background.grab_focus();
	get_node(mouseFocus+"/Selection/AnimationPlayer").play("RESET");
	changeFocus();

func _on_OkButton_pressed():
	if (!Backwards):
		$AudioButton.play();
		$AnimationPlayer.play_backwards("in");
		Backwards = true;
		changeFocus();
		Global.saveSettings()
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

func _on_VSync_pressed():
	$AudioButton.play()
	Global.VSYNC = not Global.VSYNC
	OS.vsync_enabled = Global.VSYNC;
func _on_VSync_mouse_entered():
	if (!Backwards):
		mouseFocus = "VSync"; button_mouse_entered(); changeFocus();
func _on_VSync_mouse_exited():
	if (!Backwards):
		button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Force169_pressed():
	$AudioButton.play()
	Global.VSYNC = not Global.VSYNC
	OS.vsync_enabled = Global.VSYNC;
func _on_Force169_mouse_entered():
	if (!Backwards):
		mouseFocus = "Force169"; button_mouse_entered(); changeFocus();
func _on_Force169_mouse_exited():
	if (!Backwards):
		button_mouse_exited(); mouseFocus = ""; changeFocus();
	

func _on_HSlider_value_changed(value):
	$AudioKey.play();
