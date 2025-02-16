extends TextureButton

var type = "";

func setup():
	var app = "smb";
	match (Global.CurrentAppeareance):
		Global.APP_SMB:
			app = "smb";
		Global.APP_SMB3:
			app = "smb3";
	
	match (type):
		"mushroom":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/items/mushroom.png");
		"quitmushroom":
			$Outline.modulate = $X.self_modulate;
			$Arrow.hide();
			$X.show();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/items/mushroom.png");
		"piranhaplantfire":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/enemies/piranhaplant_fire.png");
		"piranhaplant":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/enemies/piranhaplant.png");
		"goombrat":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/enemies/goombrat.png");
		"goomba":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/enemies/goomba.png");
		"spinydead":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/enemies/spinydead.png");
		"spinyalive":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/enemies/spiny.png");
		"koopatroopared":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/enemies/koopatroopa_red.png");
		"koopatroopa":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/enemies/koopatroopa.png");
			
		#Character Editor
		"charmushroom":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/items/mushroom.png");
		"charfireflower":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/items/fireflower.png");
		"charstar":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/items/star.png");
			
		"charquitmushroom":
			$Outline.modulate = $X.self_modulate;
			$Arrow.hide();
			$X.show();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/items/mushroom.png");
		"charquitfireflower":
			$Outline.modulate = $X.self_modulate;
			$Arrow.hide();
			$X.show();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/items/fireflower.png");
		"charquitstar":
			$Outline.modulate = $X.self_modulate;
			$Arrow.hide();
			$X.show();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/items/star.png");
			
	if (Global.CurrentInput == "Gamepad"):
		grab_focus();
		get_node("../../..").updateFocusSprite();

func _on_TypeButton_pressed():
	get_node("../../../AudioOpenTypeMenu").play();
	
	#get_node("../../..").savedFocus = get_node("../../..").getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!.", get_node("../../.."));
	match (type):
		"mushroom":
			get_node("../../..").currentTypeMenuObject.setMushroom(true);
		"quitmushroom":
			get_node("../../..").currentTypeMenuObject.setMushroom(false);
		"piranhaplantfire":
			var pos = get_node("../../../..").grab_node.position;
			get_node("../../../..").eraseObject(pos, false);
			get_node("../../../..").placeObject(pos, false, Global.OBJ_PIRANHAPLANT_FIRE);
		"piranhaplant":
			var pos = get_node("../../../..").grab_node.position;
			get_node("../../../..").eraseObject(pos, false);
			get_node("../../../..").placeObject(pos, false, Global.OBJ_PIRANHAPLANT);
		"goombrat":
			var pos = get_node("../../../..").grab_node.position;
			get_node("../../../..").eraseObject(pos, false);
			get_node("../../../..").placeObject(pos, false, Global.OBJ_GOOMBRAT);
		"goomba":
			var pos = get_node("../../../..").grab_node.position;
			get_node("../../../..").eraseObject(pos, false);
			get_node("../../../..").placeObject(pos, false, Global.OBJ_GOOMBA);
		"spinydead":
			get_node("../../../..").grab_node.alreadydead = true;
		"spinyalive":
			get_node("../../../..").grab_node.alreadydead = false;
		"koopatroopared":
			var pos = get_node("../../../..").grab_node.position;
			get_node("../../../..").eraseObject(pos, false);
			get_node("../../../..").placeObject(pos, false, Global.OBJ_KOOPATROOPA_RED);
		"koopatroopa":
			var pos = get_node("../../../..").grab_node.position;
			get_node("../../../..").eraseObject(pos, false);
			get_node("../../../..").placeObject(pos, false, Global.OBJ_KOOPATROOPA);
			
		#Character
		"charmushroom":
			get_node("../../../../CharacterEditor").currentDefaultPowerup = "mush";
			var cDP = get_node("../../../../CharacterEditor").currentDefaultPowerup;
			get_node("../../../../CharacterEditor").currentSprite.play(cDP+"_idle");
			get_node("../../../../CharacterEditor").currentSprite.get_node("Shadow").play(get_node("../../../../CharacterEditor").currentSprite.animation);
			get_node("../../../../CharacterEditor/PowerupGot").play();
		"charquitmushroom":
			get_node("../../../../CharacterEditor").currentDefaultPowerup = "small";
			var cDP = get_node("../../../../CharacterEditor").currentDefaultPowerup;
			get_node("../../../../CharacterEditor").currentSprite.play(cDP+"_idle");
			get_node("../../../../CharacterEditor").currentSprite.get_node("Shadow").play(get_node("../../../../CharacterEditor").currentSprite.animation);
			get_node("../../../../CharacterEditor/PowerupOut").play();
		"charfireflower":
			get_node("../../../../CharacterEditor").currentDefaultPowerup = "fireflower";
			var cDP = get_node("../../../../CharacterEditor").currentDefaultPowerup;
			get_node("../../../../CharacterEditor").currentSprite.play(cDP+"_idle");
			get_node("../../../../CharacterEditor").currentSprite.get_node("Shadow").play(get_node("../../../../CharacterEditor").currentSprite.animation);
			get_node("../../../../CharacterEditor/PowerupGot").play();
		"charquitfireflower":
			get_node("../../../../CharacterEditor").currentDefaultPowerup = "mush";
			var cDP = get_node("../../../../CharacterEditor").currentDefaultPowerup;
			get_node("../../../../CharacterEditor").currentSprite.play(cDP+"_idle");
			get_node("../../../../CharacterEditor").currentSprite.get_node("Shadow").play(get_node("../../../../CharacterEditor").currentSprite.animation);
			get_node("../../../../CharacterEditor/PowerupOut").play();
		"charstar":
			get_node("../../../../CharacterEditor").star = true;
			get_node("../../../../CharacterEditor/PowerupGot").play();
		"charquitstar":
			get_node("../../../../CharacterEditor").star = false;
			get_node("../../../../CharacterEditor/PowerupOut").play();
	
	get_node("../../..").closeMenus();

func _on_TypeButton_mouse_entered():
	get_node("../../..").mouseFocus = "TypeMenu/Buttons/"+get_name(); get_node("../../..").button_mouse_entered(); get_node("../../..").changeFocus();

func _on_TypeButton_mouse_exited():
	get_node("../../..").button_mouse_exited(); get_node("../../..").mouseFocus = ""; get_node("../../..").changeFocus();
