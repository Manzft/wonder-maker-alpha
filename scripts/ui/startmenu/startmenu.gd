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
	
	yield(get_tree().create_timer(1.0), "timeout");
	RichPresence.update_activity("MainMenu");
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
	var i = str(round(rand_range(0, 7)));
	var text = "";
	match (i):
		"0":
			text = "Feliz año nuevo 2025!";
		"1":
			text = "Prueba también SMBWF!";
		"2":
			text = "Hecho en Wonder Cave";
		"3":
			text = "Hecho con Godot :)";
		"4":
			text = "No me recupero de la papeada de leonel...";
		"5":
			text = "SMW en la Alpha 1.4?";
	return text;

#General
func button_mouse_entered():
	$AudioSelectButton.play();
	get_node(mouseFocus+"/Selection/AnimationPlayer").play("idle");
	changeFocus();

func button_mouse_exited():
	$FPS.grab_focus();
	if (mouseFocus != ""):
		get_node(mouseFocus+"/Selection/AnimationPlayer").play("RESET");
	changeFocus();

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
	yield(get_tree().create_timer(0.5), "timeout");
	Global.changeScene("res://scenes/Level.tscn");
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
	Global.showMessage("¡Aún estamos trabajando en esto!", self);
	$AudioPlayButton.play();
func _on_StoryMode_mouse_entered():
	mouseFocus = "PlayButtons/StoryMode"; button_mouse_entered(); changeFocus();
func _on_StoryMode_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_CourseWorld_pressed():
	savedFocus = getFocusNode();
	Global.showMessage("¡Aún estamos trabajando en esto!", self);
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
