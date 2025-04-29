extends StaticBody2D

onready var currentSprite = get_node("SpriteGround");

var shadow : Sprite = null

var grid_origin = Vector2(0, 0);
var grid_end = Vector2(1, 1);

var bye = false;

func setupExtensionGrids(start = false):
	var a = true;
	var mygrid = get_parent().calculateGrid(position.x, position.y);
	for i in range(grid_end.x+1):
		for j in range(grid_end.y+1):
			if (Vector2(i, j) != grid_origin):
				if (get_parent().grid_node[mygrid.x+i][mygrid.y+j] != null && start):
					a = false;
					bye = true;
	return a;

func setGrids(val):
	var mygrid = get_parent().calculateGrid(position.x, position.y);
	for i in range(grid_end.x+1):
		for j in range(grid_end.y+1):
			if (Vector2(i, j) != grid_origin):
				get_parent().grid_node[mygrid.x+i][mygrid.y+j] = self
				get_parent().grid[mygrid.x+i][mygrid.y+j] = val

func render(group, forcerender = false, render_range = 60):
	if (forcerender):
		set_process(true);
		set_physics_process(true);
		return
	if (group != ""):
		if (!is_in_group(group)):
			return
	var scrwidth = get_node("../Editor/BlackScreen").rect_size.x
	var distance = abs(position.x-Global.campos.x)
	if (distance-(scrwidth/2) > scrwidth*(render_range*0.01)):
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
	styleChanged();

func _process(_delta):
	if (bye):
		eraseShadow();
		queue_free();
	
	shadow.position = currentSprite.global_position+Vector2(3*3.25, 3*3.25);
	shadow.scale = currentSprite.scale;

func styleChanged():
	match (Global.CurrentStyle):
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
	shadow.position = currentSprite.global_position+Vector2(3*3.25, 3*3.25);
	get_node("../ViewportShadow/Shadows").add_child(shadow);
