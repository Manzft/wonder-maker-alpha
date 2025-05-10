extends CanvasLayer

var CurrentMenu = "StartMenu";

#NOTE: release_focus();

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
	
	#Restart Checkpoint
	Global.CheckpointGrid = Vector2(0, 0);
	
	$StartButton/AnimationPlayer.play("inout");
	$WonderTitle/SplashContainer/AnimationPlayer.play("idle");
	var splashText = getSplashText();
	$WonderTitle/SplashContainer/Splash.text = splashText;
	$WonderTitle/SplashContainer/Splash/Shadow.text = splashText;
	changeInput();
	
	#Connect button focus signals
	var nodes = get_tree().get_nodes_in_group("Button");
	for node in nodes:
		node.connect("focus_entered", self, "focus_change");
		
	$ActionButtons/MakeButton/AnimationPlayer.play("RESET");
	$ActionButtons/PlayButton/AnimationPlayer.play("RESET");

func _process(_delta):
	match (CurrentMenu):
		"StartMenu":
			$AudioSelectButton.pitch_scale = 1.1;
		"StartMenuAction":
			$AudioSelectButton.pitch_scale = 0.9;
			$YTButton.set_focus_neighbour(MARGIN_BOTTOM, "../ActionButtons/MakeButton");
			$YTButton.set_focus_neighbour(MARGIN_RIGHT, "../ActionButtons/MakeButton");
		"StartMenuPlay":
			$AudioSelectButton.pitch_scale = 1
			$YTButton.set_focus_neighbour(MARGIN_BOTTOM, "../PlayButtons/Coursebot");
			$YTButton.set_focus_neighbour(MARGIN_RIGHT, "../PlayButtons/Coursebot");
	
	if (CurrentMenu == "StartMenu"):
		if (Input.is_action_pressed("l") && Input.is_action_just_pressed("r")):
			$StartButton.hide();
			$ActionButtons.show();
			$ActionButtons/AnimationPlayer.play("in");
			CurrentMenu = "StartMenuAction";
			$AudioBigButton.play();
			changeFocus();

func getSplashText():
	var i = str(round(rand_range(0, 6)));
	var text = "";
	match (i):
		"0":
			text = "Prueba también SMBWF!";
		"1":
			text = "Hecho en Wonder Cave";
		"2":
			text = "Hecho con Godot :)";
		"3":
			text = "¡Haz niveles divertidos!"
		"4":
			text = "La primera versión de WM salió el 29/9/2024"
		"5":
			text = "Wonder Maker lleva 7 meses de desarrollo."
		"6":
			text = "El juego es de código cerrado!"
	return text;

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
	$FPS.grab_focus();
	if (mouseFocus != ""):
		get_node(mouseFocus+"/Selection/AnimationPlayer").play("RESET");
		get_node(mouseFocus).rect_pivot_offset.x = get_node(mouseFocus).rect_size.x/2;
		get_node(mouseFocus).rect_pivot_offset.y = get_node(mouseFocus).rect_size.y/2;
		var tween = get_tree().create_tween();
		var scale: Vector2 = str2var(get_node(mouseFocus).editor_description);
		tween.tween_property(get_node(mouseFocus), "rect_scale", scale, 0.0625);
	changeFocus();
	#Input.set_custom_mouse_cursor(load("res://sprites/ui/cursor_editor.png"));

#Start Menu
func _on_StartButton_pressed():
	$StartButton.hide();
	$ActionButtons.show();
	$ActionButtons/AnimationPlayer.play("in");
	CurrentMenu = "StartMenuAction";
	$AudioBigButton.play();
	changeFocus();
func _on_StartButton_mouse_entered():
	mouseFocus = "StartButton"; button_mouse_entered(); changeFocus();
func _on_StartButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

#Start Menu Action
func _on_MakeButton_pressed():
	getFocusNode().get_node("AnimationPlayer").play("start");
	$AudioBigButton.play();
	yield(get_tree().create_timer(1.0), "timeout");
	$AnimationPlayer.play("out");
	#Global.changeScene("res://scenes/Level.tscn");
	yield(get_tree().create_timer(1.0), "timeout");
	get_node("../Level").startmenu = false;
	get_node("../Level").editing = true;
	Global.coursePlaying = false;
	Global.toLoad = false;
	get_node("../Level/Editor")._on_Edit_pressed();
	get_node("../Level/Editor/UIBlocker").hide();
	if (Global.DISCORD_PRESENCE):
		Global.setDiscordState("editor")
	yield(get_tree().create_timer(0.125), "timeout");
	get_node("../Level/Editor").show();
	get_node("../Level/Editor/SideMenu").show();
	queue_free();
