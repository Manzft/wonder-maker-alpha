extends Node2D

var editing = true;

var grid_size = Vector2(500, 35);
var grid = [];
var grid_node = [];

var globaloffset = Vector2(0, 0);
var offset = Vector2(26, 26);
var increase = 52;

var objSelected = -50;

var grab = false;
var grab_grid = Vector2();
var grab_node = null;
var grab_node_z_index = 0;
var grab_id = -1;
var grab_offset = Vector2();
var current_grab_grid = Vector2();

var camera_grid = Vector2(0, 0);
var camera_limit_grid = Vector2(0, 0);
var camera_last_pos = Vector2(0, 0);

var startmenu = false;

var freecam = false;

var emptyBlock = [null, null, null, null];
var gotCoin = [null, null, null, null];

var coinSparkle = [null, null, null, null];

var fireball = [null, null, null, null];

var partBrickBreak = [null, null, null, null];

var CamPosX = 0;

var seaLevelOffset = 0;
var seaTopLevelOffset = 0;
var currentSeaLevelOffset = 0;

#Sync Animation
var syncanim = {
	smb = {
		"luckyblock": 0.0,
		"spike": 0.0,
		"muncher": 0.0,
		"piranhaplant": 0.0,
		"coin": 0.0,
		"coin10": 0.0
	},
	smb3 = {
		"brick": 0.0,
		"attackTimer": 0.0
	}
}

func _ready():
	for i in range(grid_size.x): 
		grid.append([]);
		grid_node.append([]);
		for j in range(grid_size.y): 
			grid[i].append(0);
			grid_node[i].append(0);
		
	for i in range(grid_size.x):
		for j in range(grid_size.y):
			grid[i][j] = null;
			grid_node[i][j] = null;
	
	#Super Mario Bros | Objet Shortcuts
	emptyBlock[Global.APP_SMB] = load("res://scenes/appearances/smb/blocks/emptyblock.tscn");
	gotCoin[Global.APP_SMB] = load("res://scenes/appearances/smb/items/gotcoin.tscn");
	
	fireball[Global.APP_SMB] = load("res://scenes/appearances/smb/fireball.tscn");
	
	partBrickBreak[Global.APP_SMB] = load("res://scenes/appearances/smb/blocks/partbrickbreak.tscn");
	
	#Super Mario Bros 3 | Object Shortcuts
	emptyBlock[Global.APP_SMB3] = load("res://scenes/appearances/smb3/blocks/emptyblock.tscn");
	gotCoin[Global.APP_SMB3] = load("res://scenes/appearances/smb3/items/gotcoin.tscn");
	
	coinSparkle[Global.APP_SMB3] = load("res://scenes/appearances/smb3/partcoinsparkle.tscn");
	
	fireball[Global.APP_SMB3] = load("res://scenes/appearances/smb3/fireball.tscn");
	
	partBrickBreak[Global.APP_SMB3] = load("res://scenes/appearances/smb3/blocks/partbrickbreak.tscn");
	
	if (get_parent().get_name() == "MainMenu"):
		startmenu = true;
	
	#Start Menu Course Selection
	if (startmenu):
		var dir = Directory.new()
		var filecount = 0;
		var todir = Global.get_game_dir()+"/Courses";
		var file = ["", "", "", "", "", "", "", "", "", "", "", "", "", "", ""];
		var fileName = ["", "", "", "", "", "", "", "", "", "", "", "", "", "", ""];
		var fileselected = "";
		var filenameselected = "";
		if dir.open(todir) == OK:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					pass
					#print("Found directory: " + file_name)
				else:
					#print("Found file: " + file_name)
					if (filecount <= 14):
						if (file_name.get_extension() == "wom"):
								file[filecount] = Global.get_game_dir()+"/Courses/"+file_name;
								fileName[filecount] = file_name.trim_suffix(".wom");
								filecount += 1;
				file_name = dir.get_next()
				
			if (filecount > 0):
				randomize();
				var ir = round(rand_range(0, filecount-1));
				for i in range(filecount):
					if (i == ir):
						fileselected = file[i];
						filenameselected = fileName[i];
			if (fileselected != ""):
				Global.currentlevel = fileselected;
				Global.currentCourseName = filenameselected;
				Global.toLoad = true;
			else:
				Global.currentlevel = "res://title level.wom"
				Global.currentCourseName = "Title Level";
				Global.toLoad = true;
	
	#yield(get_tree(), "idle_frame");
	setCameraGrid();

	if (Global.coursePlaying || startmenu):
		Global.transition(self);
		$Editor.hide();
		$Editor/SideMenu.hide();

