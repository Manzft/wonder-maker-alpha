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
		#TERRAIN
		"pipe_transport":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/ui/type menu/pipe_entrance.png");
		
		#ENEMIES
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
		"drybonesdead":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/enemies/drybonesdead.png");
		"drybonesalive":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/enemies/drybones.png");
		
		#ITEMS
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
		"10COIN":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/items/10coin.png");
		"30COIN":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/items/30coin.png");
		"50COIN":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/items/50coin.png");
		
		#GIZMOS
		"ONOFFSWITCH":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/gizmos/onoffswitch.png");
		"ONBLOCK":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/gizmos/onblock.png");
		"OFFBLOCK":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/gizmos/offblock.png");
		
		"ONOFFSWITCH2":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/gizmos/onoffswitch2.png");
		"ONBLOCK2":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/gizmos/onblock2.png");
		"OFFBLOCK2":
			$Outline.modulate = $Arrow.self_modulate;
			$Arrow.show();
			$X.hide();
			$Icon.texture = load("res://sprites/appeareances/"+app+"/icons/gizmos/offblock2.png");
			
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
		#TERRAIN
		"pipe_transport":
			var level = get_node("../../../..")
			var node = level.grab_node
			var pos = node.position;
			var grid = level.calculateGrid(pos.x, pos.y)
			if (level.grid[grid.x+node.grid_end.x+1][grid.y] == null &&
			level.grid[grid.x+node.grid_end.x+2][grid.y] == null &&
			level.grid[grid.x+node.grid_end.x+1][grid.y+1] == null &&
			level.grid[grid.x+node.grid_end.x+2][grid.y+1] == null):
				var pipe_code = 0
				var max_pipe_code = -1
				for pipe_node in get_tree().get_nodes_in_group("Pipe"):
					if (pipe_node != node):
						if (pipe_node.pipe_code > max_pipe_code):
							max_pipe_code = pipe_node.pipe_code
							
				pipe_code = max_pipe_code+1
				
				var instance_grid = Vector2(grid.x+node.grid_end.x+1, grid.y)
				var instance_pos = level.calculateGridPosition(instance_grid)
				var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_PIPE][Global.OP_SCENE].instance()
				inst.pipe_code = pipe_code
				node.pipe_code = pipe_code
				get_node("../../../..").placeObject(instance_pos, false, Global.OBJ_PIPE, false, true, inst);
				print("Node pipe code: ", node.pipe_code)
				print("Inst pipe code: ", inst.pipe_code)
		
		#ITEMS
		"piranhaplantfire":
			var pos = get_node("../../../..").grab_node.position;
			get_node("../../../..").eraseObject(pos, false);
			get_node("../../../..").placeObject(pos, false, Global.OBJ_PIRANHAPLANT_FIRE);
			get_node("../../../..").objSelected = Global.OBJ_PIRANHAPLANT_FIRE;
			get_node("../../..").selObj();
		"piranhaplant":
			var pos = get_node("../../../..").grab_node.position;
			get_node("../../../..").eraseObject(pos, false);
			get_node("../../../..").placeObject(pos, false, Global.OBJ_PIRANHAPLANT);
		"goombrat":
			var pos = get_node("../../../..").grab_node.position;
			get_node("../../../..").eraseObject(pos, false);
			get_node("../../../..").placeObject(pos, false, Global.OBJ_GOOMBRAT);
			get_node("../../../..").objSelected = Global.OBJ_GOOMBRAT;
			get_node("../../..").selObj();
		"goomba":
			var pos = get_node("../../../..").grab_node.position;
			get_node("../../../..").eraseObject(pos, false);
			get_node("../../../..").placeObject(pos, false, Global.OBJ_GOOMBA);
			get_node("../../../..").objSelected = Global.OBJ_GOOMBA;
			get_node("../../..").selObj();
		"spinydead":
			get_node("../../../..").grab_node.alreadydead = true;
		"spinyalive":
			get_node("../../../..").grab_node.alreadydead = false;
		"koopatroopared":
			var pos = get_node("../../../..").grab_node.position;
			get_node("../../../..").eraseObject(pos, false);
			get_node("../../../..").placeObject(pos, false, Global.OBJ_KOOPATROOPA_RED);
			get_node("../../../..").objSelected = Global.OBJ_KOOPATROOPA_RED;
			get_node("../../..").selObj();
		"koopatroopa":
			var pos = get_node("../../../..").grab_node.position;
			get_node("../../../..").eraseObject(pos, false);
			get_node("../../../..").placeObject(pos, false, Global.OBJ_KOOPATROOPA);
			get_node("../../../..").objSelected = Global.OBJ_KOOPATROOPA;
			get_node("../../..").selObj();
		"drybonesdead":
			get_node("../../../..").grab_node.alreadydead = true;
		"drybonesalive":
			get_node("../../../..").grab_node.alreadydead = false;
		#ITEMS
		"mushroom":
			get_node("../../..").currentTypeMenuObject.setMushroom(true);
		"quitmushroom":
			get_node("../../..").currentTypeMenuObject.setMushroom(false);
		"10COIN":
			var pos = get_node("../../../..").grab_node.position;
			get_node("../../../..").eraseObject(pos, false);
			get_node("../../../..").placeObject(pos, false, Global.OBJ_10COIN);
			get_node("../../../..").objSelected = Global.OBJ_10COIN;
			get_node("../../..").selObj();
		"30COIN":
			var pos = get_node("../../../..").grab_node.position;
			get_node("../../../..").eraseObject(pos, false);
			get_node("../../../..").placeObject(pos, false, Global.OBJ_30COIN);
			get_node("../../../..").objSelected = Global.OBJ_30COIN;
			get_node("../../..").selObj();
		"50COIN":
			var pos = get_node("../../../..").grab_node.position;
			get_node("../../../..").eraseObject(pos, false);
			get_node("../../../..").placeObject(pos, false, Global.OBJ_50COIN);
			get_node("../../../..").objSelected = Global.OBJ_50COIN;
			get_node("../../..").selObj();
		#GIZMOS
		"ONOFFSWITCH":
			var pos = get_node("../../../..").grab_node.position;
			get_node("../../../..").eraseObject(pos, false);
			get_node("../../../..").placeObject(pos, false, Global.OBJ_ONOFFSWITCH);
			get_node("../../../..").objSelected = Global.OBJ_ONOFFSWITCH;
			get_node("../../..").selObj();
		"ONBLOCK":
			var pos = get_node("../../../..").grab_node.position;
			get_node("../../../..").eraseObject(pos, false);
			get_node("../../../..").placeObject(pos, false, Global.OBJ_ONBLOCK);
			get_node("../../../..").objSelected = Global.OBJ_ONBLOCK;
			get_node("../../..").selObj();
		"OFFBLOCK":
			var pos = get_node("../../../..").grab_node.position;
			get_node("../../../..").eraseObject(pos, false);
			get_node("../../../..").placeObject(pos, false, Global.OBJ_OFFBLOCK);
			get_node("../../../..").objSelected = Global.OBJ_OFFBLOCK;
			get_node("../../..").selObj();
		"ONOFFSWITCH2":
			var pos = get_node("../../../..").grab_node.position;
			get_node("../../../..").eraseObject(pos, false);
			get_node("../../../..").placeObject(pos, false, Global.OBJ_ONOFFSWITCH2);
			get_node("../../../..").objSelected = Global.OBJ_ONOFFSWITCH2;
			get_node("../../..").selObj();
		"ONBLOCK2":
			var pos = get_node("../../../..").grab_node.position;
			get_node("../../../..").eraseObject(pos, false);
			get_node("../../../..").placeObject(pos, false, Global.OBJ_ONBLOCK2);
			get_node("../../../..").objSelected = Global.OBJ_ONBLOCK2;
			get_node("../../..").selObj();
		"OFFBLOCK2":
			var pos = get_node("../../../..").grab_node.position;
			get_node("../../../..").eraseObject(pos, false);
			get_node("../../../..").placeObject(pos, false, Global.OBJ_OFFBLOCK2);
			get_node("../../../..").objSelected = Global.OBJ_OFFBLOCK2;
			get_node("../../..").selObj();
		
		#Character
		"charmushroom":
			get_node("../../../../CharacterEditor").currentDefaultPowerup = "mush";
			var cDP = get_node("../../../../CharacterEditor").currentDefaultPowerup;
			get_node("../../../../CharacterEditor").currentSprite.play(cDP+"_idle");
			get_node("../../../../CharacterEditor/PowerupGot").play();
		"charquitmushroom":
			get_node("../../../../CharacterEditor").currentDefaultPowerup = "small";
			var cDP = get_node("../../../../CharacterEditor").currentDefaultPowerup;
			get_node("../../../../CharacterEditor").currentSprite.play(cDP+"_idle");
			get_node("../../../../CharacterEditor/PowerupOut").play();
		"charfireflower":
			get_node("../../../../CharacterEditor").currentDefaultPowerup = "fireflower";
			var cDP = get_node("../../../../CharacterEditor").currentDefaultPowerup;
			get_node("../../../../CharacterEditor").currentSprite.play(cDP+"_idle");
			get_node("../../../../CharacterEditor/PowerupGot").play();
		"charquitfireflower":
			get_node("../../../../CharacterEditor").currentDefaultPowerup = "mush";
			var cDP = get_node("../../../../CharacterEditor").currentDefaultPowerup;
			get_node("../../../../CharacterEditor").currentSprite.play(cDP+"_idle");
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
