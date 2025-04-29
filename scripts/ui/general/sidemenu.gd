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

func _process(_delta):
	pass


#Buttons
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
	$TextureRect.grab_focus();
	if (mouseFocus != ""):
		get_node(mouseFocus+"/Selection/AnimationPlayer").play("RESET");
		get_node(mouseFocus).rect_pivot_offset.x = get_node(mouseFocus).rect_size.x/2;
		get_node(mouseFocus).rect_pivot_offset.y = get_node(mouseFocus).rect_size.y/2;
		var tween = get_tree().create_tween();
		var scale: Vector2 = str2var(get_node(mouseFocus).editor_description);
		tween.tween_property(get_node(mouseFocus), "rect_scale", scale, 0.0625);
	changeFocus();
	#Input.set_custom_mouse_cursor(load("res://sprites/ui/cursor_editor.png"));


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
