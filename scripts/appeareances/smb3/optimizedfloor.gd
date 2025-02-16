extends CollisionShape2D

var floorlevel = false;
var endlevel = false;

onready var currentSprite = get_node("SpriteGround");
onready var subCurrentSprite = get_node("SpriteGround/CenterAlone");

var hasDecoration = false;
var editPlaced = false;
var decorationType = "";

var mygrid = Vector2();

func _ready():
	get_node("../../LevelFloor").connect("levelFloorChanged", self, "levelFloorChanged");
	get_node("../../EndFloor").connect("endFloorChanged", self, "endFloorChanged");
	yield(get_tree(), "idle_frame");
	if (get_parent().get_parent().editing && !floorlevel && !endlevel):
		$AnimationPlayer.play("start");
	mygrid = get_parent().get_parent().calculateGrid(position.x, position.y);
	
	updateNearFloors();
	styleChanged();
	spawnDecoration();

func spawnDecoration():
	var i = str(round(rand_range(0, 20)));
	var text = "";
	match (i):
		"0":
			var mygrid = get_parent().get_parent().calculateGrid(position.x, position.y);
			if (isNotSolidOrDoesntExists(Vector2(mygrid.x, mygrid.y-1)) && isNotSolidOrDoesntExists(Vector2(mygrid.x, mygrid.y-2)) && isNotSolidOrDoesntExists(Vector2(mygrid.x, mygrid.y-3))):
				get_node(Global.CurrentStyle+"/DecorationTall").show();
				decorationType = "Tall";
				hasDecoration = true;
				if (editPlaced):
					$SoundSpawnDecoration.play();
		"1":
			var mygrid = get_parent().get_parent().calculateGrid(position.x, position.y);
			if (isNotSolidOrDoesntExists(Vector2(mygrid.x, mygrid.y-1)) && isNotSolidOrDoesntExists(Vector2(mygrid.x, mygrid.y-2))):
				get_node(Global.CurrentStyle+"/DecorationShort").show();
				decorationType = "Short";
				hasDecoration = true;
				if (editPlaced):
					$SoundSpawnDecoration.play();
		"2":
			var mygrid = get_parent().get_parent().calculateGrid(position.x, position.y);
			if (isNotSolidOrDoesntExists(Vector2(mygrid.x, mygrid.y-1)) && isNotSolidOrDoesntExists(Vector2(mygrid.x-1, mygrid.y-1)) && isNotSolidOrDoesntExists(Vector2(mygrid.x-2, mygrid.y-1))):
				if (get_node("../../").grid[mygrid.x-1][mygrid.y] == Global.OBJ_FLOOR && get_node("../../").grid[mygrid.x-2][mygrid.y] == Global.OBJ_FLOOR):
					if (!get_node("../../").grid_node[mygrid.x-1][mygrid.y].hasDecoration && !get_node("../../").grid_node[mygrid.x-2][mygrid.y].hasDecoration):
						get_node(Global.CurrentStyle+"/DecorationWide").show();
						decorationType = "Wide";
						hasDecoration = true;
						if (editPlaced):
							$SoundSpawnDecoration.play();

func updateNearFloors():
	var mygrid = get_parent().get_parent().calculateGrid(position.x, position.y);
	var x = mygrid.x;
	var y = mygrid.y;
	var pr = get_parent().get_parent();
	if (pr.grid[x-1][y] == Global.OBJ_FLOOR): pr.grid_node[x-1][y].styleChanged();
	if (pr.grid[x+1][y] == Global.OBJ_FLOOR): pr.grid_node[x+1][y].styleChanged();
	if (pr.grid[x][y+1] == Global.OBJ_FLOOR): pr.grid_node[x][y+1].styleChanged();
	if (pr.grid[x][y-1] == Global.OBJ_FLOOR): pr.grid_node[x][y-1].styleChanged();
	if (pr.grid[x-1][y-1] == Global.OBJ_FLOOR): pr.grid_node[x-1][y-1].styleChanged();
	if (pr.grid[x+1][y-1] == Global.OBJ_FLOOR): pr.grid_node[x+1][y-1].styleChanged();
	if (pr.grid[x-1][y+1] == Global.OBJ_FLOOR): pr.grid_node[x-1][y+1].styleChanged();
	if (pr.grid[x+1][y+1] == Global.OBJ_FLOOR): pr.grid_node[x+1][y+1].styleChanged();

