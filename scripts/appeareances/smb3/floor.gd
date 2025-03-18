extends StaticBody2D

var floorlevel = false;
var endlevel = false;

onready var currentSprite = get_node("SpriteGround");
onready var subCurrentSprite = get_node("SpriteGround/Sprite");

var hasDecoration = false;
var editPlaced = false;
var decorationType = "";

var mygrid = Vector2();

var shadow : Sprite;
var shadowdecoration : Sprite

var pr;
var levelFloorGrid : Vector2
var endFloorGrid : Vector2

var defaultFrameCoords : Vector2 = Vector2(-1, -1)
var defaultFalseUp : bool = false
var defaultFalseUp2 : bool = false
var defaultFalseCenter : bool = false
var defaultFalseCenter2 : bool = false

func render(group, forcerender = false, render_range = 60):
	if (forcerender):
		set_process(true);
		set_physics_process(true);
		return
	if (group != ""):
		if (!is_in_group(group)):
			return
	var scrwidth = OS.get_window_size().x;
	var scrheight = OS.get_window_size().y;
	var multiplier = 720/scrheight;
	var finalscrwidth = scrwidth * multiplier;
	var distance = abs(position.x-Global.campos.x);
	if (distance-(finalscrwidth/2) > finalscrwidth*(render_range*0.01)):
		set_process(false);
		set_physics_process(false);
	else:
		set_process(true);
		set_physics_process(true);

func floorErase():
	var delete = false;
	if (get_parent().calculateGrid(position.x, position.y).x <= 6):
		if (get_parent().calculateGrid(position.x, position.y).y >= get_node("../LevelFloor").current_grid.y):
			delete = true;
	if (get_parent().calculateGrid(position.x, position.y).x >= get_node("../EndFloor").current_grid.x-1):
		if (get_parent().calculateGrid(position.x, position.y).y >= get_node("../EndFloor").current_grid.y):
			delete = true;

	if (delete):
		get_parent().eraseObject(position, false);

func erase():
	get_parent().eraseObject(position, false);

func changeStyle():
	var pos = position;
	var grid = get_parent().calculateGrid(pos.x, pos.y);
	var obj = get_parent().grid[grid.x][grid.y];
	var scene = Global.object[Global.CurrentAppeareance][obj][Global.OP_SCENE];
	var inst = scene.instance();
	get_parent().grid_node[grid.x][grid.y] = inst;
	get_parent().add_child(inst);
	inst.position = pos;
	queue_free();

func eraseShadow():
	shadow.queue_free();
	shadowdecoration.queue_free();

func _ready():
	pr = get_parent();
	Global.connect("render", self, "render");
	Global.connect("floorErase", self, "floorErase");
	Global.connect("changeStyle", self, "changeStyle");
	Global.connect("erase", self, "erase");
	get_node("../LevelFloor").connect("levelFloorChanged", self, "levelFloorChanged");
	get_node("../EndFloor").connect("endFloorChanged", self, "endFloorChanged");
	yield(get_tree(), "idle_frame");
	if (get_parent().editing && !floorlevel && !endlevel):
		$AnimationPlayer.play("start");
	mygrid = get_parent().calculateGrid(position.x, position.y);
	
	styleChanged();
	updateNearFloors();
	if (editPlaced):
		spawnDecoration();
	else:
		setDecoration()
	editPlaced = true;

func spawnDecoration():
	var i = str(round(rand_range(0, 20)));
	var text = "";
	match (i):
		"0":
			var mygrid = get_parent().calculateGrid(position.x, position.y);
			if (isNotSolidOrDoesntExists(Vector2(mygrid.x, mygrid.y-1)) && isNotSolidOrDoesntExists(Vector2(mygrid.x, mygrid.y-2)) && isNotSolidOrDoesntExists(Vector2(mygrid.x, mygrid.y-3))):
				get_node(Global.CurrentStyle+"/DecorationTall").show();
				decorationType = "Tall";
				hasDecoration = true;
				if (editPlaced):
					$SoundSpawnDecoration.play();
		"1":
			var mygrid = get_parent().calculateGrid(position.x, position.y);
			if (isNotSolidOrDoesntExists(Vector2(mygrid.x, mygrid.y-1)) && isNotSolidOrDoesntExists(Vector2(mygrid.x, mygrid.y-2))):
				get_node(Global.CurrentStyle+"/DecorationShort").show();
				decorationType = "Short";
				hasDecoration = true;
				if (editPlaced):
					$SoundSpawnDecoration.play();
		"2":
			var mygrid = get_parent().calculateGrid(position.x, position.y);
			if (isNotSolidOrDoesntExists(Vector2(mygrid.x, mygrid.y-1)) && isNotSolidOrDoesntExists(Vector2(mygrid.x-1, mygrid.y-1)) && isNotSolidOrDoesntExists(Vector2(mygrid.x-2, mygrid.y-1))):
				if (get_node("../").grid[mygrid.x-1][mygrid.y] == Global.OBJ_FLOOR && get_node("../").grid[mygrid.x-2][mygrid.y] == Global.OBJ_FLOOR):
					if (!get_node("../").grid_node[mygrid.x-1][mygrid.y].hasDecoration && !get_node("../").grid_node[mygrid.x-2][mygrid.y].hasDecoration):
						get_node(Global.CurrentStyle+"/DecorationWide").show();
						decorationType = "Wide";
						hasDecoration = true;
						if (editPlaced):
							$SoundSpawnDecoration.play();

