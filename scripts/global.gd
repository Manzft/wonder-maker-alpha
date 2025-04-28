extends Node

var thread : Thread;
var render_thread : Thread;
var can_render = true;
var first_render = true;

var transition = preload("res://scenes/ui/transition.tscn");
var transition_out = preload("res://scenes/ui/transition_out.tscn");

signal gameLoaded
signal render
signal floorErase
signal changeStyle
signal erase

#APPEAREANCES
const APP_SMB = 0;
const APP_SMB3 = 1;

const GAME_VERSION = "1.3";

#Editor Objects
var OP_SCENE = 0;
var OP_NAME = 1;
var OP_ICON = 2;
var object = [];

var Objects = 40;
var Appeareances = 2;
var Styles = 1;

var OBJ_FLOOR = 0;
var OBJ_BLOCK = 1;
var OBJ_BRICK = 2;
var OBJ_COIN = 3;
var OBJ_LUCKYBLOCK = 4;
var OBJ_INVISIBLE_LUCKYBLOCK = 5;
var OBJ_CLOUD = 6;
var OBJ_DONUT = 7;
var OBJ_SPIKE = 8;
var OBJ_10COIN = 9;
var OBJ_30COIN = 10;
var OBJ_50COIN = 11;
var OBJ_1UP = 12;
var OBJ_STAR = 13;
var OBJ_MUSHROOM = 14;
var OBJ_FIREFLOWER = 15;
var OBJ_GOOMBA = 16;
var OBJ_KOOPATROOPA = 17;
var OBJ_SPINY = 18;
var OBJ_PIRANHAPLANT = 19;
var OBJ_MUNCHER = 20;
var OBJ_TWOMP = 21;
var OBJ_BURNER = 22;
var OBJ_P = 23;
var OBJ_PBLOCK = 24;
var OBJ_ONOFFSWITCH = 25;
var OBJ_ONBLOCK = 26;
var OBJ_OFFBLOCK = 27;
var OBJ_KOOPATROOPA_RED = 28;
var OBJ_PIRANHAPLANT_FIRE = 29;
var OBJ_GOOMBRAT = 30;
var OBJ_DRYBONES = 31;
var OBJ_CHECKPOINT = 32;
var OBJ_ARROW = 33;
var OBJ_ONOFFSWITCH2 = 34;
var OBJ_ONBLOCK2 = 35;
var OBJ_OFFBLOCK2 = 36;
var OBJ_PIPE = 37;
var OBJ_SEMISOLID = 38;
var OBJ_PIPE_CONNECTOR = 39;

var objects_count = []

var CurrentAppeareance = APP_SMB;
var CurrentStyle = "Ground";
var CurrentSpeed = "None";
var CurrentDefaultPowerup = "small";
var CurrentStar = "false";
var CurrentTime = 300;
var CurrentMusic = "true";

var FPS = false;

var SHOW_FPS = false;
var VSYNC = true;
var SCREEN_16_9 = false;
var SHOW_PAUSE_BUTTON = true;
var CONTROLS_TRANSPARENCY = 100.0;
var min_controls_transparency = 0.0;
var max_controls_transparency = 100.0;
var ENTITY_PHYSICS_SPEED = 100.0;
var min_entity_physics_speed = 25.0;
var max_entity_physics_speed = 100.0;
var PHYSICS_INTERPOLATION = false;
var SHADOWS = true;
var USER_NAME = "";
var SPLASH_SCREEN_FINISHED = false;
var WELCOME_SCREEN = false;
var AUTO_SAVING = false;
var SNOW_FALLING_PARTICLES = true;

var CurrentInput = "Mouse";

#Save and Load
var levelfloor_grid = Vector2(0, 0);
var endfloor_grid = Vector2(0, 0);
var char_grid = Vector2(0, 0);

var currentlevel = "";
var currentCourseName = "";
var currentCourseDescription = "";
var currentCourseUser = "";

var CheckpointGrid = Vector2(0, 0);

var toLoad = false;
var loadingCourse = false;

var gnode = [];

var coursePlaying = false;
var changingToEditMode = false;
var changingToEditTimer = 0.0;

var ready = false;

var playing = false;
var charpos = Vector2(0, 0);
var campos = Vector2(0, 0);

var alternRender = true;

var level_data = {}
var object_data = []

var SECURITY_KEY = "27102021"

var DISCORD_PRESENCE = true;

var CURRENT_THUMBNAIL = null;

var activity
var assets
var timestamps

func getObjectCode(node: Node):
	var obj : int = -1;
	for group in node.get_groups():
		if (group[0] in "0123456789"):
			if !(group[group.length()-1] in "aAbBcCdDeEfFgGhHjJkKlLmMnNñÑoOpPqQrRsStTuUvVwWxXyYzZ"):
				obj = int(group);
				break
	return obj

func to_dict(node: Node):
	var obj : int = getObjectCode(node);
	
	var data : Dictionary = {
		"object": str(obj),
		"position": var2str(node.position)
	}
	
	if (obj == OBJ_FLOOR):
		data["decorationType"] = node.decorationType;
		if (CurrentAppeareance != APP_SMB):
			data["defaultFrameCoords"] = var2str(node.getFrameCoords());
			data["defaultFalseUp"] = var2str(node.getFalse("Up"));
			data["defaultFalseUp2"] = var2str(node.getFalse("Up2"));
			data["defaultFalseCenter"] = var2str(node.getFalse("Center"));
			data["defaultFalseCenter2"] = var2str(node.getFalse("Center2"));
	
	if (node.is_in_group("Insideable")):
		data["objectInside"] = node.objectInside;
		data["objectAttribute"] = node.objectAttribute;
	
	if (obj == OBJ_BURNER || obj == OBJ_TWOMP || obj == OBJ_CHECKPOINT
	|| obj == OBJ_ARROW || obj == OBJ_PIPE):
		data["seldirection"] = node.seldirection;
	
	if (obj == OBJ_DRYBONES || obj == OBJ_SPINY):
		data["alreadydead"] = var2str(node.alreadydead);
	
	if (obj == OBJ_PIPE || obj == OBJ_SEMISOLID || obj == OBJ_PIPE_CONNECTOR):
		data["grid_origin"] = var2str(node.grid_origin);
		data["grid_end"] = var2str(node.grid_end);
		if (obj == OBJ_PIPE):
			data["pipe_code"] = str(node.pipe_code)
		if (obj == OBJ_SEMISOLID):
			data["visual_grid_end"] = var2str(node.visual_grid_end)
	
	return data

func courseGetAppeareance(filedir):
	var f = File.new()
	f.open_encrypted_with_pass(filedir, File.READ, SECURITY_KEY);
	var content = f.get_as_text();
	f.close();
	var json = JSON.parse(content)
	var data = json.result;
	return int(data.appeareance)

func courseGetStyle(filedir):
	var f = File.new()
	f.open_encrypted_with_pass(filedir, File.READ, SECURITY_KEY);
	var content = f.get_as_text();
	f.close();
	var json = JSON.parse(content)
	var data = json.result;
	return data.style;