func enemyScore(position: Vector2):
	match str(get_node("Character").lastScore):
		"0": get_node("Character").lastScore = 200;
		"200": get_node("Character").lastScore = 400;
		"400": get_node("Character").lastScore = 800;
		"800": get_node("Character").lastScore = 1000;
		"1000": get_node("Character").lastScore = 2000;
		"2000": get_node("Character").lastScore = 4000;
		"4000": get_node("Character").lastScore = 8000;
		"8000": get_node("Character").lastScore = -1;
	
	var app = "smb";
	match (Global.CurrentAppeareance):
		Global.APP_SMB:
			app = "smb";
		Global.APP_SMB3:
			app = "smb3";
	
	if (get_node("Character").lastScore == -1):
		get_node("Character").get_node("1up").play();
		var inst = load("res://scenes/appearances/"+app+"/Score.tscn").instance();
		add_child(inst);
		inst.position = position;
		inst.position.y -= 26
		inst.position.x += 26
		if (app == "smb"):
			inst.get_node("Text").text = "1UP";
		else:
			inst.get_node("Text").hide();
			inst.get_node("1UP").show();
	else:
		var inst = load("res://scenes/appearances/"+app+"/Score.tscn").instance();
		add_child(inst);
		inst.position = position;
		inst.position.y -= 26
		inst.position.x += 26
		inst.get_node("Text").text = str(get_node("Character").lastScore);
		get_node("Editor").Score += get_node("Character").lastScore;

func setCameraGrid(var start = false):
	var check = start;
	var campos = get_node("Camera2D").position;
	if (campos.x >= camera_last_pos.x+26 || campos.x <= camera_last_pos.x-26): check = true;
	if (campos.y >= camera_last_pos.y+26 || campos.y <= camera_last_pos.y-26): check = true;
	
	if (check):
		camera_grid = calculateGrid(campos.x, campos.y);
		camera_limit_grid = calculateGrid(campos.x+get_node("Editor/SectionTop").rect_size.x, campos.y+get_node("Editor/SectionRightContainer").rect_size.y);
		
		camera_grid.x -= 7;
		if (camera_grid.x < 0):
			camera_grid.x = 0;
		
		camera_limit_grid.x += 7;
		if (camera_limit_grid.x > grid_size.x-1):
			camera_limit_grid.x = grid_size.x;
		
		camera_grid.y -= 7;
		if (camera_grid.y < 0): camera_grid.x = 0;
		camera_limit_grid.y += 7;
		if (camera_limit_grid.y > grid_size.y-1): camera_limit_grid.y = grid_size.y;
		
		camera_last_pos = campos;

