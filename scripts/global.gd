extends Node

var transition = preload("res://scenes/ui/transition.tscn");
var transition_out = preload("res://scenes/ui/transition_out.tscn");

signal gameLoaded

#APPEAREANCES
const APP_SMB = 0;
const APP_SMB3 = 1;

const GAME_VERSION = "1.2";

#Editor Objects
var OP_SCENE = 0;
var OP_NAME = 1;
var OP_ICON = 2;
var object = [];

var Objects = 38;
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

var objects_count = []

var CurrentAppeareance = APP_SMB;
var CurrentStyle = "Ground";
var CurrentSpeed = "None";
var CurrentDefaultPowerup = "small";
var CurrentStar = "false";
var CurrentTime = 300;
var CurrentMusic = "true";

var FPS = false;
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

func courseGetAppeareance(filedir):
	var f = File.new()
	f.open(filedir, File.READ);
	
	var appeareance = "";
	
	f.get_line();
	appeareance = f.get_line();
	
	f.close();
	
	return appeareance;

func courseGetStyle(filedir):
	var f = File.new()
	f.open(filedir, File.READ);
	
	var style = "";
	
	f.get_line();
	f.get_line();
	style = f.get_line();
	
	f.close();
	
	return style;

func courseGetAppearance(filedir):
	var f = File.new()
	f.open(filedir, File.READ);
	
	var appearance = "";
	
	f.get_line();
	appearance = int(f.get_line());
	
	f.close();
	
	return appearance;

func courseGetDescription(filedir):
	var f = File.new()
	f.open(filedir, File.READ);
	
	var description = "";
	
	f.get_line();
	f.get_line();
	f.get_line();
	description = f.get_line();
	
	f.close();
	
	return description;

func courseGetUser(filedir):
	var f = File.new()
	f.open(filedir, File.READ);
	
	var user = "";
	
	f.get_line();
	f.get_line();
	f.get_line();
	f.get_line();
	user = f.get_line();
	
	f.close();
	
	return user;

func courseGetVersion(filedir):
	var f = File.new()
	f.open(filedir, File.READ);
	
	var version = f.get_line();
	
	f.close();
	
	return version;

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

func saveCourseData(ingame = true):
	if (ingame):
		setLevelInfo();
	
	print("Course Data Saved")
	var f = File.new()
	f.open(currentlevel, File.WRITE);
	
	f.store_line(GAME_VERSION);
	f.store_line(str(CurrentAppeareance));
	f.store_line(CurrentStyle);
	
	f.store_line(currentCourseDescription);
	f.store_line(currentCourseUser);
	
	f.store_line(var2str(levelfloor_grid));
	f.store_line(var2str(endfloor_grid));
	
	f.store_line(CurrentDefaultPowerup);
	f.store_line(CurrentStar);
	f.store_line(CurrentSpeed);
	f.store_line(str(CurrentTime));
	f.store_line(CurrentMusic);
	
	for i in range(Objects):
		f.store_line(str(objects_count[i]));
		for j in range(objects_count[i]):
			for k in range(30):
				if (gnode[i][j][k] != null):
					f.store_line(var2str(gnode[i][j][k]));
				else:
					f.store_line("null");
	f.close()

func loadCourseData(ingame = true):
	print("Course Data Loaded")
	var f = File.new()
	f.open(currentlevel, File.READ);
	
	var version = f.get_line();
	#if (version == GAME_VERSION):
	CurrentAppeareance = int(f.get_line());
	CurrentStyle = f.get_line();
	
	currentCourseDescription = f.get_line();
	currentCourseUser = f.get_line();
	
	levelfloor_grid = str2var(f.get_line());
	endfloor_grid = str2var(f.get_line());
	
	CurrentDefaultPowerup = f.get_line();
	CurrentStar = f.get_line();
	CurrentSpeed =  f.get_line();
	CurrentTime = int(f.get_line());
	CurrentMusic = f.get_line();
	
	for i in range(Objects):
		objects_count[i] = int(f.get_line());
		for j in range(objects_count[i]):
				for k in range(30):
					var dat = f.get_line();
					if (dat != "null"):
						gnode[i][j][k] = str2var(dat);
					else:
						gnode[i][j][k] = null;
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
	
	setNodes();
	nodes = get_tree().get_nodes_in_group("LevelfloorController");
	for node in nodes:
		levelfloor_grid = level.calculateGrid(node.position.x, node.position.y);
	nodes = get_tree().get_nodes_in_group("EndfloorController");
	for node in nodes:
		endfloor_grid = level.calculateGrid(node.position.x, node.position.y);
	print(levelfloor_grid);
	print(endfloor_grid);

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
	
	#yield(get_tree().create_timer(0.25), "timeout");
	level = null;
	nodes = get_tree().get_nodes_in_group("Level");
	for node in nodes:
		level = node;
	loadNodes(level);
	
	emit_signal("gameLoaded");