func courseGetDescription(filedir):
	var f = File.new()
	f.open_encrypted_with_pass(filedir, File.READ, SECURITY_KEY);
	var content = f.get_as_text();
	var json = JSON.parse(content)
	var data = json.result;
	f.close();
	return data.description;

func courseGetUser(filedir):
	var f = File.new()
	f.open_encrypted_with_pass(filedir, File.READ, SECURITY_KEY);
	var content = f.get_as_text();
	var json = JSON.parse(content)
	var data = json.result;
	f.close();
	return data.user;

func courseGetVersion(filedir):
	var f = File.new()
	f.open_encrypted_with_pass(filedir, File.READ, SECURITY_KEY);
	var content = f.get_as_text();
	var json = JSON.parse(content)
	var data = json.result;
	f.close();
	return data.version;

func courseGetThumbnail(filedir):
	var f = File.new()
	f.open_encrypted_with_pass(filedir, File.READ, SECURITY_KEY);
	var content = f.get_as_text();
	var json = JSON.parse(content)
	var data = json.result;
	f.close();
	var returndata = null;
	if ("thumbnail" in data):
		var bytes_png = str2var(data.thumbnail)
		var img = Image.new();
		img.load_png_from_buffer(bytes_png);
		var texture = ImageTexture.new();
		texture.create_from_image(img);
		returndata = texture;
	return returndata;

func get_game_dir():
	var todir = "";
	if (OS.get_name() == "Android"):
		todir = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)+"/Wonder Maker";
	else:
		todir = OS.get_user_data_dir();
	
	var dir = Directory.new();
	if (!dir.dir_exists(todir)):
		dir.make_dir(todir);
	if (!dir.dir_exists(todir+"/Courses")):
		dir.make_dir(todir+"/Courses");
	
	return todir;

func saveCourseData(ingame : bool = true, autosave : bool = false):
	if (ingame && !autosave):
		var editor : Node;
		for node in get_tree().get_nodes_in_group("CurrentTree"):
			if (node.name == "Editor"):
				editor = node;
		editor.hide();
		editor.get_parent().get_node("TileMap").hide();
		editor.get_parent().get_node("LevelFloor").hide();
		editor.get_parent().get_node("EndFloor").hide();
		editor.get_parent().get_node("CharacterEditor").hide();
		$FPS.hide();
		var cmpos : Vector2 = editor.get_parent().get_node("Camera2D").position;
		editor.get_parent().get_node("Camera2D").position = Vector2(0, 840);
		yield(get_tree(), "idle_frame");
		yield(get_tree(), "idle_frame");
		var img = get_viewport().get_texture().get_data();
		img.flip_y();
		img.crop(img.get_height()*1.77, img.get_height());
		#img.resize(404, 228);
		CURRENT_THUMBNAIL = img.save_png_to_buffer()
		editor.show();
		editor.get_parent().get_node("TileMap").show();
		editor.get_parent().get_node("LevelFloor").show();
		editor.get_parent().get_node("EndFloor").show();
		editor.get_parent().get_node("CharacterEditor").show();
		editor.get_parent().get_node("Camera2D").position = cmpos;
		if (SHOW_FPS):
			$FPS.show();
	
	var f = File.new()
	f.open_encrypted_with_pass(currentlevel, File.WRITE, SECURITY_KEY);
	
	if (ingame):
		setLevelInfo();
		
	level_data = {
		"version": GAME_VERSION,
		"appeareance": str(CurrentAppeareance),
		"style": CurrentStyle,
		"description": currentCourseDescription,
		"user": currentCourseUser,
		"levelfloor_grid": var2str(levelfloor_grid),
		"endfloor_grid": var2str(endfloor_grid),
		"defaultPowerup": CurrentDefaultPowerup,
		"star": CurrentStar,
		"speed": CurrentSpeed,
		"time": str(CurrentTime),
		"music": CurrentMusic,
		
		"objects": object_data
	}
	
	if (CURRENT_THUMBNAIL != null):
		level_data["thumbnail"] = var2str(CURRENT_THUMBNAIL);
	
	f.store_string(JSON.print(level_data));
	
	f.close();

func loadCourseData(ingame = true):
	print("Course Data Loaded")
	var f = File.new()
	f.open_encrypted_with_pass(currentlevel, File.READ, SECURITY_KEY);
	
	var content = f.get_as_text();
	var json = JSON.parse(content)
	level_data = json.result;
	
	CurrentAppeareance = int(level_data.appeareance);
	CurrentStyle = level_data.style;
	currentCourseDescription = level_data.description;
	currentCourseUser = level_data.user;
	
	levelfloor_grid = str2var(level_data.levelfloor_grid);
	endfloor_grid = str2var(level_data.endfloor_grid);
	
	CurrentDefaultPowerup = level_data.defaultPowerup;
	CurrentStar = level_data.star;
	CurrentSpeed = level_data.speed;
	CurrentTime = int(level_data.time);
	CurrentMusic = level_data.music;
	
	if ("thumbnail" in level_data):
		CURRENT_THUMBNAIL = str2var(level_data.thumbnail);
	else:
		CURRENT_THUMBNAIL = null;
	
	object_data = level_data.objects;

	f.close()
	if (ingame):
		loadLevelInfo();
	return false;
	#else:
	#	return true;

func setLevelInfo():
	var level;
	var nodes = get_tree().get_nodes_in_group("Level");
	for node in nodes:
		level = node;
	
	saveObjects();
	nodes = get_tree().get_nodes_in_group("LevelfloorController");
	for node in nodes:
		levelfloor_grid = level.calculateGrid(node.position.x, node.position.y);
	nodes = get_tree().get_nodes_in_group("EndfloorController");
	for node in nodes:
		endfloor_grid = level.calculateGrid(node.position.x, node.position.y);

func loadLevelInfo():
	var level;
	var nodes = get_tree().get_nodes_in_group("Level");
	for node in nodes:
		level = node;
	
	var lvlfloor_y = 0;
	nodes = get_tree().get_nodes_in_group("LevelfloorController");
	for node in nodes:
		node.calculate(level.calculateGridPosition(levelfloor_grid), true);
		lvlfloor_y = node.position.y;
	nodes = get_tree().get_nodes_in_group("EndfloorController");
	for node in nodes:
		node.calculate(level.calculateGridPosition(endfloor_grid), true);
	nodes = get_tree().get_nodes_in_group("CharacterEditor");
	for node in nodes:
		node.position.x = level.calculateGridPosition(Vector2(4, 0)).x;
		node.position.y = lvlfloor_y-52;
		node.currentDefaultPowerup = CurrentDefaultPowerup;
		if (CurrentStar == "false"):
			node.star = false;
		else:
			node.star = true;
		node.updateSprite();
	
	yield(get_tree(), "idle_frame");
	level = null;
	nodes = get_tree().get_nodes_in_group("Level");
	for node in nodes:
		level = node;
	loadObjects(level);
#	thread = Thread.new();
#	thread.start(self, "loadObjects", level)

