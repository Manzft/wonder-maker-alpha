extends StaticBody2D

var floorlevel = false;
var endlevel = false;

onready var currentSprite = get_node("SpriteGround");

var shadow : Sprite = null

var hasDecoration = false;
var editPlaced = false;
var decorationType = "";

var mygrid = Vector2();

func render(group, forcerender = false):
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
	if (distance-(finalscrwidth/2) > finalscrwidth*0.5):
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

func _ready():
	Global.connect("render", self, "render");
	Global.connect("floorErase", self, "floorErase");
	Global.connect("changeStyle", self, "changeStyle");
	Global.connect("erase", self, "erase");
	get_node("../LevelFloor").connect("levelFloorChanged", self, "levelFloorChanged");
	get_node("../EndFloor").connect("endFloorChanged", self, "endFloorChanged");
	
	yield(get_tree(), "idle_frame");
	
	mygrid = get_parent().calculateGrid(position.x, position.y);
	updateNearFloors();
	styleChanged();
	spawnDecoration();

func _process(delta):
	if (shadow != null): shadow.position = currentSprite.global_position+Vector2(3*3.25, 3*3.25);

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

func checkFloor(x, y):
	var grid = Vector2(x, y);
	var pr = get_parent();
	var levelFloorGrid = pr.calculateGrid(get_node("../LevelFloor").position.x, get_node("../LevelFloor").position.y);
	var endFloorGrid = pr.calculateGrid(get_node("../EndFloor").position.x, get_node("../EndFloor").position.y);
	
	var check = false;
	
	if (pr.grid[grid.x][grid.y] == Global.OBJ_FLOOR):
		check = true;
	
	if (grid.x >= 0 && grid.x <= levelFloorGrid.x):
		if (grid.y >= levelFloorGrid.y):
			check = true;
	
	if (grid.x >= endFloorGrid.x && grid.x <= endFloorGrid.x+10):
		if (grid.y >= endFloorGrid.y):
			check = true;
			
	if (grid.y == 30):
		check = true;
	
	return check;

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
	if (shadow == null):
		pass
	else:
		shadow.queue_free();
	shadow = Sprite.new();
	shadow.texture = currentSprite.texture;
	shadow.scale = currentSprite.scale
	get_node("../ShadowViewport").add_child(shadow);
	
	if (Global.CurrentStyle == "Desert"):
		if (!checkFloor(mygrid.x-1, mygrid.y) && !checkFloor(mygrid.x+1, mygrid.y) && checkFloor(mygrid.x, mygrid.y+1)):
			if (currentSprite != get_node("SpriteDesertVariant")):
				currentSprite.hide();
				currentSprite = get_node("SpriteDesertVariant");
				currentSprite.show();
		else:
			if (currentSprite != get_node("SpriteDesert")):
				currentSprite.hide();
				currentSprite = get_node("SpriteDesert");
				currentSprite.show();
	
	if (Global.CurrentStyle == "Snow"):
		if (!checkFloor(mygrid.x, mygrid.y-1)):
			if (currentSprite != get_node("SpriteSnowTop")):
				currentSprite.hide();
				currentSprite = get_node("SpriteSnowTop");
				currentSprite.show();
		else:
			if (currentSprite != get_node("SpriteSnow")):
				currentSprite.hide();
				currentSprite = get_node("SpriteSnow");
				currentSprite.show();

func levelFloorChanged(levelFloorGrid):
	if (mygrid.x == levelFloorGrid.x+1):
		styleChanged();
		
func endFloorChanged(endFloorGrid):
	if (mygrid.x == endFloorGrid.x-1 || mygrid.x == endFloorGrid.x-2):
		styleChanged();