func setDecoration():
	match (decorationType):
		"Tall":
			get_node(Global.CurrentStyle+"/DecorationTall").show();
			decorationType = "Tall";
			hasDecoration = true;
		"Short":
			get_node(Global.CurrentStyle+"/DecorationShort").show();
			decorationType = "Short";
			hasDecoration = true
		"Wide":
			get_node(Global.CurrentStyle+"/DecorationWide").show();
			decorationType = "Wide";
			hasDecoration = true

func updateNearFloors():
	var mygrid = get_parent().calculateGrid(position.x, position.y);
	var x = mygrid.x;
	var y = mygrid.y;
	var pr = get_parent();
	if (pr.grid[x-1][y] == Global.OBJ_FLOOR): pr.grid_node[x-1][y].styleChanged();
	if (pr.grid[x+1][y] == Global.OBJ_FLOOR): pr.grid_node[x+1][y].styleChanged();
	if (pr.grid[x][y+1] == Global.OBJ_FLOOR): pr.grid_node[x][y+1].styleChanged();
	if (pr.grid[x][y-1] == Global.OBJ_FLOOR): pr.grid_node[x][y-1].styleChanged();
	if (pr.grid[x-1][y-1] == Global.OBJ_FLOOR): pr.grid_node[x-1][y-1].styleChanged();
	if (pr.grid[x+1][y-1] == Global.OBJ_FLOOR): pr.grid_node[x+1][y-1].styleChanged();
	if (pr.grid[x-1][y+1] == Global.OBJ_FLOOR): pr.grid_node[x-1][y+1].styleChanged();
	if (pr.grid[x+1][y+1] == Global.OBJ_FLOOR): pr.grid_node[x+1][y+1].styleChanged();

func isNotSolidOrDoesntExists(mygrid = Vector2()):
	var check = (get_node("../").grid_node[mygrid.x][mygrid.y] == null);
	var check2 = false;
	if (!check):
		check2 = (!get_node("../").grid_node[mygrid.x][mygrid.y].is_in_group("Solid"));
	var finalcheck = (check || check2);
	return finalcheck;

func quitAllDecoration():
	get_node(Global.CurrentStyle+"/DecorationTall").hide();
	get_node(Global.CurrentStyle+"/DecorationShort").hide();
	get_node(Global.CurrentStyle+"/DecorationWide").hide();
	
	hasDecoration = false;
	decorationType = "";

func swapDecorationStyle(previousStyle):
	var vis1 = get_node(previousStyle+"/DecorationTall").visible;
	var vis2 = get_node(previousStyle+"/DecorationShort").visible;
	var vis3 = get_node(previousStyle+"/DecorationWide").visible;
	
	get_node(previousStyle+"/DecorationTall").hide();
	get_node(previousStyle+"/DecorationShort").hide();
	get_node(previousStyle+"/DecorationWide").hide();
	
	get_node(Global.CurrentStyle+"/DecorationTall").visible = vis1;
	get_node(Global.CurrentStyle+"/DecorationShort").visible = vis2;
	get_node(Global.CurrentStyle+"/DecorationWide").visible = vis3;

func hideShadows():
	var currentsprite = "Sprite"+Global.CurrentStyle;
	get_node(currentsprite+"/Shadow").hide();
	get_node(currentsprite+"/ShadowFull").hide();
	get_node(currentsprite+"/ShadowDownLeft").hide();
	get_node(currentsprite+"/ShadowDownRight").hide();
	get_node(currentsprite+"/ShadowUpRight").hide();
	get_node(currentsprite+"/ShadowRightAlone").hide();
	get_node(currentsprite+"/ShadowDownAlone").hide();