func saveObjects():
	var nodes = get_tree().get_nodes_in_group("Obj");
	
	object_data = []
	
	for node in nodes:
		if (!node.is_in_group("FalseFloor")):
			object_data.append(to_dict(node));

func loadObjects(level):
	if (level == null):
		return
	
	for obj in object_data:
		var inst = Global.object[Global.CurrentAppeareance][int(obj.object)][Global.OP_SCENE].instance();
		level.placeObject(str2var(obj.position), false, int(obj.object), false, false, inst);
		
		if (int(obj.object) == OBJ_FLOOR):
			inst.decorationType = obj.decorationType;
			if (CurrentAppeareance != APP_SMB):
				inst.defaultFrameCoords = str2var(obj.defaultFrameCoords);
				inst.defaultFalseUp = str2var(obj.defaultFalseUp);
				inst.defaultFalseUp2 = str2var(obj.defaultFalseUp2);
				inst.defaultFalseCenter = str2var(obj.defaultFalseCenter);
				inst.defaultFalseCenter2 = str2var(obj.defaultFalseCenter2);
		
		if (inst.is_in_group("Insideable")):
			inst.objectInside = obj.objectInside;
			inst.objectAttribute = obj.objectAttribute;
		
		if (int(obj.object) == OBJ_BURNER || int(obj.object) == OBJ_TWOMP || int(obj.object) == OBJ_CHECKPOINT
		|| int(obj.object) == OBJ_ARROW || int(obj.object) == OBJ_PIPE):
			if ("seldirection" in obj):
				inst.seldirection = obj.seldirection;
		
		if (int(obj.object) == OBJ_DRYBONES || int(obj.object) == OBJ_SPINY):
			inst.alreadydead = str2var(obj.alreadydead)
		
		if (int(obj.object) == OBJ_PIPE || int(obj.object) == OBJ_SEMISOLID || int(obj.object) == OBJ_PIPE_CONNECTOR):
			inst.grid_origin = str2var(obj.grid_origin);
			inst.grid_end = str2var(obj.grid_end);
			if (int(obj.object) == OBJ_PIPE):
				if ("pipe_code" in obj):
					inst.pipe_code = int(obj.pipe_code)
			if (int(obj.object) == OBJ_SEMISOLID):
				inst.visual_grid_end = str2var(obj.visual_grid_end)
	
	emit_signal("gameLoaded");

func loadSettings():
	var score_data = {}
	var config = ConfigFile.new()

	var err = config.load(get_game_dir()+"/config.ini")

	if err != OK:
		return

	for section in config.get_sections():
		if (section == "General"):
			VSYNC = config.get_value(section, "VSync", true);
			SCREEN_16_9 = config.get_value(section, "Force 16:9", false);
			SHOW_FPS = config.get_value(section, "Show FPS", false);
			SHOW_PAUSE_BUTTON = config.get_value(section, "Show Pause Button (Only PC)", true);
			CONTROLS_TRANSPARENCY = config.get_value(section, "Touch Buttons Transparency (%)", 100.0);
			if (CONTROLS_TRANSPARENCY < min_controls_transparency): CONTROLS_TRANSPARENCY = min_controls_transparency;
			if (CONTROLS_TRANSPARENCY > max_controls_transparency): CONTROLS_TRANSPARENCY = max_controls_transparency;
			ENTITY_PHYSICS_SPEED = config.get_value(section, "Entity Physics Speed (%)", 100.0);
			if (ENTITY_PHYSICS_SPEED < min_entity_physics_speed): ENTITY_PHYSICS_SPEED = min_entity_physics_speed;
			if (ENTITY_PHYSICS_SPEED > max_entity_physics_speed): ENTITY_PHYSICS_SPEED = max_entity_physics_speed;
			PHYSICS_INTERPOLATION = config.get_value(section, "Physics Interpolation", false);
			SHADOWS = config.get_value(section, "Shadows (Experimental)", true);
			SPLASH_SCREEN_FINISHED = config.get_value(section, "Splash Screen Finished", false);
			WELCOME_SCREEN = config.get_value(section, "Welcome Screen Finished", false);
			SNOW_FALLING_PARTICLES = config.get_value(section, "Snow Falling Particles", true);
			AUTO_SAVING = config.get_value(section, "Auto-Saving", false);
		if (section == "User"):
			USER_NAME = config.get_value(section, "Username", "");
	
	OS.vsync_enabled = VSYNC;
	if (SCREEN_16_9):
		get_tree().set_screen_stretch(get_tree().STRETCH_MODE_2D, get_tree().STRETCH_ASPECT_KEEP, Vector2(1280, 720));
	else:
		get_tree().set_screen_stretch(get_tree().STRETCH_MODE_2D, get_tree().STRETCH_ASPECT_KEEP_HEIGHT, Vector2(1280, 720));

func saveSettings():
	var config = ConfigFile.new()

	config.set_value("General", "VSync", VSYNC);
	config.set_value("General", "Force 16:9", SCREEN_16_9);
	config.set_value("General", "Show FPS", SHOW_FPS);
	config.set_value("General", "Show Pause Button (Only PC)", SHOW_PAUSE_BUTTON);
	config.set_value("General", "Touch Buttons Transparency (%)", CONTROLS_TRANSPARENCY);
	config.set_value("General", "Entity Physics Speed (%)", ENTITY_PHYSICS_SPEED);
	config.set_value("General", "Physics Interpolation", PHYSICS_INTERPOLATION);
	config.set_value("General", "Shadows (Experimental)", SHADOWS);
	config.set_value("General", "Splash Screen Finished", SPLASH_SCREEN_FINISHED);
	config.set_value("General", "Welcome Screen Finished", WELCOME_SCREEN);
	config.set_value("General", "Auto-Saving", AUTO_SAVING);
	config.set_value("General", "Snow Falling Particles", SNOW_FALLING_PARTICLES);
	
	config.set_value("User", "Username", USER_NAME);

	config.save(get_game_dir()+"/config.ini");

func checkSettingsFile():
	var configDir = get_game_dir()+"/config.ini";
	var dir = Directory.new();
	if (!dir.file_exists(configDir)):
		saveSettings();

func rendering(node):
	return