func _process(delta):
	$ShadowLayer.visible = Global.SHADOWS;
	syncSMBSprites(delta);
	syncSMB3Sprites(delta);
	#Water and Lava Showing
	get_node("Camera2D/SMB3/Water").hide();
	get_node("Camera2D/SMB/Water").hide();
	var app = "SMB";
	match (Global.CurrentAppeareance):
		Global.APP_SMB:
			app = "SMB";
		Global.APP_SMB3:
			app = "SMB3";
	if (Global.CurrentStyle == "Forest"):
		get_node("Camera2D/"+app+"/Water").show();
		get_node("Camera2D/"+app+"/Water").offset.y = seaLevelOffset;
		currentSeaLevelOffset = 0;	
	
	if ($Editor.playing):
		$GameUI.show();
		
		get_node("Camera2D/SMB/Water").offset.y = seaLevelOffset-currentSeaLevelOffset;
		
		#InGame Character Camera
		var charpos = get_node("Character").position-get_node("Camera2D").position;
		
		var campos = Vector2($Editor/GamepadCursorDefaultPosition.rect_position.x, $Editor/GamepadCursorDefaultPosition.rect_position.y);
		if (Global.CurrentSpeed == "None"):
			get_node("Camera2D").position.x = lerp(get_node("Camera2D").position.x, get_node("Character").position.x-campos.x, 0.25);
		else:
			match (Global.CurrentSpeed):
				"Slow":
					get_node("Camera2D").position.x += 78.125*delta;
				"Normal":
					get_node("Camera2D").position.x += 156.25*delta;
				"Fast":
					get_node("Camera2D").position.x += 218.75*delta;
					
			if (get_node("Character").position.x-20 < get_node("Camera2D").position.x):
				get_node("Character").position.x = get_node("Camera2D").position.x+20;
				#get_node("Character").motion.x = 0;
			
		
		#if (get_node("Character").position.y < 840-52-52):
		if (freecam):
			get_node("Camera2D").position.y = lerp(get_node("Camera2D").position.y, get_node("Character").position.y-campos.y, 0.0625);
		else:
			get_node("Camera2D").position.y = lerp(get_node("Camera2D").position.y, 840, 0.0625);
		
		if (get_node("Camera2D").position.y < 0): get_node("Camera2D").position.y = 0;
		if (get_node("Camera2D").position.x < 0): get_node("Camera2D").position.x = 0;
		if (get_node("Camera2D").position.y > 840): get_node("Camera2D").position.y = 840;
		var px = get_node("EndFloor").position.x+(52*9)-26-get_node("Editor/SectionTop").rect_size.x;
		if (get_node("Camera2D").position.x > px): get_node("Camera2D").position.x = px;
		
		if (get_node("Character").position.x-24 < 0):
			get_node("Character").position.x = 24;
			get_node("Character").motion.x = 0;
			
		if (get_node("Character").position.x > get_node("EndFloor").position.x+(52*9)-52 && !get_node("Character").course_clear):
			get_node("Character").position.x = get_node("EndFloor").position.x+(52*9)-52;
			get_node("Character").motion.x = 0;
	else:
		$GameUI.hide();
		
		setCameraGrid();
		$Camera2D.offset.x = abs($Editor.offset.x);
	Global.campos = get_node("Camera2D").position;
		
	#Pause Menu
	if (Global.coursePlaying):
		if (Input.is_action_just_pressed("start") && !get_node("Character").died && !get_node("Character").changingPowerup):
			var inst = load("res://scenes/ui/pausemenu.tscn").instance();
			add_child(inst);

#Deprecated function
func calculateGlobalGrid(ex, ey):
	var finded = false;
	for i in range(grid_size.x):
		for j in range(grid_size.y):
			if (!finded):
				var center = Vector2(offset.x+(increase*i), offset.y+(increase*j));
				center += globaloffset;
				if (ex >= center.x-(increase/2) && ex <= center.x+(increase/2)):
					if (ey >= center.y-(increase/2) && ey <= center.y+(increase/2)):
						finded = true;
						return Vector2(i, j);
						#return Vector2(center.x, center.y);
			if (finded):
				break;
	if (!finded):
		return null;

func calculateGrid(ex, ey):
	var rx = floor(ex/increase);
	var ry = floor(ey/increase);
	return Vector2(rx, ry);

func calculateGridPosition(cgrid):
	var center = Vector2(offset.x+(increase*cgrid.x), offset.y+(increase*cgrid.y));
	return center;