func hideFalse():
	var currentsprite = "Sprite"+Global.CurrentStyle;
	get_node(currentsprite+"/FalseUp").hide(); get_node(currentsprite+"/FalseUp2").hide();
	get_node(currentsprite+"/FalseCenter").hide(); get_node(currentsprite+"/FalseCenter2").hide();

func checkFloor(x, y):
	var grid = Vector2(x, y);
	
	var check = false;
	
	if (pr.grid[grid.x][grid.y] == Global.OBJ_FLOOR):
		check = true;
	
	if (grid.x >= 0 && grid.x <= levelFloorGrid.x):
		if (grid.y >= levelFloorGrid.y):
			check = true;
	
	if (grid.x >= endFloorGrid.x-1 && grid.x <= endFloorGrid.x+9):
		if (grid.y >= endFloorGrid.y):
			check = true;
			
	if (grid.y == 30):
		check = true;
	
	return check;

func _process(_delta):
	if (shadow != null):
		shadow.position = currentSprite.get_node("Sprite").global_position+Vector2(3*3.25, 3*3.25);
		shadow.frame = currentSprite.get_node("Sprite").frame;
	if (shadowdecoration != null && decorationType != ""):
		shadowdecoration.show();
		var node = Global.CurrentStyle+"/Decoration"+decorationType;
		shadowdecoration.position = get_node(node).global_position+Vector2(3*3.25, 3*3.25);
		shadowdecoration.texture = get_node(node).texture;
	elif (shadowdecoration != null):
		shadowdecoration.hide();