func _ready() -> void:
	if (DISCORD_PRESENCE):
		activity = Discord.Activity.new()
		assets = activity.get_assets()
		
		setDiscordState("start")
	
	checkSettingsFile();
	loadSettings();
	saveSettings();
	
	pause_mode = PAUSE_MODE_PROCESS;
	
	var inst = load("res://scenes/ui/FPS.tscn").instance();
	add_child(inst);
	inst.visible = SHOW_FPS;
	
	OS.request_permissions();
	
	#Editor Objects Definition
	setup3dArray(object, Appeareances, Objects, 3);
	setup3dArray(gnode, Objects, 5000, 31);
	setupArray(objects_count, Objects, true);
	
	#Super Mario Bros
	#Terrain
	configObject(APP_SMB, OBJ_FLOOR, load("res://scenes/appearances/smb/blocks/floor.tscn"), "Suelo", load("res://sprites/appeareances/smb/icons/terrain/floor.png"));
	configObject(APP_SMB, OBJ_BLOCK, load("res://scenes/appearances/smb/blocks/block.tscn"), "Bloque", load("res://sprites/appeareances/smb/icons/terrain/block.png"));
	configObject(APP_SMB, OBJ_BRICK, load("res://scenes/appearances/smb/blocks/brick.tscn"), "Ladrillo", load("res://sprites/appeareances/smb/icons/terrain/brick.png"));
	configObject(APP_SMB, OBJ_LUCKYBLOCK, load("res://scenes/appearances/smb/blocks/luckyblock.tscn"), "Bloque ?", load("res://sprites/appeareances/smb/icons/terrain/luckyblock.png"));
	configObject(APP_SMB, OBJ_INVISIBLE_LUCKYBLOCK, load("res://scenes/appearances/smb/blocks/invisible_luckyblock.tscn"), "Bloque ? Invisible", load("res://sprites/appeareances/smb/icons/terrain/invisible_luckyblock.png"));
	configObject(APP_SMB, OBJ_CLOUD, load("res://scenes/appearances/smb/blocks/cloud.tscn"), "Bloque Nube", load("res://sprites/appeareances/smb/icons/terrain/cloud.png"));
	configObject(APP_SMB, OBJ_DONUT, load("res://scenes/appearances/smb/blocks/donut.tscn"), "Dona", load("res://sprites/appeareances/smb/icons/terrain/donut.png"));
	configObject(APP_SMB, OBJ_SPIKE, load("res://scenes/appearances/smb/blocks/spike.tscn"), "Bloque de Pinchos", load("res://sprites/appeareances/smb/icons/terrain/spike.png"));
	configObject(APP_SMB, OBJ_PIPE, load("res://scenes/appearances/smb/blocks/pipe.tscn"), "Tubería", load("res://sprites/appeareances/smb/icons/terrain/pipe.png"));
	configObject(APP_SMB, OBJ_SEMISOLID, load("res://scenes/appearances/smb/blocks/semisolid.tscn"), "Plataforma", load("res://sprites/appeareances/smb/icons/terrain/semisolid.png"));
	configObject(APP_SMB, OBJ_PIPE_CONNECTOR, load("res://scenes/appearances/smb/blocks/pipe_connector.tscn"), "Conector de Tubería", load("res://sprites/appeareances/smb/icons/terrain/pipe_connector.png"));
	
	#Items
	configObject(APP_SMB, OBJ_COIN, load("res://scenes/appearances/smb/items/coin.tscn"), "Moneda", load("res://sprites/appeareances/smb/icons/items/coin.png"));
	configObject(APP_SMB, OBJ_10COIN, load("res://scenes/appearances/smb/items/10coin.tscn"), "Moneda x10", load("res://sprites/appeareances/smb/icons/items/10coin.png"));
	configObject(APP_SMB, OBJ_30COIN, load("res://scenes/appearances/smb/items/30coin.tscn"), "Moneda x30", load("res://sprites/appeareances/smb/icons/items/30coin.png"));
	configObject(APP_SMB, OBJ_50COIN, load("res://scenes/appearances/smb/items/50coin.tscn"), "Moneda x50", load("res://sprites/appeareances/smb/icons/items/50coin.png"));
	configObject(APP_SMB, OBJ_1UP, load("res://scenes/appearances/smb/items/1up.tscn"), "Vida", load("res://sprites/appeareances/smb/icons/items/1up.png"));
	configObject(APP_SMB, OBJ_STAR, load("res://scenes/appearances/smb/items/star.tscn"), "Estrella", load("res://sprites/appeareances/smb/icons/items/star.png"));
	configObject(APP_SMB, OBJ_MUSHROOM, load("res://scenes/appearances/smb/items/mushroom.tscn"), "Super Champiñón", load("res://sprites/appeareances/smb/icons/items/mushroom.png"));
	configObject(APP_SMB, OBJ_FIREFLOWER, load("res://scenes/appearances/smb/items/fireflower.tscn"), "Flor de Fuego", load("res://sprites/appeareances/smb/icons/items/fireflower.png"));
	
	#Enemies
	configObject(APP_SMB, OBJ_GOOMBA, load("res://scenes/appearances/smb/enemies/goomba.tscn"), "Goomba", load("res://sprites/appeareances/smb/icons/enemies/goomba.png"));
	configObject(APP_SMB, OBJ_KOOPATROOPA, load("res://scenes/appearances/smb/enemies/koopatroopa.tscn"), "Koopa Troopa", load("res://sprites/appeareances/smb/icons/enemies/koopatroopa.png"));
	configObject(APP_SMB, OBJ_SPINY, load("res://scenes/appearances/smb/enemies/spiny.tscn"), "Koopa Espinoso", load("res://sprites/appeareances/smb/icons/enemies/spiny.png"));
	configObject(APP_SMB, OBJ_PIRANHAPLANT, load("res://scenes/appearances/smb/enemies/piranhaplant.tscn"), "Planta Piraña", load("res://sprites/appeareances/smb/icons/enemies/piranhaplant.png"));
	configObject(APP_SMB, OBJ_MUNCHER, load("res://scenes/appearances/smb/enemies/muncher.tscn"), "Tulipán Piraña", load("res://sprites/appeareances/smb/icons/enemies/muncher.png"));
	configObject(APP_SMB, OBJ_TWOMP, load("res://scenes/appearances/smb/enemies/twomp.tscn"), "Twomp", load("res://sprites/appeareances/smb/icons/enemies/twomp.png"));
	configObject(APP_SMB, OBJ_KOOPATROOPA_RED, load("res://scenes/appearances/smb/enemies/koopatroopa_red.tscn"), "Koopa Troopa Rojo", load("res://sprites/appeareances/smb/icons/enemies/koopatroopa_red.png"));
	configObject(APP_SMB, OBJ_PIRANHAPLANT_FIRE, load("res://scenes/appearances/smb/enemies/piranhaplant_fire.tscn"), "Planta Piraña de Fuego", load("res://sprites/appeareances/smb/icons/enemies/piranhaplant_fire.png"));
	configObject(APP_SMB, OBJ_GOOMBRAT, load("res://scenes/appearances/smb/enemies/goombrat.tscn"), "Goombrat", load("res://sprites/appeareances/smb/icons/enemies/goombrat.png"));
	configObject(APP_SMB, OBJ_DRYBONES, load("res://scenes/appearances/smb/enemies/drybones.tscn"), "Drybones", load("res://sprites/appeareances/smb/icons/enemies/drybones.png"));
	
	#Gizmos
	configObject(APP_SMB, OBJ_BURNER, load("res://scenes/appearances/smb/gizmos/burner.tscn"), "Soplete", load("res://sprites/appeareances/smb/icons/gizmos/burner.png"));
	configObject(APP_SMB, OBJ_P, load("res://scenes/appearances/smb/gizmos/p.tscn"), "Botón P", load("res://sprites/appeareances/smb/icons/gizmos/p.png"));
	configObject(APP_SMB, OBJ_PBLOCK, load("res://scenes/appearances/smb/gizmos/pblock.tscn"), "Bloque P", load("res://sprites/appeareances/smb/icons/gizmos/pblock.png"));
	configObject(APP_SMB, OBJ_ONOFFSWITCH, load("res://scenes/appearances/smb/gizmos/onoffswitch.tscn"), "Interruptor", load("res://sprites/appeareances/smb/icons/gizmos/onoffswitch.png"));
	configObject(APP_SMB, OBJ_OFFBLOCK, load("res://scenes/appearances/smb/gizmos/offblock.tscn"), "Bloque de Interruptor (ON)", load("res://sprites/appeareances/smb/icons/gizmos/offblock.png"));
	configObject(APP_SMB, OBJ_ONBLOCK, load("res://scenes/appearances/smb/gizmos/onblock.tscn"), "Bloque de Interruptor (OFF)", load("res://sprites/appeareances/smb/icons/gizmos/onblock.png"));
	configObject(APP_SMB, OBJ_CHECKPOINT, load("res://scenes/appearances/smb/gizmos/checkpoint.tscn"), "Checkpoint", load("res://sprites/appeareances/smb/icons/gizmos/checkpoint.png"));
	configObject(APP_SMB, OBJ_ARROW, load("res://scenes/appearances/smb/gizmos/arrow.tscn"), "Flecha", load("res://sprites/appeareances/smb/icons/gizmos/arrow.png"));
	configObject(APP_SMB, OBJ_ONOFFSWITCH2, load("res://scenes/appearances/smb/gizmos/onoffswitch2.tscn"), "Interruptor", load("res://sprites/appeareances/smb/icons/gizmos/onoffswitch2.png"));
	configObject(APP_SMB, OBJ_OFFBLOCK2, load("res://scenes/appearances/smb/gizmos/offblock2.tscn"), "Bloque de Interruptor (ON)", load("res://sprites/appeareances/smb/icons/gizmos/offblock2.png"));
	configObject(APP_SMB, OBJ_ONBLOCK2, load("res://scenes/appearances/smb/gizmos/onblock2.tscn"), "Bloque de Interruptor (OFF)", load("res://sprites/appeareances/smb/icons/gizmos/onblock2.png"));
	
	#Super Mario Bros 3
	#Terrain
	configObject(APP_SMB3, OBJ_FLOOR, load("res://scenes/appearances/smb3/blocks/floor.tscn"), "Suelo", load("res://sprites/appeareances/smb3/icons/terrain/floor.png"));
	configObject(APP_SMB3, OBJ_BLOCK, load("res://scenes/appearances/smb3/blocks/block.tscn"), "Bloque", load("res://sprites/appeareances/smb3/icons/terrain/block.png"));
	configObject(APP_SMB3, OBJ_BRICK, load("res://scenes/appearances/smb3/blocks/brick.tscn"), "Ladrillo", load("res://sprites/appeareances/smb3/icons/terrain/brick.png"));
	configObject(APP_SMB3, OBJ_LUCKYBLOCK, load("res://scenes/appearances/smb3/blocks/luckyblock.tscn"), "Bloque ?", load("res://sprites/appeareances/smb3/icons/terrain/luckyblock.png"));
	configObject(APP_SMB3, OBJ_INVISIBLE_LUCKYBLOCK, load("res://scenes/appearances/smb3/blocks/invisible_luckyblock.tscn"), "Bloque ? Invisible", load("res://sprites/appeareances/smb3/icons/terrain/invisible_luckyblock.png"));
	configObject(APP_SMB3, OBJ_CLOUD, load("res://scenes/appearances/smb3/blocks/cloud.tscn"), "Bloque Nube", load("res://sprites/appeareances/smb3/icons/terrain/cloud.png"));
	configObject(APP_SMB3, OBJ_DONUT, load("res://scenes/appearances/smb3/blocks/donut.tscn"), "Dona", load("res://sprites/appeareances/smb3/icons/terrain/donut.png"));
	configObject(APP_SMB3, OBJ_SPIKE, load("res://scenes/appearances/smb3/blocks/spike.tscn"), "Bloque de Pinchos", load("res://sprites/appeareances/smb3/icons/terrain/spike.png"));
	configObject(APP_SMB3, OBJ_PIPE, load("res://scenes/appearances/smb3/blocks/pipe.tscn"), "Tubería", load("res://sprites/appeareances/smb3/icons/terrain/pipe.png"));
	configObject(APP_SMB3, OBJ_SEMISOLID, load("res://scenes/appearances/smb3/blocks/semisolid.tscn"), "Plataforma", load("res://sprites/appeareances/smb3/icons/terrain/semisolid.png"));
	configObject(APP_SMB3, OBJ_PIPE_CONNECTOR, load("res://scenes/appearances/smb3/blocks/pipe_connector.tscn"), "Conector de Tubería", load("res://sprites/appeareances/smb3/icons/terrain/pipe_connector.png"));
	
	#Items
	configObject(APP_SMB3, OBJ_COIN, load("res://scenes/appearances/smb3/items/coin.tscn"), "Moneda", load("res://sprites/appeareances/smb3/icons/items/coin.png"));
	configObject(APP_SMB3, OBJ_10COIN, load("res://scenes/appearances/smb3/items/10coin.tscn"), "Moneda x10", load("res://sprites/appeareances/smb3/icons/items/10coin.png"));
	configObject(APP_SMB3, OBJ_30COIN, load("res://scenes/appearances/smb3/items/30coin.tscn"), "Moneda x30", load("res://sprites/appeareances/smb3/icons/items/30coin.png"));
	configObject(APP_SMB3, OBJ_50COIN, load("res://scenes/appearances/smb3/items/50coin.tscn"), "Moneda x50", load("res://sprites/appeareances/smb3/icons/items/50coin.png"));
	configObject(APP_SMB3, OBJ_1UP, load("res://scenes/appearances/smb3/items/1up.tscn"), "Vida", load("res://sprites/appeareances/smb3/icons/items/1up.png"));
	configObject(APP_SMB3, OBJ_STAR, load("res://scenes/appearances/smb3/items/star.tscn"), "Estrella", load("res://sprites/appeareances/smb3/icons/items/star.png"));
	configObject(APP_SMB3, OBJ_MUSHROOM, load("res://scenes/appearances/smb3/items/mushroom.tscn"), "Super Champiñón", load("res://sprites/appeareances/smb3/icons/items/mushroom.png"));
	configObject(APP_SMB3, OBJ_FIREFLOWER, load("res://scenes/appearances/smb3/items/fireflower.tscn"), "Flor de Fuego", load("res://sprites/appeareances/smb3/icons/items/fireflower.png"));
	
	#Enemies
	configObject(APP_SMB3, OBJ_GOOMBA, load("res://scenes/appearances/smb3/enemies/goomba.tscn"), "Goomba", load("res://sprites/appeareances/smb3/icons/enemies/goomba.png"));
	configObject(APP_SMB3, OBJ_KOOPATROOPA, load("res://scenes/appearances/smb3/enemies/koopatroopa.tscn"), "Koopa Troopa", load("res://sprites/appeareances/smb3/icons/enemies/koopatroopa.png"));
	configObject(APP_SMB3, OBJ_SPINY, load("res://scenes/appearances/smb3/enemies/spiny.tscn"), "Koopa Espinoso", load("res://sprites/appeareances/smb3/icons/enemies/spiny.png"));
	configObject(APP_SMB3, OBJ_PIRANHAPLANT, load("res://scenes/appearances/smb3/enemies/piranhaplant.tscn"), "Planta Piraña", load("res://sprites/appeareances/smb3/icons/enemies/piranhaplant.png"));
	configObject(APP_SMB3, OBJ_MUNCHER, load("res://scenes/appearances/smb3/enemies/muncher.tscn"), "Tulipán Piraña", load("res://sprites/appeareances/smb3/icons/enemies/muncher.png"));
	configObject(APP_SMB3, OBJ_TWOMP, load("res://scenes/appearances/smb3/enemies/twomp.tscn"), "Twomp", load("res://sprites/appeareances/smb3/icons/enemies/twomp.png"));
	configObject(APP_SMB3, OBJ_KOOPATROOPA_RED, load("res://scenes/appearances/smb3/enemies/koopatroopa_red.tscn"), "Koopa Troopa Rojo", load("res://sprites/appeareances/smb3/icons/enemies/koopatroopa_red.png"));
	configObject(APP_SMB3, OBJ_PIRANHAPLANT_FIRE, load("res://scenes/appearances/smb3/enemies/piranhaplant_fire.tscn"), "Planta Piraña de Fuego", load("res://sprites/appeareances/smb3/icons/enemies/piranhaplant_fire.png"));
	configObject(APP_SMB3, OBJ_GOOMBRAT, load("res://scenes/appearances/smb3/enemies/goombrat.tscn"), "Goombrat", load("res://sprites/appeareances/smb3/icons/enemies/goombrat.png"));
	configObject(APP_SMB3, OBJ_DRYBONES, load("res://scenes/appearances/smb3/enemies/drybones.tscn"), "Drybones", load("res://sprites/appeareances/smb3/icons/enemies/drybones.png"));
	
	#Gizmos
	configObject(APP_SMB3, OBJ_BURNER, load("res://scenes/appearances/smb3/gizmos/burner.tscn"), "Soplete", load("res://sprites/appeareances/smb3/icons/gizmos/burner.png"));
	configObject(APP_SMB3, OBJ_P, load("res://scenes/appearances/smb3/gizmos/p.tscn"), "Botón P", load("res://sprites/appeareances/smb3/icons/gizmos/p.png"));
	configObject(APP_SMB3, OBJ_PBLOCK, load("res://scenes/appearances/smb3/gizmos/pblock.tscn"), "Bloque P", load("res://sprites/appeareances/smb3/icons/gizmos/pblock.png"));
	configObject(APP_SMB3, OBJ_ONOFFSWITCH, load("res://scenes/appearances/smb3/gizmos/onoffswitch.tscn"), "Interruptor", load("res://sprites/appeareances/smb3/icons/gizmos/onoffswitch.png"));
	configObject(APP_SMB3, OBJ_OFFBLOCK, load("res://scenes/appearances/smb3/gizmos/offblock.tscn"), "Bloque de Interruptor (ON)", load("res://sprites/appeareances/smb3/icons/gizmos/offblock.png"));
	configObject(APP_SMB3, OBJ_ONBLOCK, load("res://scenes/appearances/smb3/gizmos/onblock.tscn"), "Bloque de Interruptor (OFF)", load("res://sprites/appeareances/smb3/icons/gizmos/onblock.png"));
	configObject(APP_SMB3, OBJ_CHECKPOINT, load("res://scenes/appearances/smb3/gizmos/checkpoint.tscn"), "Checkpoint", load("res://sprites/appeareances/smb3/icons/gizmos/checkpoint.png"));
	configObject(APP_SMB3, OBJ_ARROW, load("res://scenes/appearances/smb3/gizmos/arrow.tscn"), "Flecha", load("res://sprites/appeareances/smb3/icons/gizmos/arrow.png"));
	configObject(APP_SMB3, OBJ_ONOFFSWITCH2, load("res://scenes/appearances/smb3/gizmos/onoffswitch2.tscn"), "Interruptor", load("res://sprites/appeareances/smb3/icons/gizmos/onoffswitch2.png"));
	configObject(APP_SMB3, OBJ_OFFBLOCK2, load("res://scenes/appearances/smb3/gizmos/offblock2.tscn"), "Bloque de Interruptor (ON)", load("res://sprites/appeareances/smb3/icons/gizmos/offblock2.png"));
	configObject(APP_SMB3, OBJ_ONBLOCK2, load("res://scenes/appearances/smb3/gizmos/onblock2.tscn"), "Bloque de Interruptor (OFF)", load("res://sprites/appeareances/smb3/icons/gizmos/onblock2.png"));