func placeObject(mousepos, pressed = false, customObj = -1, sound : bool = true, inEditor : bool = true, inst : Node = null):
	if (get_node("Editor").externalButton):
		return
	if (inEditor):
		yield(get_tree(), "idle_frame");
	if (!$LevelFloor.selected && !$CharacterEditor.selected && !$CharacterEditor.mouse_selected && !$EndFloor.selected):
		var cgrid = calculateGrid(mousepos.x, mousepos.y);
		
		var poscheck = true;
		if (inEditor):
			if (cgrid.x <= 6): 
				if (cgrid.y >= get_node("LevelFloor").current_grid.y):
					poscheck = false;
			if (cgrid.x >= get_node("EndFloor").current_grid.x-1):
				if (cgrid.y >= get_node("EndFloor").current_grid.y):
					poscheck = false;
		
		if (cgrid != null && poscheck):
			if (grid[cgrid.x][cgrid.y] == null && grid_node[cgrid.x][cgrid.y] == null):
				if (objSelected > -50 || customObj != -1):
					var pos = calculateGridPosition(cgrid);
					var obj = objSelected;
					if (customObj != -1): obj = customObj;
					var scene = Global.object[Global.CurrentAppeareance][obj][Global.OP_SCENE];
					if (inst == null):
						inst = scene.instance();
					
					#Remove Wide Decoration
					var nodegrid = cgrid;
					if (grid[nodegrid.x][nodegrid.y+1] == Global.OBJ_FLOOR):
						if (grid_node[nodegrid.x][nodegrid.y+1].decorationType == "Wide"):
							grid_node[nodegrid.x][nodegrid.y+1].quitAllDecoration();
					if (grid[nodegrid.x+1][nodegrid.y+1] == Global.OBJ_FLOOR):
						if (grid_node[nodegrid.x+1][nodegrid.y+1].decorationType == "Wide"):
							grid_node[nodegrid.x+1][nodegrid.y+1].quitAllDecoration();
					if (grid[nodegrid.x+2][nodegrid.y+1] == Global.OBJ_FLOOR):
						if (grid_node[nodegrid.x+2][nodegrid.y+1].decorationType == "Wide"):
							grid_node[nodegrid.x+2][nodegrid.y+1].quitAllDecoration();
					
					if (grid[nodegrid.x][nodegrid.y+1] == Global.OBJ_FLOOR):
						if (grid_node[nodegrid.x][nodegrid.y+1].decorationType == "Short"):
							grid_node[nodegrid.x][nodegrid.y+1].quitAllDecoration();
					if (grid[nodegrid.x][nodegrid.y+2] == Global.OBJ_FLOOR):
						if (grid_node[nodegrid.x][nodegrid.y+2].decorationType == "Short"):
							grid_node[nodegrid.x][nodegrid.y+2].quitAllDecoration();
					
					if (grid[nodegrid.x][nodegrid.y+1] == Global.OBJ_FLOOR):
						if (grid_node[nodegrid.x][nodegrid.y+1].decorationType == "Tall"):
							grid_node[nodegrid.x][nodegrid.y+1].quitAllDecoration();
					if (grid[nodegrid.x][nodegrid.y+2] == Global.OBJ_FLOOR):
						if (grid_node[nodegrid.x][nodegrid.y+2].decorationType == "Tall"):
							grid_node[nodegrid.x][nodegrid.y+2].quitAllDecoration();
					if (grid[nodegrid.x][nodegrid.y+3] == Global.OBJ_FLOOR):
						if (grid_node[nodegrid.x][nodegrid.y+3].decorationType == "Tall"):
							grid_node[nodegrid.x][nodegrid.y+3].quitAllDecoration();
					
					add_child(inst);
					inst.position = pos;
					inst.add_to_group(str(obj))
					if (obj == Global.OBJ_FLOOR && inEditor):
						inst.editPlaced = true;
					
					if (inst.is_in_group("Extensible")):
						yield(get_tree(), "idle_frame");
						var a = inst.setupExtensionGrids(true);
						if (!a):
							return;
						inst.setGrids(obj);
					
					grid[cgrid.x][cgrid.y] = obj;
					grid_node[cgrid.x][cgrid.y] = inst;
					
					if (sound):
						if (!$AudioPlaceObject.playing):
							$AudioPlaceObject.pitch_scale = rand_range(0.8, 1.2);
							$AudioPlaceObject.play();
						elif (!$AudioPlaceObject2.playing):
							$AudioPlaceObject2.pitch_scale = rand_range(0.8, 1.2);
							$AudioPlaceObject2.play();
			else:
				var check = true;
				
				var pos = calculateGridPosition(cgrid);
				var nodes = get_tree().get_nodes_in_group("Obj");
				var n = null;
				for node in nodes:
					if (grid_node[cgrid.x][cgrid.y] == node):
						n = node;
						if (node.is_in_group("Floor")):
							check = false;
				
				if (!grab && pressed && check && n != null):
					$Editor/TypeMenuTimer.start();
					$Editor.resetTypeMenu();
					
					grab = true;
					var inst2 = load("res://scenes/ui/selection.tscn").instance();
					add_child(inst2);
					grab_grid = cgrid;
					grab_id = grid[cgrid.x][cgrid.y];
					
					if (n.is_in_group("Extensible")):
						var grid_origin = n.grid_origin;
						for i in range(n.grid_end.x+1+(abs(grid_origin.x))):
							for j in range(n.grid_end.y+1+(abs(grid_origin.y))):
								if (Vector2(i, j) != grid_origin*-1):
									inst2.generateAdditional(Vector2(i+grid_origin.x, j+grid_origin.y));
						grab_grid = calculateGrid(n.position.x, n.position.y);
						grab_id = grid[grab_grid.x][grab_grid.y];
					
					grab_node = n;
					grab_node_z_index = n.z_index;
					grab_offset = mousepos-n.position;
					n.z_index = 10;
					
					current_grab_grid = cgrid;
					
					var part = load("res://scenes/ui/partgrab.tscn").instance();
					part.position = pos;
					add_child(part);
					
					if (!$Editor/AudioGrab.playing):
						$Editor/AudioGrab.pitch_scale = rand_range(0.8, 1.2);
						$Editor/AudioGrab.play();