func isNotSolidOrDoesntExists(mygrid = Vector2()):
	var check = (get_node("../../").grid_node[mygrid.x][mygrid.y] == null);
	var check2 = false;
	if (!check):
		check2 = (!get_node("../../").grid_node[mygrid.x][mygrid.y].is_in_group("Solid"));
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
	var pr = get_parent().get_parent();
	var levelFloorGrid = pr.calculateGrid(get_node("../../LevelFloor").position.x, get_node("../../LevelFloor").position.y);
	var endFloorGrid = pr.calculateGrid(get_node("../../EndFloor").position.x, get_node("../../EndFloor").position.y);
	
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
	var mygrid = get_parent().get_parent().calculateGrid(position.x, position.y);
	var currentsprite = "Sprite"+Global.CurrentStyle;
	#Up
	if (checkFloor(mygrid.x-1, mygrid.y)
	&& checkFloor(mygrid.x+1, mygrid.y)
	&& !checkFloor(mygrid.x, mygrid.y-1)
	&& checkFloor(mygrid.x, mygrid.y+1)):
		if (subCurrentSprite != get_node(currentsprite+"/Up")):
			subCurrentSprite.hide();
			subCurrentSprite = get_node(currentsprite+"/Up");
			subCurrentSprite.show();
			hideShadows();
			#get_node(currentsprite+"/ShadowFull").show();
	#Up Left
	elif (!checkFloor(mygrid.x-1, mygrid.y)
	&& checkFloor(mygrid.x+1, mygrid.y)
	&& !checkFloor(mygrid.x, mygrid.y-1)
	&& checkFloor(mygrid.x, mygrid.y+1)):
		if (subCurrentSprite != get_node(currentsprite+"/UpLeft")):
			subCurrentSprite.hide();
			subCurrentSprite = get_node(currentsprite+"/UpLeft");
			subCurrentSprite.show();
			hideShadows();
			get_node(currentsprite+"/ShadowFull").show();
	#Up Right
	elif (checkFloor(mygrid.x-1, mygrid.y)
	&& !checkFloor(mygrid.x+1, mygrid.y)
	&& !checkFloor(mygrid.x, mygrid.y-1)
	&& checkFloor(mygrid.x, mygrid.y+1)):
		if (subCurrentSprite != get_node(currentsprite+"/UpRight")):
			subCurrentSprite.hide();
			subCurrentSprite = get_node(currentsprite+"/UpRight");
			subCurrentSprite.show();
			hideShadows();
			get_node(currentsprite+"/ShadowUpRight").show();
	#Center
	elif (checkFloor(mygrid.x-1, mygrid.y)
	&& checkFloor(mygrid.x+1, mygrid.y)
	&& checkFloor(mygrid.x, mygrid.y-1)
	&& checkFloor(mygrid.x, mygrid.y+1)):
		if (subCurrentSprite != get_node(currentsprite+"/Center")):
			subCurrentSprite.hide();
			subCurrentSprite = get_node(currentsprite+"/Center");
			subCurrentSprite.show();
			hideShadows();
			#get_node(currentsprite+"/ShadowFull").show();
	#Left
	elif (!checkFloor(mygrid.x-1, mygrid.y)
	&& checkFloor(mygrid.x+1, mygrid.y)
	&& checkFloor(mygrid.x, mygrid.y-1)
	&& checkFloor(mygrid.x, mygrid.y+1)):
		if (subCurrentSprite != get_node(currentsprite+"/Left")):
			subCurrentSprite.hide();
			subCurrentSprite = get_node(currentsprite+"/Left");
			subCurrentSprite.show();
			hideShadows();
			#get_node(currentsprite+"/ShadowFull").show();
	#Right
	elif (checkFloor(mygrid.x-1, mygrid.y)
	&& !checkFloor(mygrid.x+1, mygrid.y)
	&& checkFloor(mygrid.x, mygrid.y-1)
	&& checkFloor(mygrid.x, mygrid.y+1)):
		if (subCurrentSprite != get_node(currentsprite+"/Right")):
			subCurrentSprite.hide();
			subCurrentSprite = get_node(currentsprite+"/Right");
			subCurrentSprite.show();
			hideShadows();
			get_node(currentsprite+"/ShadowFull").show();
	#Down
	elif (checkFloor(mygrid.x-1, mygrid.y)
	&& checkFloor(mygrid.x+1, mygrid.y)
	&& checkFloor(mygrid.x, mygrid.y-1)
	&& !checkFloor(mygrid.x, mygrid.y+1)):
		if (subCurrentSprite != get_node(currentsprite+"/Down")):
			subCurrentSprite.hide();
			subCurrentSprite = get_node(currentsprite+"/Down");
			subCurrentSprite.show();
			hideShadows();
			get_node(currentsprite+"/ShadowFull").show();
	#Down Left
	elif (!checkFloor(mygrid.x-1, mygrid.y)
	&& checkFloor(mygrid.x+1, mygrid.y)
	&& checkFloor(mygrid.x, mygrid.y-1)
	&& !checkFloor(mygrid.x, mygrid.y+1)):
		if (subCurrentSprite != get_node(currentsprite+"/DownLeft")):
			subCurrentSprite.hide();
			subCurrentSprite = get_node(currentsprite+"/DownLeft");
			subCurrentSprite.show();
			hideShadows();
			get_node(currentsprite+"/ShadowDownLeft").show();
	#Down Right
	elif (checkFloor(mygrid.x-1, mygrid.y)
	&& !checkFloor(mygrid.x+1, mygrid.y)
	&& checkFloor(mygrid.x, mygrid.y-1)
	&& !checkFloor(mygrid.x, mygrid.y+1)):
		if (subCurrentSprite != get_node(currentsprite+"/DownRight")):
			subCurrentSprite.hide();
			subCurrentSprite = get_node(currentsprite+"/DownRight");
			subCurrentSprite.show();
			hideShadows();
			get_node(currentsprite+"/ShadowDownRight").show();
	#Left Alone
	elif (!checkFloor(mygrid.x-1, mygrid.y)
	&& checkFloor(mygrid.x+1, mygrid.y)
	&& !checkFloor(mygrid.x, mygrid.y-1)
	&& !checkFloor(mygrid.x, mygrid.y+1)):
		if (subCurrentSprite != get_node(currentsprite+"/LeftAlone")):
			subCurrentSprite.hide();
			subCurrentSprite = get_node(currentsprite+"/LeftAlone");
			subCurrentSprite.show();
			hideShadows();
			get_node(currentsprite+"/ShadowDownLeft").show();
	#Right Alone
	elif (checkFloor(mygrid.x-1, mygrid.y)
	&& !checkFloor(mygrid.x+1, mygrid.y)
	&& !checkFloor(mygrid.x, mygrid.y-1)
	&& !checkFloor(mygrid.x, mygrid.y+1)):
		if (subCurrentSprite != get_node(currentsprite+"/RightAlone")):
			subCurrentSprite.hide();
			subCurrentSprite = get_node(currentsprite+"/RightAlone");
			subCurrentSprite.show();
			hideShadows();
			get_node(currentsprite+"/ShadowRightAlone").show();
	#Down Alone
	elif (!checkFloor(mygrid.x-1, mygrid.y)
	&& !checkFloor(mygrid.x+1, mygrid.y)
	&& checkFloor(mygrid.x, mygrid.y-1)
	&& !checkFloor(mygrid.x, mygrid.y+1)):
		if (subCurrentSprite != get_node(currentsprite+"/DownAlone")):
			subCurrentSprite.hide();
			subCurrentSprite = get_node(currentsprite+"/DownAlone");
			subCurrentSprite.show();
			hideShadows();
			get_node(currentsprite+"/ShadowDownAlone").show();
	#Up Alone
	elif (!checkFloor(mygrid.x-1, mygrid.y)
	&& !checkFloor(mygrid.x+1, mygrid.y)
	&& !checkFloor(mygrid.x, mygrid.y-1)
	&& checkFloor(mygrid.x, mygrid.y+1)):
		if (subCurrentSprite != get_node(currentsprite+"/UpAlone")):
			subCurrentSprite.hide();
			subCurrentSprite = get_node(currentsprite+"/UpAlone");
			subCurrentSprite.show();
			hideShadows();
			get_node(currentsprite+"/ShadowUpRight").show();
	#Horizontal Alone
	elif (checkFloor(mygrid.x-1, mygrid.y)
	&& checkFloor(mygrid.x+1, mygrid.y)
	&& !checkFloor(mygrid.x, mygrid.y-1)
	&& !checkFloor(mygrid.x, mygrid.y+1)):
		if (subCurrentSprite != get_node(currentsprite+"/HorizontalAlone")):
			subCurrentSprite.hide();
			subCurrentSprite = get_node(currentsprite+"/HorizontalAlone");
			subCurrentSprite.show();
			hideShadows();
			get_node(currentsprite+"/ShadowFull").show();
	#Vertical Alone
	elif (!checkFloor(mygrid.x-1, mygrid.y)
	&& !checkFloor(mygrid.x+1, mygrid.y)
	&& checkFloor(mygrid.x, mygrid.y-1)
	&& checkFloor(mygrid.x, mygrid.y+1)):
		if (subCurrentSprite != get_node(currentsprite+"/VerticalAlone")):
			subCurrentSprite.hide();
			subCurrentSprite = get_node(currentsprite+"/VerticalAlone");
			subCurrentSprite.show();
			hideShadows();
			get_node(currentsprite+"/ShadowFull").show();
	#Center Alone
	else:
		if (subCurrentSprite != get_node(currentsprite+"/CenterAlone")):
			subCurrentSprite.hide();
			subCurrentSprite = get_node(currentsprite+"/CenterAlone");
			subCurrentSprite.show();
			hideShadows();
			get_node(currentsprite+"/Shadow").show();
			
	var levelFloorGrid = get_parent().get_parent().calculateGrid(get_node("../../LevelFloor").position.x, get_node("../../LevelFloor").position.y);
	var endFloorGrid = get_parent().get_parent().calculateGrid(get_node("../../EndFloor").position.x, get_node("../../EndFloor").position.y);
	if (mygrid.x == levelFloorGrid.x+1):
		if (mygrid.y == levelFloorGrid.y):
			get_node(currentsprite+"/FalseUp").show();
		if (mygrid.y > levelFloorGrid.y):
			get_node(currentsprite+"/FalseCenter").show();
	
	if (mygrid.x == endFloorGrid.x-1):
		if (mygrid.y == endFloorGrid.y):
			get_node(currentsprite+"/FalseUp2").show();
		if (mygrid.y > endFloorGrid.y):
			get_node(currentsprite+"/FalseCenter2").show();

func levelFloorChanged(levelFloorGrid):
	if (mygrid.x == levelFloorGrid.x+1):
		styleChanged();
		
func endFloorChanged(endFloorGrid):
	if (mygrid.x == endFloorGrid.x-1 || mygrid.x == endFloorGrid.x-2):
		styleChanged();