func _on_MakeButton_mouse_entered():
	mouseFocus = "ActionButtons/MakeButton"; button_mouse_entered(); changeFocus();
func _on_MakeButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_BackButton_pressed():
	$StartButton.show();
	$ActionButtons.hide();
	$ActionButtons/AnimationPlayer.play_backwards("in");
	$StartButton/AnimationPlayer.play("in");
	CurrentMenu = "StartMenu";
	$AudioButton.play();
	changeFocus();
func _on_BackButton_mouse_entered():
	mouseFocus = "ActionButtons/BackButton"; button_mouse_entered(); changeFocus();
func _on_BackButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_PlayButton_pressed():
	getFocusNode().get_node("AnimationPlayer").play("start");
	$AudioBigButton.play();
	yield(get_tree().create_timer(0.5), "timeout");
	$ActionButtons.hide();
	$PlayButtons.show();
	$StartButton/AnimationPlayer.play_backwards("in");
	$PlayButtons/AnimationPlayer.play("in");
	CurrentMenu = "StartMenuPlay";
	changeFocus();
func _on_PlayButton_mouse_entered():
	mouseFocus = "ActionButtons/PlayButton"; button_mouse_entered(); changeFocus();
func _on_PlayButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

#Start Menu Play
func _on_StoryMode_pressed():
	savedFocus = getFocusNode();
	Global.showMessage("¡Aún estamos trabajando en esto!", self, self);
	$AudioPlayButton.play();
func _on_StoryMode_mouse_entered():
	mouseFocus = "PlayButtons/StoryMode"; button_mouse_entered(); changeFocus();
func _on_StoryMode_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_CourseWorld_pressed():
	savedFocus = getFocusNode();
	Global.showMessage("¡Aún estamos trabajando en esto!", self, self);
	$AudioPlayButton.play();
func _on_CourseWorld_mouse_entered():
	mouseFocus = "PlayButtons/CourseWorld"; button_mouse_entered(); changeFocus();
func _on_CourseWorld_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();
	
func _on_Coursebot_pressed():
	$AudioPlayButton.play();
	Global.changeScene("res://scenes/Level.tscn");
	Global.changeScene("res://scenes/ui/coursebot.tscn");
func _on_Coursebot_mouse_entered():
	mouseFocus = "PlayButtons/Coursebot"; button_mouse_entered(); changeFocus();
func _on_Coursebot_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_ManzftChallenge_pressed():
	savedFocus = getFocusNode();
	Global.showMessage("Lo sentimos, el Manzft Challenge fue aplazado y no esta disponible todavia. Vendra en la Alpha v1.4.", self, self);
	$AudioPlayButton.play();
func _on_ManzftChallenge_mouse_entered():
	mouseFocus = "PlayButtons/ManzftChallenge"; button_mouse_entered(); changeFocus();
func _on_ManzftChallenge_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_BackButton2_pressed():
	$PlayButtons.hide();
	$ActionButtons.show();
	$PlayButtons/AnimationPlayer.play_backwards("in");
	$ActionButtons/AnimationPlayer.play("in");
	CurrentMenu = "StartMenuAction";
	$AudioButton.play();
	changeFocus();
func _on_BackButton2_mouse_entered():
	mouseFocus = "PlayButtons/BackButton"; button_mouse_entered(); changeFocus();
func _on_BackButton2_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

#Social Networks
func _on_DiscordButton_pressed():
	savedFocus = getFocusNode();
	Global.showMessage("Wonder Cave\nServidor de Discord Oficial del Fangame\n(Copiado al portapapeles)", self);
	OS.set_clipboard("https://discord.gg/csGS3eKxvD");
	$AudioPlayButton.play();
func _on_DiscordButton_mouse_entered():
	mouseFocus = "DiscordButton"; button_mouse_entered(); changeFocus();
func _on_DiscordButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_YTButton_pressed():
	savedFocus = getFocusNode();
	Global.showMessage("@Manzft27\nCanal de YouTube del creador del Fangame\n(Copiado al portapapeles)", self);
	OS.set_clipboard("https://youtube.com/@manzft27");
	$AudioPlayButton.play();
func _on_YTButton_mouse_entered():
	mouseFocus = "YTButton"; button_mouse_entered(); changeFocus();
func _on_YTButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();
