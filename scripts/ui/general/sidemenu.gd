extends Control

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
			$TextureRect.grab_focus();
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
		if (Global.CurrentInput == "Gamepad"):
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);
		if (savedFocus == null):
			changeFocus();

func changeFocus():
	if (Global.CurrentInput == "Gamepad"):
		$CourseMaker.grab_focus();
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
	pass

func _process(_delta):
	pass


#Buttons
func button_mouse_entered():
	$AudioSelectButton.play();
	get_node(mouseFocus+"/Selection/AnimationPlayer").play("idle");
	changeFocus();

func button_mouse_exited():
	$TextureRect.grab_focus();
	get_node(mouseFocus+"/Selection/AnimationPlayer").play("RESET");
	changeFocus();

func _on_Close_pressed():
	get_parent().sidemenu();
	$AudioOpenMenu.play();
func _on_Close_mouse_entered():
	mouseFocus = "Close"; button_mouse_entered(); changeFocus();
func _on_Close_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_StoryMode_pressed():
	savedFocus = getFocusNode();
	Global.showMessage("¡Aún estamos trabajando en esto!", get_parent(), self);
	$AudioPlayButton.play();
func _on_StoryMode_mouse_entered():
	mouseFocus = "StoryMode"; button_mouse_entered(); changeFocus();
func _on_StoryMode_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Exit_pressed():
	Global.changeScene("res://scenes/ui/MainMenu.tscn");
	$AudioButton.play();
func _on_Exit_mouse_entered():
	mouseFocus = "Exit"; button_mouse_entered(); changeFocus();
func _on_Exit_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_CourseWorld_pressed():
	savedFocus = getFocusNode();
	Global.showMessage("¡Aún estamos trabajando en esto!", get_parent(), self);
	$AudioPlayButton.play();
func _on_CourseWorld_mouse_entered():
	mouseFocus = "CourseWorld"; button_mouse_entered(); changeFocus();
func _on_CourseWorld_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_CourseMaker_pressed():
	Global.currentlevel = "";
	Global.changeScene("res://scenes/Level.tscn");
	$AudioPlayButton.play();
func _on_CourseMaker_mouse_entered():
	mouseFocus = "CourseMaker"; button_mouse_entered(); changeFocus();
func _on_CourseMaker_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_WorldMaker_pressed():
	savedFocus = getFocusNode();
	Global.showMessage("¡Aún estamos trabajando en esto!", get_parent(), self);
	$AudioPlayButton.play();
func _on_WorldMaker_mouse_entered():
	mouseFocus = "WorldMaker"; button_mouse_entered(); changeFocus();
func _on_WorldMaker_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Coursebot_pressed():
	Global.changeScene("res://scenes/ui/coursebot.tscn");
	$AudioPlayButton.play();
func _on_Coursebot_mouse_entered():
	mouseFocus = "Coursebot"; button_mouse_entered(); changeFocus();
func _on_Coursebot_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Worldbot_pressed():
	savedFocus = getFocusNode();
	Global.showMessage("¡Aún estamos trabajando en esto!", get_parent(), self);
	$AudioPlayButton.play();
func _on_Worldbot_mouse_entered():
	mouseFocus = "Worldbot"; button_mouse_entered(); changeFocus();
func _on_Worldbot_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Notifications_pressed():
	savedFocus = getFocusNode();
	Global.showMessage("¡Aún estamos trabajando en esto!", get_parent(), self);
	$AudioButton.play();
func _on_Notifications_mouse_entered():
	mouseFocus = "Notifications"; button_mouse_entered(); changeFocus();
func _on_Notifications_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Settings_pressed():
#	savedFocus = getFocusNode();
#	Global.showMessage("¡Aún estamos trabajando en esto!", get_parent(), self);
	Global.spawnSettings(get_parent(), self);
	$AudioButton.play();
func _on_Settings_mouse_entered():
	mouseFocus = "Settings"; button_mouse_entered(); changeFocus();
func _on_Settings_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();
	
func _on_ManzftChallenge_pressed():
	savedFocus = getFocusNode();
	Global.showMessage("El Manzft Challenge aún está en desarrollo, vendrá en la Alpha v1.3 Fix.", get_parent(), self);
	$AudioPlayButton.play();
func _on_ManzftChallenge_mouse_entered():
	mouseFocus = "ManzftChallenge"; button_mouse_entered(); changeFocus();
func _on_ManzftChallenge_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Controls_pressed():
	savedFocus = getFocusNode();
	Global.showMessage("¡Aún estamos trabajando en esto!", get_parent(), self);
	$AudioButton.play();
func _on_Controls_mouse_entered():
	mouseFocus = "Controls"; button_mouse_entered(); changeFocus();
func _on_Controls_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Discord_pressed():
	savedFocus = getFocusNode();
	Global.showMessage("Wonder Cave\nServidor de Discord Oficial del Fangame\n(Copiado al portapapeles)", get_parent(), self);
	OS.set_clipboard("https://discord.gg/csGS3eKxvD");
	$AudioButton.play();
func _on_Discord_mouse_entered():
	mouseFocus = "Discord"; button_mouse_entered(); changeFocus();
func _on_Discord_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Youtube_pressed():
	savedFocus = getFocusNode();
	Global.showMessage("@Manzft27\nCanal de YouTube del creador del Fangame\n(Copiado al portapapeles)", get_parent(), self);
	OS.set_clipboard("https://youtube.com/@manzft27");
	$AudioButton.play();
func _on_Youtube_mouse_entered():
	mouseFocus = "Youtube"; button_mouse_entered(); changeFocus();
func _on_Youtube_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();