func setNodes():
	var nodes = get_tree().get_nodes_in_group("Obj");
	
	setup3dArray(gnode, Objects, 5000, Objects+3);
	setupArray(objects_count, Objects, true);
	
	for node in nodes:
		#Floor
		if (!node.is_in_group("FalseFloor") && node.is_in_group("Floor")):
			gnode[OBJ_FLOOR][objects_count[OBJ_FLOOR]][0] = node.position; objects_count[OBJ_FLOOR] += 1;
		#Block
		if (node.is_in_group("Block")):
			gnode[OBJ_BLOCK][objects_count[OBJ_BLOCK]][0] = node.position; objects_count[OBJ_BLOCK] += 1;
		#Brick
		if (node.is_in_group("Brick")):
			gnode[OBJ_BRICK][objects_count[OBJ_BRICK]][0] = node.position;
			if (node.coinInside):
				gnode[OBJ_BRICK][objects_count[OBJ_BRICK]][1] = "coinInside";
			if (node.oneup):
				gnode[OBJ_BRICK][objects_count[OBJ_BRICK]][1] = "oneup";
			if (node.star):
				gnode[OBJ_BRICK][objects_count[OBJ_BRICK]][1] = "star";
			if (node.mushroom):
				gnode[OBJ_BRICK][objects_count[OBJ_BRICK]][1] = "mushroom";
			if (node.fireflower):
				gnode[OBJ_BRICK][objects_count[OBJ_BRICK]][1] = "fireflower";
			if (node.goomba):
				gnode[OBJ_BRICK][objects_count[OBJ_BRICK]][1] = "goomba";
			if (node.koopatroopa):
				gnode[OBJ_BRICK][objects_count[OBJ_BRICK]][1] = "koopatroopa";
			if (node.koopatroopa_red):
				gnode[OBJ_BRICK][objects_count[OBJ_BRICK]][1] = "koopatroopa_red";
			if (node.spiny):
				gnode[OBJ_BRICK][objects_count[OBJ_BRICK]][1] = "spiny";
			if (node.piranhaplant):
				gnode[OBJ_BRICK][objects_count[OBJ_BRICK]][1] = "piranhaplant";
			if (node.withp):
				gnode[OBJ_BRICK][objects_count[OBJ_BRICK]][1] = "withp";
			if (node.piranhaplantfire):
				gnode[OBJ_BRICK][objects_count[OBJ_BRICK]][1] = "piranhaplantfire";
			if (node.goombrat):
				gnode[OBJ_BRICK][objects_count[OBJ_BRICK]][1] = "goombrat";
			if (node.drybones):
				gnode[OBJ_BRICK][objects_count[OBJ_BRICK]][1] = "drybones";
				
			#Atributtes
			if (node.a_mushroom):
				gnode[OBJ_BRICK][objects_count[OBJ_BRICK]][2] = "a_mushroom";
			if (node.a_alreadydead):
				gnode[OBJ_BRICK][objects_count[OBJ_BRICK]][2] = "a_alreadydead";
			
			objects_count[OBJ_BRICK] += 1;
		#Coin
		if (node.is_in_group("Coin") && !node.is_in_group("10Coin") && !node.is_in_group("30Coin") && !node.is_in_group("50Coin")):
			gnode[OBJ_COIN][objects_count[OBJ_COIN]][0] = node.position; objects_count[OBJ_COIN] += 1;
		#Luckyblock
		if (node.is_in_group("Luckyblock") && !node.is_in_group("InvisibleLuckyblock")):
			gnode[OBJ_LUCKYBLOCK][objects_count[OBJ_LUCKYBLOCK]][0] = node.position;
			#Inside Objects
			if (node.coinInside):
				gnode[OBJ_LUCKYBLOCK][objects_count[OBJ_LUCKYBLOCK]][1] = "coinInside";
			if (node.oneup):
				gnode[OBJ_LUCKYBLOCK][objects_count[OBJ_LUCKYBLOCK]][1] = "oneup";
			if (node.star):
				gnode[OBJ_LUCKYBLOCK][objects_count[OBJ_LUCKYBLOCK]][1] = "star";
			if (node.mushroom):
				gnode[OBJ_LUCKYBLOCK][objects_count[OBJ_LUCKYBLOCK]][1] = "mushroom";
			if (node.fireflower):
				gnode[OBJ_LUCKYBLOCK][objects_count[OBJ_LUCKYBLOCK]][1] = "fireflower";
			if (node.goomba):
				gnode[OBJ_LUCKYBLOCK][objects_count[OBJ_LUCKYBLOCK]][1] = "goomba";
			if (node.koopatroopa):
				gnode[OBJ_LUCKYBLOCK][objects_count[OBJ_LUCKYBLOCK]][1] = "koopatroopa";
			if (node.koopatroopa_red):
				gnode[OBJ_LUCKYBLOCK][objects_count[OBJ_LUCKYBLOCK]][1] = "koopatroopa_red";
			if (node.spiny):
				gnode[OBJ_LUCKYBLOCK][objects_count[OBJ_LUCKYBLOCK]][1] = "spiny";
			if (node.piranhaplant):
				gnode[OBJ_LUCKYBLOCK][objects_count[OBJ_LUCKYBLOCK]][1] = "piranhaplant";
			if (node.withp):
				gnode[OBJ_LUCKYBLOCK][objects_count[OBJ_LUCKYBLOCK]][1] = "withp";
			if (node.piranhaplantfire):
				gnode[OBJ_LUCKYBLOCK][objects_count[OBJ_LUCKYBLOCK]][1] = "piranhaplantfire";
			if (node.goombrat):
				gnode[OBJ_LUCKYBLOCK][objects_count[OBJ_LUCKYBLOCK]][1] = "goombrat";
			if (node.drybones):
				gnode[OBJ_LUCKYBLOCK][objects_count[OBJ_LUCKYBLOCK]][1] = "drybones";
				
			#Atributtes
			if (node.a_mushroom):
				gnode[OBJ_LUCKYBLOCK][objects_count[OBJ_LUCKYBLOCK]][2] = "a_mushroom";
			if (node.a_alreadydead):
				gnode[OBJ_LUCKYBLOCK][objects_count[OBJ_LUCKYBLOCK]][2] = "a_alreadydead";
			
			objects_count[OBJ_LUCKYBLOCK] += 1;
		#Invisible Luckyblock
		if (node.is_in_group("InvisibleLuckyblock")):
			gnode[OBJ_INVISIBLE_LUCKYBLOCK][objects_count[OBJ_INVISIBLE_LUCKYBLOCK]][0] = node.position;
			if (node.coinInside):
				gnode[OBJ_INVISIBLE_LUCKYBLOCK][objects_count[OBJ_INVISIBLE_LUCKYBLOCK]][1] = "coinInside";
			if (node.oneup):
				gnode[OBJ_INVISIBLE_LUCKYBLOCK][objects_count[OBJ_INVISIBLE_LUCKYBLOCK]][1] = "oneup";
			if (node.star):
				gnode[OBJ_INVISIBLE_LUCKYBLOCK][objects_count[OBJ_INVISIBLE_LUCKYBLOCK]][1] = "star";
			if (node.mushroom):
				gnode[OBJ_INVISIBLE_LUCKYBLOCK][objects_count[OBJ_INVISIBLE_LUCKYBLOCK]][1] = "mushroom";
			if (node.fireflower):
				gnode[OBJ_INVISIBLE_LUCKYBLOCK][objects_count[OBJ_INVISIBLE_LUCKYBLOCK]][1] = "fireflower";
			if (node.goomba):
				gnode[OBJ_INVISIBLE_LUCKYBLOCK][objects_count[OBJ_INVISIBLE_LUCKYBLOCK]][1] = "goomba";
			if (node.koopatroopa):
				gnode[OBJ_INVISIBLE_LUCKYBLOCK][objects_count[OBJ_INVISIBLE_LUCKYBLOCK]][1] = "koopatroopa";
			if (node.koopatroopa_red):
				gnode[OBJ_INVISIBLE_LUCKYBLOCK][objects_count[OBJ_INVISIBLE_LUCKYBLOCK]][1] = "koopatroopa_red";
			if (node.spiny):
				gnode[OBJ_INVISIBLE_LUCKYBLOCK][objects_count[OBJ_INVISIBLE_LUCKYBLOCK]][1] = "spiny";
			if (node.piranhaplant):
				gnode[OBJ_INVISIBLE_LUCKYBLOCK][objects_count[OBJ_INVISIBLE_LUCKYBLOCK]][1] = "piranhaplant";
			if (node.withp):
				gnode[OBJ_INVISIBLE_LUCKYBLOCK][objects_count[OBJ_INVISIBLE_LUCKYBLOCK]][1] = "withp";
			if (node.piranhaplantfire):
				gnode[OBJ_INVISIBLE_LUCKYBLOCK][objects_count[OBJ_INVISIBLE_LUCKYBLOCK]][1] = "piranhaplantfire";
			if (node.goombrat):
				gnode[OBJ_INVISIBLE_LUCKYBLOCK][objects_count[OBJ_INVISIBLE_LUCKYBLOCK]][1] = "goombrat";
			if (node.drybones):
				gnode[OBJ_INVISIBLE_LUCKYBLOCK][objects_count[OBJ_INVISIBLE_LUCKYBLOCK]][1] = "drybones";
				
			#Atributtes
			if (node.a_mushroom):
				gnode[OBJ_INVISIBLE_LUCKYBLOCK][objects_count[OBJ_INVISIBLE_LUCKYBLOCK]][2] = "a_mushroom";
			if (node.a_alreadydead):
				gnode[OBJ_INVISIBLE_LUCKYBLOCK][objects_count[OBJ_INVISIBLE_LUCKYBLOCK]][2] = "a_alreadydead";
			
			objects_count[OBJ_INVISIBLE_LUCKYBLOCK] += 1;
		#Cloud
		if (node.is_in_group("Cloud")):
			gnode[OBJ_CLOUD][objects_count[OBJ_CLOUD]][0] = node.position; objects_count[OBJ_CLOUD] += 1;
		#Donut
		if (node.is_in_group("Donut")):
			gnode[OBJ_DONUT][objects_count[OBJ_DONUT]][0] = node.position; objects_count[OBJ_DONUT] += 1;
		#Spike
		if (node.is_in_group("Spike")):
			gnode[OBJ_SPIKE][objects_count[OBJ_SPIKE]][0] = node.position; objects_count[OBJ_SPIKE] += 1;
		#10 Coin
		if (node.is_in_group("10Coin")):
			gnode[OBJ_10COIN][objects_count[OBJ_10COIN]][0] = node.position; 
			gnode[OBJ_10COIN][objects_count[OBJ_10COIN]][10] = node.extension_grid_size;
			for i in range(node.extension_grid_size):
				gnode[OBJ_10COIN][objects_count[OBJ_10COIN]][11+i] = node.default_extension_grid[i];
			objects_count[OBJ_10COIN] += 1;
		#30 Coin
		if (node.is_in_group("30Coin")):
			gnode[OBJ_30COIN][objects_count[OBJ_30COIN]][0] = node.position; 
			gnode[OBJ_30COIN][objects_count[OBJ_30COIN]][10] = node.extension_grid_size;
			for i in range(node.extension_grid_size):
				gnode[OBJ_30COIN][objects_count[OBJ_30COIN]][11+i] = node.default_extension_grid[i];
			objects_count[OBJ_30COIN] += 1;
		#50 Coin
		if (node.is_in_group("50Coin")):
			gnode[OBJ_50COIN][objects_count[OBJ_50COIN]][0] = node.position; 
			gnode[OBJ_50COIN][objects_count[OBJ_50COIN]][10] = node.extension_grid_size;
			for i in range(node.extension_grid_size):
				gnode[OBJ_50COIN][objects_count[OBJ_50COIN]][11+i] = node.default_extension_grid[i];
			objects_count[OBJ_50COIN] += 1;
		#1UP
		if (node.is_in_group("1up")):
			gnode[OBJ_1UP][objects_count[OBJ_1UP]][0] = node.position; objects_count[OBJ_1UP] += 1;
		#MUSHROOM
		if (node.is_in_group("Mushroom")):
			gnode[OBJ_MUSHROOM][objects_count[OBJ_MUSHROOM]][0] = node.position; objects_count[OBJ_MUSHROOM] += 1;
		#STAR
		if (node.is_in_group("Star")):
			gnode[OBJ_STAR][objects_count[OBJ_STAR]][0] = node.position; objects_count[OBJ_STAR] += 1;
		#FIREFLOWER
		if (node.is_in_group("Fireflower")):
			gnode[OBJ_FIREFLOWER][objects_count[OBJ_FIREFLOWER]][0] = node.position;
			if (node.mushroom):
				gnode[OBJ_FIREFLOWER][objects_count[OBJ_FIREFLOWER]][1] = "mushroom";
			objects_count[OBJ_FIREFLOWER] += 1;
		#Goomba
		if (node.is_in_group("Goomba")):
			gnode[OBJ_GOOMBA][objects_count[OBJ_GOOMBA]][0] = node.position; objects_count[OBJ_GOOMBA] += 1;
		#Goombrat
		if (node.is_in_group("Goombrat")):
			gnode[OBJ_GOOMBRAT][objects_count[OBJ_GOOMBRAT]][0] = node.position; objects_count[OBJ_GOOMBRAT] += 1;
		#Koopa Troopa
		if (node.is_in_group("KoopaTroopa")):
			gnode[OBJ_KOOPATROOPA][objects_count[OBJ_KOOPATROOPA]][0] = node.position; objects_count[OBJ_KOOPATROOPA] += 1;
		#Koopa Troopa Red
		if (node.is_in_group("KoopaTroopaRed")):
			gnode[OBJ_KOOPATROOPA_RED][objects_count[OBJ_KOOPATROOPA_RED]][0] = node.position; objects_count[OBJ_KOOPATROOPA_RED] += 1;
		#Spiny
		if (node.is_in_group("Spiny")):
			gnode[OBJ_SPINY][objects_count[OBJ_SPINY]][0] = node.position;
			if (node.alreadydead):
				gnode[OBJ_SPINY][objects_count[OBJ_SPINY]][1] = "alreadydead";
			objects_count[OBJ_SPINY] += 1;
		#Piranha Plant
		if (node.is_in_group("PiranhaPlant")):
			gnode[OBJ_PIRANHAPLANT][objects_count[OBJ_PIRANHAPLANT]][0] = node.position; objects_count[OBJ_PIRANHAPLANT] += 1;
		#Piranha Plant Fire
		if (node.is_in_group("PiranhaPlantFire")):
			gnode[OBJ_PIRANHAPLANT_FIRE][objects_count[OBJ_PIRANHAPLANT_FIRE]][0] = node.position; objects_count[OBJ_PIRANHAPLANT_FIRE] += 1;
		#Muncher
		if (node.is_in_group("Muncher")):
			gnode[OBJ_MUNCHER][objects_count[OBJ_MUNCHER]][0] = node.position; objects_count[OBJ_MUNCHER] += 1;
		#Twomp
		if (node.is_in_group("Twomp")):
			gnode[OBJ_TWOMP][objects_count[OBJ_TWOMP]][0] = node.position;
			gnode[OBJ_TWOMP][objects_count[OBJ_TWOMP]][1] = node.seldirection;
			gnode[OBJ_TWOMP][objects_count[OBJ_TWOMP]][10] = node.extension_grid_size;
			for i in range(node.extension_grid_size):
				gnode[OBJ_TWOMP][objects_count[OBJ_TWOMP]][11+i] = node.default_extension_grid[i];
			objects_count[OBJ_TWOMP] += 1;
		#Dry Bones
		if (node.is_in_group("DryBones")):
			gnode[OBJ_DRYBONES][objects_count[OBJ_DRYBONES]][0] = node.position; objects_count[OBJ_DRYBONES] += 1;
		#Burner
		if (node.is_in_group("Burner")):
			gnode[OBJ_BURNER][objects_count[OBJ_BURNER]][0] = node.position;
			gnode[OBJ_BURNER][objects_count[OBJ_BURNER]][1] = node.seldirection;
			objects_count[OBJ_BURNER] += 1;
		#P
		if (node.is_in_group("P")):
			gnode[OBJ_P][objects_count[OBJ_P]][0] = node.position; objects_count[OBJ_P] += 1;
		#P Block
		if (node.is_in_group("PBlock")):
			gnode[OBJ_PBLOCK][objects_count[OBJ_PBLOCK]][0] = node.position; objects_count[OBJ_PBLOCK] += 1;
		#ON/OFF Switch
		if (node.is_in_group("OnOffSwitch")):
			gnode[OBJ_ONOFFSWITCH][objects_count[OBJ_ONOFFSWITCH]][0] = node.position; objects_count[OBJ_ONOFFSWITCH] += 1;
		#ON/OFF Switch 2
		if (node.is_in_group("OnOffSwitch2")):
			gnode[OBJ_ONOFFSWITCH2][objects_count[OBJ_ONOFFSWITCH2]][0] = node.position; objects_count[OBJ_ONOFFSWITCH2] += 1;
		#ON Block
		if (node.is_in_group("OnBlock")):
			gnode[OBJ_ONBLOCK][objects_count[OBJ_ONBLOCK]][0] = node.position; objects_count[OBJ_ONBLOCK] += 1;
		#ON Block 2
		if (node.is_in_group("OnBlock2")):
			gnode[OBJ_ONBLOCK2][objects_count[OBJ_ONBLOCK2]][0] = node.position; objects_count[OBJ_ONBLOCK2] += 1;
		#OFF Block
		if (node.is_in_group("OffBlock")):
			gnode[OBJ_OFFBLOCK][objects_count[OBJ_OFFBLOCK]][0] = node.position; objects_count[OBJ_OFFBLOCK] += 1;
		#OFF Block 2
		if (node.is_in_group("OffBlock2")):
			gnode[OBJ_OFFBLOCK2][objects_count[OBJ_OFFBLOCK2]][0] = node.position; objects_count[OBJ_OFFBLOCK2] += 1;
		#Checkpoint
		if (node.is_in_group("Checkpoint")):
			gnode[OBJ_CHECKPOINT][objects_count[OBJ_CHECKPOINT]][0] = node.position;
			gnode[OBJ_CHECKPOINT][objects_count[OBJ_CHECKPOINT]][1] = node.seldirection;
			gnode[OBJ_CHECKPOINT][objects_count[OBJ_CHECKPOINT]][10] = node.extension_grid_size;
			for i in range(node.extension_grid_size):
				gnode[OBJ_CHECKPOINT][objects_count[OBJ_CHECKPOINT]][11+i] = node.default_extension_grid[i];
			objects_count[OBJ_CHECKPOINT] += 1;
		#Arrow
		if (node.is_in_group("Arrow")):
			gnode[OBJ_ARROW][objects_count[OBJ_ARROW]][0] = node.position;
			gnode[OBJ_ARROW][objects_count[OBJ_ARROW]][1] = node.seldirection;
			gnode[OBJ_ARROW][objects_count[OBJ_ARROW]][10] = node.extension_grid_size;
			for i in range(node.extension_grid_size):
				gnode[OBJ_ARROW][objects_count[OBJ_ARROW]][11+i] = node.default_extension_grid[i];
			objects_count[OBJ_ARROW] += 1;
		#Pipe
		if (node.is_in_group("Pipe")):
			gnode[OBJ_PIPE][objects_count[OBJ_PIPE]][0] = node.position;
			gnode[OBJ_PIPE][objects_count[OBJ_PIPE]][1] = node.seldirection;
			gnode[OBJ_PIPE][objects_count[OBJ_PIPE]][10] = node.extension_grid_size;
			for i in range(node.extension_grid_size):
				gnode[OBJ_PIPE][objects_count[OBJ_PIPE]][11+i] = node.default_extension_grid[i];
			objects_count[OBJ_PIPE] += 1;

