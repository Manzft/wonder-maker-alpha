extends Area2D

onready var currentSprite = get_node("SpriteGround");

var grid_origin = Vector2(0, 0);
var grid_end = Vector2(1, 1);

var shadow : AnimatedSprite;

var bye = false;

var ready = false;

var canSyncAnim = false;

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
	if (delete): get_parent().eraseObject(position, false);

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
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");
	ready = true;
	canSyncAnim = true;

func _process(_delta):
	if (bye):
		eraseShadow();
		queue_free();
		
	if (get_node("../Editor").playing):
		currentSprite.frame = floor(get_parent().syncanim.smb.coin10);
		currentSprite.speed_scale = 1;
		
		if (canSyncAnim):
			var nodes = get_tree().get_nodes_in_group("10Coin");
			for node in nodes:
				node.currentSprite.frame = currentSprite.frame;
			nodes = get_tree().get_nodes_in_group("30Coin");
			for node in nodes:
				node.currentSprite.frame = currentSprite.frame;
			nodes = get_tree().get_nodes_in_group("50Coin");
			for node in nodes:
				node.currentSprite.frame = currentSprite.frame;
	else:
		if (!visible && ready):
			show();
		currentSprite.speed_scale = 0;
		currentSprite.frame = 0;
	shadow.position = currentSprite.global_position+Vector2(3*3.25, 3*3.25);
	shadow.frame = currentSprite.frame;
	shadow.animation = currentSprite.animation;
	shadow.scale = currentSprite.scale;
	shadow.visible = visible;

func styleChanged():
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
		"Snow":
			currentSprite.hide();
			currentSprite = get_node("SpriteUnderground");
			currentSprite.show();
		_:
			currentSprite.hide();
			currentSprite = get_node("SpriteGround");
			currentSprite.show();
	if (shadow == null):
		pass
	else:
		shadow.queue_free();
	shadow = AnimatedSprite.new();
	shadow.frames = currentSprite.frames;
	shadow.scale = currentSprite.scale;
	get_node("../ShadowViewport").add_child(shadow);

func _on_Coin_body_entered(body):
	if (body.is_in_group("Character") && visible):
		hide();
		body.get_node("Sound10Coin").play();
		
		get_node("../Editor").Score += 200;
		
		if (is_in_group("10Coin")):
			get_parent().get_node("Editor").Coins += 10;
		elif (is_in_group("30Coin")):
			get_parent().get_node("Editor").Coins += 30;
		elif (is_in_group("50Coin")):
			get_parent().get_node("Editor").Coins += 50;
