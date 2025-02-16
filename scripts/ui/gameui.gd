extends CanvasLayer

var savedFocus;
var mouseFocus = "";

var branchmenu = true;

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
			$Control.grab_focus();
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
		if (Global.CurrentInput == "Gamepad"):
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);
		if (savedFocus == null):
			changeFocus();

func changeFocus():
	if (Global.CurrentInput == "Gamepad"):
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
	if (Global.coursePlaying):
		$Pause.show();
	else:
		$Pause.hide();

func _process(_delta):
	pass

#Buttons
func button_mouse_entered():
	$AudioSelectButton.play();
	get_node(mouseFocus+"/Selection/AnimationPlayer").play("idle");
	changeFocus();

func button_mouse_exited():
	$Control.grab_focus();
	if (mouseFocus != ""):
		get_node(mouseFocus+"/Selection/AnimationPlayer").play("RESET");
	changeFocus();

func _on_Pause_pressed():
	$AudioButton.play();
	var inst = load("res://scenes/ui/pausemenu.tscn").instance();
	get_parent().add_child(inst);
	$Control.grab_focus();
	updateFocusSprite();
func _on_Pause_mouse_entered():
	mouseFocus = "Pause"; button_mouse_entered(); changeFocus();
func _on_Pause_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();