func loadNodes(level):
	if (level == null):
		return
	for i in range(Objects):
		for j in range(objects_count[i]):
			if (gnode[i][j][0] != null):
				var inst = object[CurrentAppeareance][i][OP_SCENE].instance();
				inst.position = gnode[i][j][0];
#				if (i == Global.OBJ_FLOOR):
#					level.get_node("Solids").add_child(inst);
#				else:
				if (inst.is_in_group("OptimizedFloor")):
					level.get_node("Solids").add_child(inst);
				else:
					level.add_child(inst);
				var gr = level.calculateGrid(inst.position.x, inst.position.y);
				if (gr.x > level.grid_size.x || gr.y > level.grid_size.y):
					inst.queue_free();
					return;
				else:
					level.grid[gr.x][gr.y] = i;
					level.grid_node[gr.x][gr.y] = inst;
				
				if (inst.is_in_group("Insideable")):
					if (gnode[i][j][1] != null):
						inst.insided = true;
						match (gnode[i][j][1]):
							"coinInside": inst.coinInside = true;
							"oneup": inst.oneup = true;
							"star": inst.star = true;
							"mushroom": inst.mushroom = true;
							"fireflower": inst.fireflower = true;
							"goomba": inst.goomba = true;
							"koopatroopa": inst.koopatroopa = true;
							"koopatroopa_red": inst.koopatroopa_red = true;
							"spiny": inst.spiny = true;
							"piranhaplant": inst.piranhaplant = true;
							"withp": inst.withp = true;
							"piranhaplantfire": inst.piranhaplantfire = true;
							"goombrat": inst.goombrat = true;
							"drybones": inst.drybones = true;
							
						#Atributes
						match (gnode[i][j][2]):
							"a_mushroom": inst.a_mushroom = true;
							"a_alreadydead": inst.a_alreadydead = true;
				
				if (inst.is_in_group("Extensible")):
					inst.extension_grid_size = gnode[i][j][10];
					for k in range(20):
						if (gnode[i][j][k+10+1] != null):
							inst.default_extension_grid[k] = gnode[i][j][k+10+1];
					inst.setGrids(i);
					
				if (inst.is_in_group("Fireflower")):
					if (gnode[i][j][1] == "mushroom"):
						inst.mushroom = true;
						
				if (inst.is_in_group("Spiny")):
					if (gnode[i][j][1] == "alreadydead"):
						inst.alreadydead = true;
				
				if (inst.is_in_group("Twomp") ||
				inst.is_in_group("Burner") ||
				inst.is_in_group("Checkpoint") ||
				inst.is_in_group("Arrow") ||
				inst.is_in_group("Pipe")):
					inst.seldirection = gnode[i][j][1];
			else:
				break;