func styleChanged():
	swapDecorationStyle(currentSprite.get_name().trim_prefix("Sprite").trim_suffix("Variant").trim_suffix("Top"));
	match (Global.CurrentStyle):
		"Underground":
			currentSprite.hide();
			currentSprite = get_node("SpriteUnderground");
			currentSprite.show();
		"Ghosthouse":
			currentSprite.hide();
			currentSprite = get_node("SpriteUnderground");
			currentSprite.show();
		"Ghostforest":
			currentSprite.hide();
			currentSprite = get_node("SpriteGhostforest");
			currentSprite.show();
		"Sky":
			currentSprite.hide();
			currentSprite = get_node("SpriteSky");
			currentSprite.show();
		"Forest":
			currentSprite.hide();
			currentSprite = get_node("SpriteForest");
			currentSprite.show();
		"Snow":
			currentSprite.hide();
			currentSprite = get_node("SpriteSnow");
			currentSprite.show();
		"Desert":
			currentSprite.hide();
			currentSprite = get_node("SpriteDesert");
			currentSprite.show();
		_:
			currentSprite.hide();
			currentSprite = get_node("SpriteGround");
			currentSprite.show();
			
	hideFalse();
	var currentsprite = "Sprite"+Global.CurrentStyle;
	if (editPlaced || defaultFrameCoords == Vector2(-1, -1)):
		levelFloorGrid = pr.calculateGrid(get_node("../LevelFloor").position.x, get_node("../LevelFloor").position.y);
		endFloorGrid = pr.calculateGrid(get_node("../EndFloor").position.x, get_node("../EndFloor").position.y);
		var mygrid = get_parent().calculateGrid(position.x, position.y);
		
		#MAIN COMBINATIONS
		#Up
		if (checkFloor(mygrid.x-1, mygrid.y)
		&& checkFloor(mygrid.x+1, mygrid.y)
		&& !checkFloor(mygrid.x, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y+1)):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(3, 0);
		#Up Left
		elif (!checkFloor(mygrid.x-1, mygrid.y)
		&& checkFloor(mygrid.x+1, mygrid.y)
		&& !checkFloor(mygrid.x, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y+1)):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(2, 0);
		#Up Right
		elif (checkFloor(mygrid.x-1, mygrid.y)
		&& !checkFloor(mygrid.x+1, mygrid.y)
		&& !checkFloor(mygrid.x, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y+1)):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(4, 0);
		#Center
		elif (checkFloor(mygrid.x-1, mygrid.y)
		&& checkFloor(mygrid.x+1, mygrid.y)
		&& checkFloor(mygrid.x, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y+1)):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(3, 1);
		#Left
		elif (!checkFloor(mygrid.x-1, mygrid.y)
		&& checkFloor(mygrid.x+1, mygrid.y)
		&& checkFloor(mygrid.x, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y+1)):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(2, 1);
		#Right
		elif (checkFloor(mygrid.x-1, mygrid.y)
		&& !checkFloor(mygrid.x+1, mygrid.y)
		&& checkFloor(mygrid.x, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y+1)):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(4, 1);
		#Down
		elif (checkFloor(mygrid.x-1, mygrid.y)
		&& checkFloor(mygrid.x+1, mygrid.y)
		&& checkFloor(mygrid.x, mygrid.y-1)
		&& !checkFloor(mygrid.x, mygrid.y+1)):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(3, 2);
		#Down Left
		elif (!checkFloor(mygrid.x-1, mygrid.y)
		&& checkFloor(mygrid.x+1, mygrid.y)
		&& checkFloor(mygrid.x, mygrid.y-1)
		&& !checkFloor(mygrid.x, mygrid.y+1)):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(2, 2);
		#Down Right
		elif (checkFloor(mygrid.x-1, mygrid.y)
		&& !checkFloor(mygrid.x+1, mygrid.y)
		&& checkFloor(mygrid.x, mygrid.y-1)
		&& !checkFloor(mygrid.x, mygrid.y+1)):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(4, 2);
		#Left Alone
		elif (!checkFloor(mygrid.x-1, mygrid.y)
		&& checkFloor(mygrid.x+1, mygrid.y)
		&& !checkFloor(mygrid.x, mygrid.y-1)
		&& !checkFloor(mygrid.x, mygrid.y+1)):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(0, 3);
		#Right Alone
		elif (checkFloor(mygrid.x-1, mygrid.y)
		&& !checkFloor(mygrid.x+1, mygrid.y)
		&& !checkFloor(mygrid.x, mygrid.y-1)
		&& !checkFloor(mygrid.x, mygrid.y+1)):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(2, 3);
		#Down Alone
		elif (!checkFloor(mygrid.x-1, mygrid.y)
		&& !checkFloor(mygrid.x+1, mygrid.y)
		&& checkFloor(mygrid.x, mygrid.y-1)
		&& !checkFloor(mygrid.x, mygrid.y+1)):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(1, 2);
		#Up Alone
		elif (!checkFloor(mygrid.x-1, mygrid.y)
		&& !checkFloor(mygrid.x+1, mygrid.y)
		&& !checkFloor(mygrid.x, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y+1)):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(1, 0);
		#Horizontal Alone
		elif (checkFloor(mygrid.x-1, mygrid.y)
		&& checkFloor(mygrid.x+1, mygrid.y)
		&& !checkFloor(mygrid.x, mygrid.y-1)
		&& !checkFloor(mygrid.x, mygrid.y+1)):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(1, 3);
		#Vertical Alone
		elif (!checkFloor(mygrid.x-1, mygrid.y)
		&& !checkFloor(mygrid.x+1, mygrid.y)
		&& checkFloor(mygrid.x, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y+1)):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(1, 1);
		#Center Alone
		else:
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(0, 0);
		
		#SPECIFIC COMBINATIONS
		
		#  $
		# $O$
		#  $
		if (checkFloor(mygrid.x-1, mygrid.y) && !checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y) && !checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1) && !checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1) && !checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(1, 5);
			
		# $
		# O$
		# $
		if (!checkFloor(mygrid.x-1, mygrid.y)# && !checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y) && !checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1)# && !checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1) && !checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(5, 1);
		
		#  $
		# $O
		#  $
		if (checkFloor(mygrid.x-1, mygrid.y) && !checkFloor(mygrid.x-1, mygrid.y-1)
		&& !checkFloor(mygrid.x+1, mygrid.y)# && !checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1) && !checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1)# && !checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(8, 1);
			
		#  $
		# $O
		#  
		if (checkFloor(mygrid.x-1, mygrid.y) && !checkFloor(mygrid.x-1, mygrid.y-1)
		&& !checkFloor(mygrid.x+1, mygrid.y)# && !checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1)# && !checkFloor(mygrid.x-1, mygrid.y+1)
		&& !checkFloor(mygrid.x, mygrid.y+1)# && !checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(10, 1);
		
		#  $
		#  O$
		#  
		if (!checkFloor(mygrid.x-1, mygrid.y)# && !checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y) && !checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1)# && !checkFloor(mygrid.x-1, mygrid.y+1)
		&& !checkFloor(mygrid.x, mygrid.y+1)# && !checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(11, 1);
		
		#  $O
		#   $
		#  
		if (checkFloor(mygrid.x-1, mygrid.y)# && !checkFloor(mygrid.x-1, mygrid.y-1)
		&& !checkFloor(mygrid.x+1, mygrid.y)# && !checkFloor(mygrid.x+1, mygrid.y-1)
		&& !checkFloor(mygrid.x, mygrid.y-1) && !checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1)# && !checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(10, 2);
		
		#  O$
		#  $
		#  
		if (!checkFloor(mygrid.x-1, mygrid.y)# && !checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y)# && !checkFloor(mygrid.x+1, mygrid.y-1)
		&& !checkFloor(mygrid.x, mygrid.y-1)# && !checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1) && !checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(11, 2);
			
		#  
		# $O$
		#  $
		if (checkFloor(mygrid.x-1, mygrid.y)# && !checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y)# && !checkFloor(mygrid.x+1, mygrid.y-1)
		&& !checkFloor(mygrid.x, mygrid.y-1) && !checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1) && !checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(4, 3);
		
		#  $
		# $O$
		#  
		if (checkFloor(mygrid.x-1, mygrid.y) && !checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y) && !checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1)# && !checkFloor(mygrid.x-1, mygrid.y+1)
		&& !checkFloor(mygrid.x, mygrid.y+1)# && !checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(4, 6);
			
		# $$
		# $O$
		# $$
		if (checkFloor(mygrid.x-1, mygrid.y) && checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y) && !checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1) && checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1) && !checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(1, 8);
		
		#  $$
		# $O$
		#  $$
		if (checkFloor(mygrid.x-1, mygrid.y) && !checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y) && checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1) && !checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1) && checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(4, 8);
		
		# $$$
		# $O$
		#  $
		if (checkFloor(mygrid.x-1, mygrid.y) && checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y) && checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1) && !checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1) && !checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(1, 11);
		
		#  $
		# $O$
		# $$$
		if (checkFloor(mygrid.x-1, mygrid.y) && !checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y) && !checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1) && checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1) && checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(4, 11);
		
		# $O$
		# $$
		# 
		if (checkFloor(mygrid.x-1, mygrid.y)# && checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y)# && checkFloor(mygrid.x+1, mygrid.y-1)
		&& !checkFloor(mygrid.x, mygrid.y-1) && checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1) && !checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(1, 13);
		
		# $O$
		#  $$
		# 
		if (checkFloor(mygrid.x-1, mygrid.y)# && checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y)# && checkFloor(mygrid.x+1, mygrid.y-1)
		&& !checkFloor(mygrid.x, mygrid.y-1) && !checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1) && checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(4, 13);
			
		#  $$
		# $O$
		# 
		if (checkFloor(mygrid.x-1, mygrid.y) && !checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y) && checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1)# && checkFloor(mygrid.x-1, mygrid.y+1)
		&& !checkFloor(mygrid.x, mygrid.y+1)# && checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(4, 16);
		
		# $$
		# $O$
		# 
		if (checkFloor(mygrid.x-1, mygrid.y) && checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y) && !checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1)# && checkFloor(mygrid.x-1, mygrid.y+1)
		&& !checkFloor(mygrid.x, mygrid.y+1)# && checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(1, 16);
		
		# $$
		# $O
		#  $
		if (checkFloor(mygrid.x-1, mygrid.y) && checkFloor(mygrid.x-1, mygrid.y-1)
		&& !checkFloor(mygrid.x+1, mygrid.y)# && checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1) && !checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1)# && !checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(9, 14);
		
		# $$
		# O$
		# $
		if (!checkFloor(mygrid.x-1, mygrid.y)# && checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y) && checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1)# && checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1) && !checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(6, 14);
		
		# $
		# O$
		# $$
		if (!checkFloor(mygrid.x-1, mygrid.y)# && checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y) && !checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1)# && checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1) && checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(6, 17);
		
		#  $
		# $O
		# $$
		if (checkFloor(mygrid.x-1, mygrid.y) && !checkFloor(mygrid.x-1, mygrid.y-1)
		&& !checkFloor(mygrid.x+1, mygrid.y)# && checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1) && checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1)# && !checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(9, 17);
		
		# $$
		# $O$
		#  $$
		if (checkFloor(mygrid.x-1, mygrid.y) && checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y) && !checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1) && !checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1) && checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(13, 5);
		
		#  $$
		# $O$
		# $$
		if (checkFloor(mygrid.x-1, mygrid.y) && !checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y) && checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1) && checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1) && !checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(16, 5);
		
		# $$
		# $O$
		#  $
		if (checkFloor(mygrid.x-1, mygrid.y) && checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y) && !checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1) && !checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1) && !checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(13, 8);
		
		#  $$
		# $O$
		#  $
		if (checkFloor(mygrid.x-1, mygrid.y) && !checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y) && checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1) && !checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1) && !checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(16, 8);
		
		#  $
		# $O$
		# $$
		if (checkFloor(mygrid.x-1, mygrid.y) && !checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y) && !checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1) && checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1) && !checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(13, 11);
		
		#  $
		# $O$
		#  $$
		if (checkFloor(mygrid.x-1, mygrid.y) && !checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y) && !checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1) && !checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1) && checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(16, 11);
		
		# $$
		# $O$
		# $$$
		if (checkFloor(mygrid.x-1, mygrid.y) && checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y) && !checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1) && checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1) && checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(7, 8);
		
		#  $$
		# $O$
		# $$$
		if (checkFloor(mygrid.x-1, mygrid.y) && !checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y) && checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1) && checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1) && checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(10, 8);
		
		# $$$
		# $O$
		# $$
		if (checkFloor(mygrid.x-1, mygrid.y) && checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y) && checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1) && checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1) && !checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(7, 5);
		
		# $$$
		# $O$
		#  $$
		if (checkFloor(mygrid.x-1, mygrid.y) && checkFloor(mygrid.x-1, mygrid.y-1)
		&& checkFloor(mygrid.x+1, mygrid.y) && checkFloor(mygrid.x+1, mygrid.y-1)
		&& checkFloor(mygrid.x, mygrid.y-1) && !checkFloor(mygrid.x-1, mygrid.y+1)
		&& checkFloor(mygrid.x, mygrid.y+1) && checkFloor(mygrid.x+1, mygrid.y+1)
		):
			get_node(currentsprite+"/Sprite").frame_coords = Vector2(10, 5);
		
		#FALSE FLOOR
		var levelFloorGrid = get_parent().calculateGrid(get_node("../LevelFloor").position.x, get_node("../LevelFloor").position.y);
		var endFloorGrid = get_parent().calculateGrid(get_node("../EndFloor").position.x, get_node("../EndFloor").position.y);
		if (mygrid.x == levelFloorGrid.x+1):
			if (mygrid.y == levelFloorGrid.y):
				get_node(currentsprite+"/FalseUp").show();
			if (mygrid.y > levelFloorGrid.y):
				get_node(currentsprite+"/FalseCenter").show();
		
		if (mygrid.x == endFloorGrid.x-2):
			if (mygrid.y == endFloorGrid.y):
				get_node(currentsprite+"/FalseUp2").show();
			if (mygrid.y > endFloorGrid.y):
				get_node(currentsprite+"/FalseCenter2").show();
	else:
		get_node(currentsprite+"/Sprite").frame_coords = defaultFrameCoords;
		get_node(currentsprite+"/FalseUp").visible = defaultFalseUp;
		get_node(currentsprite+"/FalseCenter").visible = defaultFalseCenter;
		get_node(currentsprite+"/FalseUp2").visible = defaultFalseUp2;
		get_node(currentsprite+"/FalseCenter2").visible = defaultFalseCenter2;
	
	if (shadow == null):
		pass
	else:
		shadow.queue_free();
	shadow = Sprite.new();
	shadow.scale = currentSprite.scale
	shadow.hframes = currentSprite.get_node("Sprite").hframes;
	shadow.vframes = currentSprite.get_node("Sprite").vframes;
	shadow.texture = currentSprite.get_node("Sprite").texture;
	get_node("../ShadowViewport").add_child(shadow);
	if (shadowdecoration == null):
		pass
	else:
		shadowdecoration.queue_free();
	shadowdecoration = Sprite.new();
	shadowdecoration.scale = currentSprite.scale;
	get_node("../ShadowViewport").add_child(shadowdecoration);

func levelFloorChanged(levelFloorGrid):
	if (mygrid.x == levelFloorGrid.x+1):
		styleChanged();
		
func endFloorChanged(endFloorGrid):
	if (mygrid.x == endFloorGrid.x-2 || mygrid.x == endFloorGrid.x-3):
		styleChanged();

func getFrameCoords():
	var currentsprite = "Sprite"+Global.CurrentStyle;
	return get_node(currentsprite+"/Sprite").frame_coords;

func getFalse(Str: String):
	var currentsprite = "Sprite"+Global.CurrentStyle;
	return get_node(currentsprite+"/False"+Str).visible;