func configObject(app, obj, scene, name, icon):
	object[app][obj][OP_SCENE] = scene;
	object[app][obj][OP_NAME] = name;
	object[app][obj][OP_ICON] = icon;

func setupArray(array, x, INT = false):
	for i in range(x): 
		array.append([]);
		if (INT):
			array[i] = 0;

func setup2dArray(array, x, y):
	for i in range(x): 
		array.append([]);
		for j in range(y): 
			array[i].append(0);
func setup3dArray(array, width, height, depth):
	array.resize(width);   # X-dimension
	for x in width:
		array[x] = []
		array[x].resize(height)    # Y-dimension
		for y in height:
			array[x][y] = []
			array[x][y].resize(depth)    # Z-dimension
			for z in depth:
				array[x][y][z] = null;

func renderAll():
	emit_signal("render", "", true, 70);

func unrenderAll():
	pass

func renderize():
	var nodes = get_tree().get_nodes_in_group("Obj");
	for node in nodes:
		var scrwidth = OS.get_window_size().x;
		var scrheight = OS.get_window_size().y;
		var multiplier = 720/scrheight;
		var finalscrwidth = scrwidth * multiplier;
		var distance = abs(node.position.x-Global.campos.x);
		if (distance-(finalscrwidth/2) > finalscrwidth*(70*0.01)):
			set_process(false);
			set_physics_process(false);
		else:
			set_process(true);
			set_physics_process(true);
	
	can_render = true;