func eraseObject(mousepos, sound = true, hide = false, editMode: bool =  true):
	var cgrid = calculateGrid(mousepos.x, mousepos.y);
	if (cgrid != null):
		if (grid[cgrid.x][cgrid.y] != null):
			var notfloorlevel = true;
			var pos = mousepos;
			var node = grid_node[cgrid.x][cgrid.y];
			get_node("Editor").externalButton = false;
			if (node.is_in_group("Floor")):
				if (node.floorlevel || node.endlevel):
					notfloorlevel = false;
			if (notfloorlevel):
				if (hide):
					node.hide();
				else:
					var nodegrid = calculateGrid(node.position.x, node.position.y);
					var isfloor = false;
					
					#Remove Wide Decoration
					if (grid[nodegrid.x][nodegrid.y] == Global.OBJ_FLOOR && editMode):
						isfloor = true;
						if (grid[nodegrid.x+1][nodegrid.y] == Global.OBJ_FLOOR):
							if (grid_node[nodegrid.x+1][nodegrid.y].decorationType == "Wide"):
								grid_node[nodegrid.x+1][nodegrid.y].quitAllDecoration();
						if (grid[nodegrid.x+2][nodegrid.y] == Global.OBJ_FLOOR):
							if (grid_node[nodegrid.x+2][nodegrid.y].decorationType == "Wide"):
								grid_node[nodegrid.x+2][nodegrid.y].quitAllDecoration();
					
					grid[nodegrid.x][nodegrid.y] = null;
					grid_node[nodegrid.x][nodegrid.y] = null;
					if (node.has_method("eraseShadow")):
						node.eraseShadow();
					
					if (node.is_in_group("Extensible")):
						for i in range(node.grid_end.x+1+(abs(node.grid_origin.x))):
							for j in range(node.grid_end.y+1+(abs(node.grid_origin.y))):
								if (Vector2(i, j) != node.grid_origin*-1):
									grid[nodegrid.x+i+node.grid_origin.x][nodegrid.y+j+node.grid_origin.y] = null;
									grid_node[nodegrid.x+i+node.grid_origin.x][nodegrid.y+j+node.grid_origin.y] = null;
					
					if (isfloor):
						node.updateNearFloors();
					
					node.queue_free();
				
				if (sound):
					if (!$AudioEraseObject.playing):
						$AudioEraseObject.pitch_scale = rand_range(0.8, 1.2);
						$AudioEraseObject.play();

