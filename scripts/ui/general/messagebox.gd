extends TextureRect

var Backwards = false;
var timer = 0.0;

var mouseFocus = "";

var branchmenu = false;

var realmenu = null;

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
	if (get_parent().get_name() == "Editor"):
		get_parent().editingText = true;
	$AnimationPlayer.play("in");
	changeInput();
	
	#Connect button focus signals
	var nodes = get_tree().get_nodes_in_group("Button");
	for node in nodes:
		node.connect("focus_entered", self, "focus_change");
	
	if (get_parent().get_name() == "Editor"):
		if (get_parent().CurrentMenu == "SideMenu"):
			rect_position.x += 610;
	
func _process(delta):
	if (!visible):
		timer += delta;
		if (timer >= 2):
			queue_free();

func setText(text):
	$Text.text = text;

#General
func button_mouse_entered():
	$AudioSelectButton.play();
	get_node(mouseFocus+"/Selection/AnimationPlayer").play("idle");
	changeFocus();

func button_mouse_exited():
	$Text.grab_focus();
	get_node(mouseFocus+"/Selection/AnimationPlayer").play("RESET");
	changeFocus();

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
		if (Global.CurrentInput == "Gamepad"):
			if (realmenu == null):
				if (get_parent().savedFocus != null):
					get_parent().savedFocus.grab_focus();
				get_parent().updateFocusSprite();
			else:
				if (realmenu.savedFocus != null):
					realmenu.savedFocus.grab_focus();
				realmenu.updateFocusSprite();
		if (get_parent().get_name() == "Editor"):
			get_parent().editingText = false;
		get_parent().savedFocus = null;