func startAppearanceChange(app, start = false, editor : Node = null):
	#thread = Thread.new();
	#thread.start(self, "appearanceChange", [app, start, editor])
	appearanceChange([app, start, editor])

func appearanceChange(userdata):
	var app = userdata[0];
	var start = userdata[1];
	var editor = userdata[2];
	if (editor == null):
		return
	if (app == CurrentAppeareance && !start):
		return
	
	get_tree().paused = true;
	
	if (!playing):
		editor.editorMusic(false, false);
	var last_app = CurrentAppeareance;
	CurrentAppeareance = app;
	editor.updateObjectButtons();
	
	if (!playing):
		editor.editorMusic(true, false);
	
	if (!start):
#		Global.emit_signal("changeStyle");
		editor.get_node("AppeareanceChangeIcon/AnimationPlayer").play("in");
		editor.get_node("UIBlocker").show();
		$FPS.hide();
		var itex = ImageTexture.new()
		itex.create_from_image(get_viewport().get_texture().get_data())
		editor.get_node("Screenshot").texture = itex;
		editor.get_node("Screenshot").show();
		var nodes = get_tree().get_nodes_in_group("Obj");
		for node in nodes:
			if (!node.is_in_group("FalseFloor")):
				var obj = getObjectCode(node);
				#print(obj)
				var pos = node.position;
				var inst = Global.object[Global.CurrentAppeareance][obj][Global.OP_SCENE].instance();
				if (obj == Global.OBJ_FLOOR):
					inst.decorationType = node.decorationType;
					if (Global.CurrentAppeareance != Global.APP_SMB && last_app != Global.APP_SMB):
						inst.defaultFrameCoords = node.defaultFrameCoords;
						inst.defaultFalseUp = node.defaultFalseUp;
						inst.defaultFalseUp2 = node.defaultFalseUp2;
						inst.defaultFalseCenter = node.defaultFalseCenter;
						inst.defaultFalseCenter2 = node.defaultFalseCenter2;
				
				if (node.is_in_group("Insideable")):
					inst.objectInside = node.objectInside;
					inst.objectAttribute = node.objectAttribute;
				
				if (obj == OBJ_BURNER || obj == OBJ_TWOMP || obj == OBJ_CHECKPOINT
				|| obj == OBJ_ARROW || obj == OBJ_PIPE):
					inst.seldirection = node.seldirection;
				
				if (obj == OBJ_DRYBONES || obj == OBJ_SPINY):
					inst.alreadydead = node.alreadydead;
				
				if (obj == OBJ_PIPE || obj == OBJ_SEMISOLID || obj == OBJ_PIPE_CONNECTOR):
					inst.grid_origin = node.grid_origin;
					inst.grid_end = node.grid_end;
					if (obj == OBJ_PIPE):
						inst.pipe_code = node.pipe_code
					if (obj == OBJ_SEMISOLID):
						inst.visual_grid_end = node.visual_grid_end
				
				editor.get_parent().eraseObject(pos, false, false, false);
				editor.get_parent().placeObject(pos, false, obj, false, false, inst);
	get_tree().paused = false;
	editor.emit_signal("appearanceChanged", app);
	yield(get_tree(), "idle_frame");
	editor.styleChange(CurrentStyle, true, true);
	editor.get_node("Screenshot").hide();
	editor.get_node("AppeareanceChangeIcon/AnimationPlayer").play("out");
	editor.get_node("UIBlocker").hide();
	if (SHOW_FPS):
		$FPS.show();
	
	print("Appearance Changed Successfully");
	
	#thread.wait_to_finish();

