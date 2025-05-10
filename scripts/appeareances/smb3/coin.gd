extends Area2D

onready var currentSprite = get_node("SpriteGround");

var p = false;
var powner = false;

var shadow : AnimatedSprite;

func render(group, forcerender = false, render_range = 60):
	if (forcerender):
		set_process(true);
		set_physics_process(true);
		return
	if (group != ""):
		if (!is_in_group(group)):
			return
	var scrwidth = get_node("../Editor/BlackScreen").rect_size.x;
	var distance = abs(position.x-Global.campos.x);
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

func _process(_delta):
	if (get_node("../Editor").playing):
		currentSprite.frame = floor(get_parent().syncanim.smb.coin);
		currentSprite.speed_scale = 1;
	else:
		if (p):
			eraseShadow();
			queue_free();
		if (powner):
			powner = false;
		
		if (!visible):
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
	shadow.position = currentSprite.global_position+Vector2(3*3.25, 3*3.25);
	get_node("../ViewportShadow/Shadows").add_child(shadow);

func _on_Coin_body_entered(body):
	if (body.is_in_group("Character") && visible):
		hide();
		if (body.get_node("SoundCoin").playing):
			body.get_node("SoundCoin").stop();
		body.get_node("SoundCoin").play();
		
		get_parent().get_node("Editor").Coins += 1;
		get_node("../Editor").Score += 200;
		
		var inst = get_parent().coinSparkle[Global.CurrentAppeareance].instance();
		get_parent().add_child(inst);
		inst.position = position;
		
		if (!p):
			var grid = get_parent().calculateGrid(position.x, position.y);
			var gr = get_parent().grid[grid.x][grid.y+1];
			if (gr == Global.OBJ_LUCKYBLOCK || gr == Global.OBJ_BRICK || gr == Global.OBJ_INVISIBLE_LUCKYBLOCK):
				var nodes = get_tree().get_nodes_in_group("Insideable");
				for node in nodes:
					if (node.position == get_parent().calculateGridPosition(Vector2(grid.x, grid.y+1))):
						node.myUpCoinDone = true;
		else:
			var grid = get_parent().calculateGrid(position.x, position.y);
			get_parent().grid_node[grid.x][grid.y].powner = false;
			eraseShadow();
			queue_free();