func gameMusic(a):
	var nodes = get_tree().get_nodes_in_group("Music");
	for node in nodes:
		node.stop();
	
	var music = null;
	match (Global.CurrentAppeareance):
		Global.APP_SMB:
			music = get_node("GameMusic/SMB/"+Global.CurrentStyle);
		Global.APP_SMB3:
			music = get_node("GameMusic/SMB3/"+Global.CurrentStyle);
	
	print("Style: "+Global.CurrentStyle)
	
	if (a):
		music.play();
	else:
		music.stop();

func reset():
	Global.emit_signal("erase");
	return
	for i in range(grid_size.x):
		for j in range(grid_size.y):
			if (grid[i][j] != null || grid_node[i][j] != null):
				var notfloorlevel = true;
				var pos = calculateGridPosition(Vector2(i, j));
				var nodes = get_tree().get_nodes_in_group("Obj");
				for node in nodes:
					notfloorlevel = true;
					if (grid_node[i][j] == node):
						if (node.is_in_group("Floor")):
							if (node.floorlevel || node.endlevel):
								notfloorlevel = false;
						if (notfloorlevel):
							var nodegrid = calculateGrid(node.position.x, node.position.y);
							grid[nodegrid.x][nodegrid.y] = null;
							grid_node[nodegrid.x][nodegrid.y] = null;
							
							if (node.is_in_group("Extensible")):
								for g in node.extension_grid:
									if (g != null):
										grid[g.x][g.y] = null;
										grid_node[g.x][g.y] = null;
								
							node.queue_free();

func change_editmode():
	if (editing):
		editing = false;
		$TileMap.hide();
	else:
		editing = true;
		$TileMap.show();

func setStyleBackground():
	var bg = null;
	match (Global.CurrentAppeareance):
		Global.APP_SMB:
			bg = get_node("Camera2D/SMB/"+Global.CurrentStyle);
		Global.APP_SMB3:
			bg = get_node("Camera2D/SMB3/"+Global.CurrentStyle);
	
	var nodes = get_tree().get_nodes_in_group("Background");
	for node in nodes:
		if (node.get_name() != "Water" && node.get_name() != "Lava"):
			node.hide();
	
	bg.show();

func syncSMBSprites(delta):
	var divider = (1/delta)/10.0;
	syncanim.smb.luckyblock += 1.0/divider;
	if (syncanim.smb.luckyblock>= 4):
		syncanim.smb.luckyblock = 0.0;
	
	divider = (1/delta)/5.0;
	syncanim.smb.spike += 1.0/divider;
	if (syncanim.smb.spike >= 2):
		syncanim.smb.spike = 0.0;
		divider = 60.0/5.0;
	
	syncanim.smb.muncher += 1.0/divider;
	if (syncanim.smb.muncher >= 2):
		syncanim.smb.muncher = 0.0;
	
	syncanim.smb.piranhaplant += 1.0/divider;
	if (syncanim.smb.piranhaplant >= 2):
		syncanim.smb.piranhaplant = 0.0;
	
	divider = (1/delta)/10.0;
	syncanim.smb.coin += 1.0/divider;
	if (syncanim.smb.coin > 4):
		syncanim.smb.coin = 0.0;
	
	divider = (1/delta)/7.0;
	syncanim.smb.coin10 += 1.0/divider;
	if (syncanim.smb.coin10 > 4):
		syncanim.smb.coin10 = 0.0;

func syncSMB3Sprites(delta):
	var divider = (1/delta)/10.0;
	syncanim.smb3.brick += 1.0/divider;
	if (syncanim.smb3.brick >= 4):
		syncanim.smb3.brick = 0.0;
		
	syncanim.smb3.attackTimer += delta;
	
	if (syncanim.smb3.attackTimer >= 4.8): syncanim.smb3.attackTimer = 0.0;
