extends TextureRect

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
		$Base/Text.grab_focus();
		changeFocus();
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	if (Global.CurrentInput == "Gamepad"):
		$Base/Text.grab_focus();
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
	changeInput();
	if (get_parent().get_name() == "Editor"):
		get_parent().editingText = true;
	
	#Connect button focus signals
	var nodes = get_tree().get_nodes_in_group("Button");
	for node in nodes:
		node.connect("focus_entered", self, "focus_change");
	
	if (get_parent().get_name() == "Editor"):
		if (get_parent().CurrentMenu == "SideMenu"):
			rect_position.x += 610;

func setText(text):
	$GuideText.text = text;
	$Base/Text.text = "";

#General
func button_mouse_entered():
	$AudioSelectButton.play();
	get_node(mouseFocus+"/Selection/AnimationPlayer").play("idle");
	changeFocus();

func button_mouse_exited():
	$GuideText.grab_focus();
	get_node(mouseFocus+"/Selection/AnimationPlayer").play("RESET");
	changeFocus();

func _on_OkButton_pressed():
	if ($Base/Text.text != ""):
		$AudioButton.play();
		changeFocus();
		finish();
func _on_OkButton_mouse_entered():
	mouseFocus = "OkButton"; button_mouse_entered(); changeFocus();
func _on_OkButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_CancelButton_pressed():
	$AudioButton.play();
	changeFocus();
	finish(true);
func _on_CancelButton_mouse_entered():
	mouseFocus = "CancelButton"; button_mouse_entered(); changeFocus();
func _on_CancelButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func finish(cancel = false):
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
	
	get_parent().savedFocus = null;
	if (get_parent().get_name() == "Editor"):
		get_parent().editingText = false;
	
	if (!cancel):
		get_parent().enterTextFinished($Base/Text.text, type);
	
	queue_free();