func rendering(node):
	return
	var chr;
	if (node.get_node("../Editor").playing):
		chr = node.get_node("../Character");
	else:
		chr = node.get_node("../CharacterEditor");
	var distance = abs(node.position.x-chr.position.x);
	if (distance > 1280/4):
		node.hide();
	else:
		node.show();

func _ready() -> void:
	OS.request_permissions();
	
	#Editor Objects Definition
	setup3dArray(object, Appeareances, Objects, 3);
	setup3dArray(gnode, Objects, 5000, 31);
	setupArray(objects_count, Objects, true);
	
	#Super Mario Bros
	#Terrain
	configObject(APP_SMB, OBJ_FLOOR, load("res://scenes/appearances/smb/blocks/floor.tscn"), "Piso", load("res://sprites/appeareances/smb/icons/terrain/floor.png"));
	configObject(APP_SMB, OBJ_BLOCK, load("res://scenes/appearances/smb/blocks/block.tscn"), "Bloque", load("res://sprites/appeareances/smb/icons/terrain/block.png"));
	configObject(APP_SMB, OBJ_BRICK, load("res://scenes/appearances/smb/blocks/brick.tscn"), "Ladrillo", load("res://sprites/appeareances/smb/icons/terrain/brick.png"));
	configObject(APP_SMB, OBJ_LUCKYBLOCK, load("res://scenes/appearances/smb/blocks/luckyblock.tscn"), "Bloque ?", load("res://sprites/appeareances/smb/icons/terrain/luckyblock.png"));
	configObject(APP_SMB, OBJ_INVISIBLE_LUCKYBLOCK, load("res://scenes/appearances/smb/blocks/invisible_luckyblock.tscn"), "Bloque ? Invisible", load("res://sprites/appeareances/smb/icons/terrain/invisible_luckyblock.png"));
	configObject(APP_SMB, OBJ_CLOUD, load("res://scenes/appearances/smb/blocks/cloud.tscn"), "Bloque Nube", load("res://sprites/appeareances/smb/icons/terrain/cloud.png"));
	configObject(APP_SMB, OBJ_DONUT, load("res://scenes/appearances/smb/blocks/donut.tscn"), "Dona", load("res://sprites/appeareances/smb/icons/terrain/donut.png"));
	configObject(APP_SMB, OBJ_SPIKE, load("res://scenes/appearances/smb/blocks/spike.tscn"), "Bloque de Pinchos", load("res://sprites/appeareances/smb/icons/terrain/spike.png"));
	configObject(APP_SMB, OBJ_PIPE, load("res://scenes/appearances/smb/blocks/pipe.tscn"), "Tubería", load("res://sprites/appeareances/smb/icons/terrain/pipe.png"));
	
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
	configObject(APP_SMB3, OBJ_FLOOR, load("res://scenes/appearances/smb3/blocks/floor.tscn"), "Piso", load("res://sprites/appeareances/smb3/icons/terrain/floor.png"));
	configObject(APP_SMB3, OBJ_BLOCK, load("res://scenes/appearances/smb3/blocks/block.tscn"), "Bloque", load("res://sprites/appeareances/smb3/icons/terrain/block.png"));
	configObject(APP_SMB3, OBJ_BRICK, load("res://scenes/appearances/smb3/blocks/brick.tscn"), "Ladrillo", load("res://sprites/appeareances/smb3/icons/terrain/brick.png"));
	configObject(APP_SMB3, OBJ_LUCKYBLOCK, load("res://scenes/appearances/smb3/blocks/luckyblock.tscn"), "Bloque ?", load("res://sprites/appeareances/smb3/icons/terrain/luckyblock.png"));
	configObject(APP_SMB3, OBJ_INVISIBLE_LUCKYBLOCK, load("res://scenes/appearances/smb3/blocks/invisible_luckyblock.tscn"), "Bloque ? Invisible", load("res://sprites/appeareances/smb3/icons/terrain/invisible_luckyblock.png"));
	configObject(APP_SMB3, OBJ_CLOUD, load("res://scenes/appearances/smb3/blocks/cloud.tscn"), "Bloque Nube", load("res://sprites/appeareances/smb3/icons/terrain/cloud.png"));
	configObject(APP_SMB3, OBJ_DONUT, load("res://scenes/appearances/smb3/blocks/donut.tscn"), "Dona", load("res://sprites/appeareances/smb3/icons/terrain/donut.png"));
	configObject(APP_SMB3, OBJ_SPIKE, load("res://scenes/appearances/smb3/blocks/spike.tscn"), "Bloque de Pinchos", load("res://sprites/appeareances/smb3/icons/terrain/spike.png"));
	configObject(APP_SMB3, OBJ_PIPE, load("res://scenes/appearances/smb3/blocks/pipe.tscn"), "Tubería", load("res://sprites/appeareances/smb3/icons/terrain/pipe.png"));
	
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
	var nodes = get_tree().get_nodes_in_group("Enemy");
	for node in nodes:
		node.set_process(true);
		node.set_physics_process(true);
		node.rendered = true;

func unrenderAll():
	var nodes = get_tree().get_nodes_in_group("Enemy");
	for node in nodes:
		if (!node.get_node("VisibilityEnabler2D").is_on_screen()):
			node.set_process(false);
			node.set_physics_process(false);

func _process(delta):
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

func showMessage(text, tree, realtree = null):
	var scene = preload("res://scenes/ui/messagebox.tscn");
	var inst = scene.instance();
	tree.add_child(inst);
	inst.setText(text);
	inst.realmenu = realtree;

func enterText(guidetext, type, tree, realtree = null):
	var scene = preload("res://scenes/ui/entertext.tscn");
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
				if (node.visible):
					node.changeInput();
			print("Input was changed to "+CurrentInput);
	if (event is InputEventJoypadButton || event is InputEventJoypadMotion):
		if (CurrentInput != "Gamepad"):
			CurrentInput = "Gamepad";
			var nodes = get_tree().get_nodes_in_group("CurrentTree");
			for node in nodes:
				if (node.visible):
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
