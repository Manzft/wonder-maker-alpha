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
	get_parent().get_node("GameMusic").pause_mode = PAUSE_MODE_INHERIT;
	get_tree().paused = true;
	$BaseContainer/AnimationPlayer.play("in");
	$AudioPause.play();
	
	var user = Global.courseGetUser(Global.currentlevel);
	
	$Separator/Label2.text = Global.currentCourseName;
	$Separator/Author.text = user;
	
	changeFocus();
	
	if (user != Global.USER_NAME):
		$BaseContainer/Base/Reset.rect_position.y += 62;
		$BaseContainer/Base/Exit.rect_position.y += 62;
		$BaseContainer/Base/Edit.hide();

func _process(_delta):
	if (Input.is_action_just_pressed("start")):
		_on_Close_pressed();

#Buttons
func button_mouse_entered():
	$AudioSelectButton.play();
	get_node(mouseFocus+"/Selection/AnimationPlayer").play("idle");
	changeFocus();

func button_mouse_exited():
	$Bg.grab_focus();
	get_node(mouseFocus+"/Selection/AnimationPlayer").play("RESET");
	changeFocus();

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
	Global.changeScene("res://scenes/ui/coursebot.tscn", get_parent())
	Global.coursePlaying = false;
	get_tree().paused = false;
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