func _process(delta):
	if (!changingToEditMode && !OS.window_minimized):
		emit_signal("render", "", false, 70);
#		if (can_render):
#			can_render = false;
#			if (!first_render):
#				render_thread.wait_to_finish();
#			render_thread = Thread.new();
#			render_thread.start(self, "renderize");
#			first_render = false;

	#Render System
#	if (alternRender && !changingToEditMode):
#		var nodes = get_tree().get_nodes_in_group("Obj");
#		var scrwidth = OS.get_window_size().x;
#		var scrheight = OS.get_window_size().y;
#		var multiplier = 720/scrheight;
#		var finalscrwidth = scrwidth * multiplier;
#		for node in nodes:
#			#if (node.get_node("../Editor").playing):
#			if (!node.is_in_group("Burner")
#			&& !node.is_in_group("OnOffSwitch")
#			&& !node.is_in_group("Twomp")
#			&& !node.is_in_group("Insideable")):
#				var distance = abs(node.position.x-campos.x);
#
#				if (distance-(finalscrwidth/2) > finalscrwidth*0.55):
#					node.set_process(false);
#					node.set_physics_process(false);
#					if (node.is_in_group("Enemy")):
#						node.rendered = false;
#				else:
#					node.set_process(true);
#					node.set_physics_process(true);
#					if (node.is_in_group("Enemy")):
#						node.rendered = true;
#			#else:
#			#	node.set_process(true);
#			#	node.set_physics_process(true);
#			#	if (node.is_in_group("Enemy")):
#			#			node.rendered = true;
#	else:
#		renderAll();
	if (changingToEditMode):
		renderAll();
	
	if (Input.is_action_just_pressed("fullscreen")):
		OS.window_fullscreen = !OS.window_fullscreen;
	if (Input.is_action_just_pressed("fps")):
		FPS = !FPS;
		
	#if (Input.is_action_just_pressed("setnodes")):
	#	toLoad = true;
	
	if (changingToEditMode):
		changingToEditTimer += delta;
		if (changingToEditTimer >= 0.25):
			changingToEditMode = false;
			changingToEditTimer = 0.0;
			unrenderAll();

func showMessage(text, tree, realtree = null, type : String = ""):
	var scene = preload("res://scenes/ui/messagebox.tscn");
	var inst = scene.instance();
	tree.add_child(inst);
	inst.setText(text);
	inst.realmenu = realtree;
	inst.type = type;

func spawnSettings(tree, realtree = null):
	var scene = preload("res://scenes/ui/settings.tscn");
	var inst = scene.instance();
	tree.add_child(inst);
	inst.realmenu = realtree;

func enterText(guidetext, type, tree, realtree = null):
	var scene = preload("res://scenes/ui/Keyboard.tscn");
	var inst = scene.instance();
	tree.add_child(inst);
	tree.editingText = true;
	inst.setText(guidetext);
	inst.realmenu = realtree;
	inst.type = type;
	return inst;

func _input(event):
	if (event is InputEventMouse || event is InputEventScreenTouch):
		if (CurrentInput != "Mouse"):
			CurrentInput = "Mouse";
			var nodes = get_tree().get_nodes_in_group("CurrentTree");
			for node in nodes:
				if (node.visible && node.has_method("changeInput")):
					node.changeInput();
			print("Input was changed to "+CurrentInput);
	if (event is InputEventJoypadButton || event is InputEventJoypadMotion):
		if (CurrentInput != "Gamepad"):
			CurrentInput = "Gamepad";
			var nodes = get_tree().get_nodes_in_group("CurrentTree");
			for node in nodes:
				if (node.visible && node.has_method("changeInput")):
					node.changeInput();
			print("Input was changed to "+CurrentInput);

func changeScene(scene, var tree = null):
	var inst = transition.instance();
	if (tree == null):
		var nodes = get_tree().get_nodes_in_group("CurrentTree");
		for node in nodes:
			if (node.visible && !node.branchmenu):
				node.add_child(inst);
	else:
		tree.add_child(inst);
	inst.scene = scene;
	inst.get_node("Transition/AnimationPlayer").play("in");

