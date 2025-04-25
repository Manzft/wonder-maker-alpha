extends CanvasLayer

var branchmenu = false;

var mouseFocus = "";

var editingText = false;

var savedFocus = null;

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
	#Connect button focus signals
	var nodes = get_tree().get_nodes_in_group("Button");
	for node in nodes:
		node.connect("focus_entered", self, "focus_change");
	
	if (Global.WELCOME_SCREEN && Global.USER_NAME != ""):
		Global.changeScene("res://scenes/ui/intro.tscn", self);
	else:
		get_tree().create_timer(2.0);
		if (Global.USER_NAME == ""):
			Global.showMessage("Bienvenido a Wonder Maker Alpha "+Global.GAME_VERSION+". Antes de continuar, ingresa el nombre de usuario que vas a usar para el juego.", self, null, "WelcomeMsg0");
		else:
			Global.showMessage("Bienvenido a Wonder Maker Alpha "+Global.GAME_VERSION+".", self, null, "WelcomeMsg");

func messageBoxFinished(type : String):
	if (type == "WelcomeMsg0"):
		Global.enterText("Escribe tu nombre de usuario:", "Username", self);
	if (type == "WelcomeMsg"):
		Global.showMessage("Esta versión trae bastantes cambios en comparación con la anterior, así que diviertete probando todo lo nuevo.", self, null, "WelcomeMsg2");
	if (type == "WelcomeMsg2"):
		Global.showMessage("Cualquier pregunta que tengas puedes preguntar en el servidor de Discord del juego. Si necesitas el link de invitación puedes buscarlo en YouTube.", self, null, "WelcomeMsg3");
#	if (type == "WelcomeMsg3"):
#		Global.showMessage("Ahora, vamos a verificar algo.", self, null, "WelcomeMsg4");
#	if (type == "WelcomeMsg4"):
#		$Bg2.show();
#		$Bg2/AnimationPlayer.play("in");
	#if (type == "ShadowsFalse" || type == "ShadowsTrue"):
	if (type == "WelcomeMsg3"):
		Global.showMessage("Disfruta del juego, crea niveles y juega los de la comunidad.", self, null, "WelcomeMsg5");
	if (type == "WelcomeMsg5"):
		Global.WELCOME_SCREEN = true;
		Global.saveSettings();
		Global.changeScene("res://scenes/ui/intro.tscn", self);

func enterTextFinished(text : String, type : String):
	if (type == "Username"):
		Global.USER_NAME = text;
		Global.saveSettings();
		Global.showMessage("Perfecto, ya se ha guardado tu nombre de usuario. Ahora podemos continuar.", self, null, "WelcomeMsg");

#General
func button_mouse_entered():
	$AudioSelectButton.play();
	get_node(mouseFocus+"/Selection/AnimationPlayer").play("idle");
	changeFocus();

func button_mouse_exited():
	$Bg.grab_focus();
	get_node(mouseFocus+"/Selection/AnimationPlayer").play("RESET");
	changeFocus();
