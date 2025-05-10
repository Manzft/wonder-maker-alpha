extends Node2D

onready var currentSprite = get_node("SpriteGround");

var grid_origin = Vector2(0, 0);
var grid_end = Vector2(1, 1);

var bye = false;

var seldirection = "right";

var shadow : Sprite;

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
	inst.seldirection = seldirection;
	var mygrid = get_parent().calculateGrid(position.x, position.y);
	for i in range(grid_end.x+1):
		for j in range(grid_end.y+1):
			if (Vector2(i, j) != grid_origin):
				get_parent().grid_node[grid.x+i][grid.y+j] = inst;
	queue_free();

func eraseShadow():
	shadow.queue_free();

func _ready():
	Global.connect("render", self, "render");
	Global.connect("floorErase", self, "floorErase");
	Global.connect("changeStyle", self, "changeStyle");
	Global.connect("erase", self, "erase");
	styleChanged();

func _process(delta: float):
	if (bye):
		eraseShadow();
		queue_free();
		
	$DirectionButton/ArrowLeft.hide();
	$DirectionButton/ArrowRight.hide();
	$DirectionButton/ArrowUp.hide();
	$DirectionButton/ArrowDown.hide();
	
	$DirectionButton/ArrowLeftUp.hide();
	$DirectionButton/ArrowLeftDown.hide();
	$DirectionButton/ArrowRightUp.hide();
	$DirectionButton/ArrowRightDown.hide();
	match (seldirection):
		"down":
			$DirectionButton/ArrowDown.show();
			currentSprite.rotation = lerp_angle(currentSprite.rotation, deg2rad(90.0), 16.0*delta);
		"up":
			$DirectionButton/ArrowUp.show();
			currentSprite.rotation = lerp_angle(currentSprite.rotation, deg2rad(270.0), 16.0*delta);
		"left":
			$DirectionButton/ArrowLeft.show();
			currentSprite.rotation = lerp_angle(currentSprite.rotation, deg2rad(180.0), 16.0*delta);
		"right":
			$DirectionButton/ArrowRight.show();
			currentSprite.rotation = lerp_angle(currentSprite.rotation, deg2rad(0.0), 16.0*delta);
		#----------------------------------------------------------
		"leftdown":
			$DirectionButton/ArrowLeftDown.show();
			currentSprite.rotation = lerp_angle(currentSprite.rotation, deg2rad(135.0), 16.0*delta);
		"leftup":
			$DirectionButton/ArrowLeftUp.show();
			currentSprite.rotation = lerp_angle(currentSprite.rotation, deg2rad(225.0), 16.0*delta);
		"rightdown":
			$DirectionButton/ArrowRightDown.show();
			currentSprite.rotation = lerp_angle(currentSprite.rotation, deg2rad(45.0), 16.0*delta);
		"rightup":
			$DirectionButton/ArrowRightUp.show();
			currentSprite.rotation = lerp_angle(currentSprite.rotation, deg2rad(315.0), 16.0*delta);
	
	if (get_node("../Editor").playing):
		$DirectionButton.hide();
	else:
		$DirectionButton.show();
	
	shadow.position = currentSprite.global_position+Vector2(3*3.25, 3*3.25);
	shadow.scale = currentSprite.scale;
	shadow.rotation_degrees = currentSprite.rotation_degrees;

func styleChanged():
	match (Global.CurrentStyle):
		_:
			pass
	if (shadow == null):
		pass
	else:
		shadow.queue_free();
	shadow = Sprite.new();
	shadow.texture = currentSprite.texture;
	shadow.scale = currentSprite.scale
	get_node("../ViewportShadow/Shadows").add_child(shadow);

func _on_DirectionButton_pressed():
	match (seldirection):
		"down":
			seldirection = "leftdown";
		"leftdown":
			seldirection = "left";
		"left":
			seldirection = "leftup";
		"leftup":
			seldirection = "up";
		"up":
			seldirection = "rightup";
		"rightup":
			seldirection = "right";
		"right":
			seldirection = "rightdown";
		"rightdown":
			seldirection = "down";
	$AudioGrabMove.play();
	if (OS.get_name() == "Android"):
		get_node("../Editor").externalButton = false;

func _on_DirectionButton_mouse_entered():
	get_node("../Editor").externalButton = true;

func _on_DirectionButton_mouse_exited():
	get_node("../Editor").externalButton = false;