func transition(var tree = null):
	var inst = transition_out.instance();
	if (tree == null):
		var nodes = get_tree().get_nodes_in_group("CurrentTree");
		for node in nodes:
			if (node.visible && !node.branchmenu):
				node.add_child(inst);
	else:
		tree.add_child(inst);
	inst.get_node("TransitionOut/AnimationPlayer").play("out");

func getCategory(var objCode):
	var category = "none";
	match (objCode):
		#Terrain
		OBJ_FLOOR: category = "Terrain"
		OBJ_BRICK: category = "Terrain"
		OBJ_BLOCK: category = "Terrain"
		OBJ_LUCKYBLOCK: category = "Terrain"
		OBJ_INVISIBLE_LUCKYBLOCK: category = "Terrain"
		OBJ_CLOUD: category = "Terrain"
		OBJ_DONUT: category = "Terrain"
		OBJ_SPIKE: category = "Terrain"
		OBJ_PIPE: category = "Terrain"
		OBJ_SEMISOLID: category = "Terrain"
		OBJ_PIPE_CONNECTOR: category = "Terrain"
		#Items
		OBJ_COIN: category = "Items"
		OBJ_10COIN: category = "Items"
		OBJ_30COIN: category = "Items"
		OBJ_50COIN: category = "Items"
		OBJ_1UP: category = "Items"
		OBJ_STAR: category = "Items"
		OBJ_MUSHROOM: category = "Items"
		OBJ_FIREFLOWER: category = "Items"
		#Enemies
		OBJ_GOOMBA: category = "Enemies"
		OBJ_KOOPATROOPA: category = "Enemies"
		OBJ_SPINY: category = "Enemies"
		OBJ_PIRANHAPLANT: category = "Enemies"
		OBJ_MUNCHER: category = "Enemies"
		OBJ_TWOMP: category = "Enemies"
		OBJ_KOOPATROOPA_RED: category = "Enemies"
		OBJ_PIRANHAPLANT_FIRE: category = "Enemies"
		OBJ_GOOMBRAT: category = "Enemies"
		OBJ_DRYBONES: category = "Enemies"
		#Gizmos
		OBJ_BURNER: category = "Gizmos"
		OBJ_P: category = "Gizmos"
		OBJ_PBLOCK: category = "Gizmos"
		OBJ_ONOFFSWITCH: category = "Gizmos"
		OBJ_ONBLOCK: category = "Gizmos"
		OBJ_OFFBLOCK: category = "Gizmos"
		OBJ_ONOFFSWITCH2: category = "Gizmos"
		OBJ_ONBLOCK2: category = "Gizmos"
		OBJ_OFFBLOCK2: category = "Gizmos"
		OBJ_CHECKPOINT: category = "Gizmos"
		OBJ_ARROW: category = "Gizmos"
	
	return category;
	
func hasVariants(var objCode):
	var variants = false;
	match (objCode):
		#Items
		OBJ_FIREFLOWER: variants = true;
		OBJ_ONBLOCK: variants = true;
		OBJ_OFFBLOCK: variants = true;
		OBJ_ONBLOCK2: variants = true;
		OBJ_OFFBLOCK2: variants = true;
		OBJ_ONOFFSWITCH: variants = true;
		OBJ_ONOFFSWITCH2: variants = true;
		OBJ_10COIN: variants = true;
		OBJ_30COIN: variants = true;
		OBJ_50COIN: variants = true;
		
		#Enemies
		OBJ_PIRANHAPLANT: variants = true;
		OBJ_PIRANHAPLANT_FIRE: variants = true;
		OBJ_GOOMBA: variants = true;
		OBJ_GOOMBRAT: variants = true;
		OBJ_SPINY: variants = true;
		OBJ_KOOPATROOPA: variants = true;
		OBJ_KOOPATROOPA_RED: variants = true;
		OBJ_DRYBONES: variants = true;
	
	return variants;

func isChainable(var objCode):
	var chainable = false;
	match (objCode):
		OBJ_GOOMBA: chainable = true;
		OBJ_GOOMBRAT: chainable = true;
		OBJ_DRYBONES: chainable = true;
		OBJ_KOOPATROOPA: chainable = true;
		OBJ_KOOPATROOPA_RED: chainable = true;
		OBJ_SPINY: chainable = true;
	
	return chainable;

func setDiscordState(state: String):
	if (state == "start"):
		activity.set_type(Discord.ActivityType.Playing)
		
		timestamps = activity.get_timestamps()
		timestamps.set_start(OS.get_unix_time())
		
		activity.set_details("Iniciando Wonder Maker")
		activity.set_state("")
		assets.set_large_image("deficon")
		assets.set_large_text("WM")
		assets.set_small_image("")
		assets.set_small_text("")
	else:
		yield(get_tree(), "idle_frame")
		match (state):
			"startmenu":
				activity.set_details("En el menú de inicio")
				activity.set_state("")
				assets.set_small_image("")
				assets.set_small_text("")
				assets.set_large_image("deficon")
				assets.set_large_text("WM")
			"editor":
				activity.set_details("Creando un Nivel");
				if (Global.currentCourseName != ""):
					activity.set_state("Nivel: "+Global.currentCourseName);
				else:
					activity.set_state("")
				assets.set_small_image("cursor_editor")
				assets.set_small_text("Cursor")
				assets.set_large_image("deficon")
				assets.set_large_text("WM")
			"playing_coursebot":
				activity.set_details("Jugando un nivel del Guardabot");
				if (Global.currentCourseName != ""):
					activity.set_state("Nivel: "+currentCourseName);
				else:
					activity.set_state("")
				assets.set_small_image("playing")
				assets.set_small_text("Joycon")
				assets.set_large_image("deficon")
				assets.set_large_text("WM")
			"playing_courseworld":
				activity.set_details("Jugando un nivel online");
				activity.set_state("Nivel: "+currentCourseName);
				assets.set_small_image("courseworld")
				assets.set_small_text("Niveles Mundiales")
				assets.set_large_image("deficon")
				assets.set_large_text("WM")
			"courseworld":
				activity.set_details("Niveles Mundiales");
				activity.set_state("");
				assets.set_small_image("courseworld")
				assets.set_small_text("Niveles Mundiales")
				assets.set_large_image("deficon")
				assets.set_large_text("WM")
			"login":
				activity.set_details("Iniciando Sesión");
				activity.set_state("");
				assets.set_small_image("courseworld")
				assets.set_small_text("Niveles Mundiales")
				assets.set_large_image("deficon")
				assets.set_large_text("WM")
			"coursebot":
				activity.set_details("En el guardabot");
				activity.set_state("")
				assets.set_small_image("coursebot")
				assets.set_small_text("Guardabot")
				assets.set_large_image("deficon")
				assets.set_large_text("WM")
	
	var result = yield(Discord.activity_manager.update_activity(activity), "result").result
	if result != Discord.Result.Ok:
		push_error(str(result))
