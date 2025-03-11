extends StaticBody2D

onready var currentSprite = get_node("SpriteGround");

var grid_origin = Vector2(0, 0);
var grid_end = Vector2(1, 1);

var bye = false;

var seldirection = "up";

#var shadows = {
#	"top": null,
#	"body1": null
#}

var shadowtop : Sprite
var shadowbody : Sprite

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
	inst.seldirection = seldirection;
	var mygrid = get_parent().calculateGrid(position.x, position.y);
	for i in range(grid_end.x+1):
		for j in range(grid_end.y+1):
			if (Vector2(i, j) != grid_origin):
				get_parent().grid_node[grid.x+i][grid.y+j] = inst;

	queue_free();

func eraseShadow():
	shadowbody.queue_free();
	shadowtop.queue_free();

func _ready():
	Global.connect("render", self, "render");
	Global.connect("floorErase", self, "floorErase");
	Global.connect("changeStyle", self, "changeStyle");
	Global.connect("erase", self, "erase");
	styleChanged();
	
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");

func _process(_delta):
	if (bye):
		eraseShadow();
		queue_free();
		
	$DirectionButton/ArrowLeft.hide();
	$DirectionButton/ArrowRight.hide();
	$DirectionButton/ArrowUp.hide();
	$DirectionButton/ArrowDown.hide();
	match (seldirection):
		"right":
			$DirectionButton/ArrowRight.show();
			#currentSprite.rotation_degrees = 90;
			currentSprite.rotation = lerp_angle(currentSprite.rotation, deg2rad(90.0), 0.25);
			currentSprite.flip_h = false;
			currentSprite.get_node("Body").flip_h = false;
		"left":
			$DirectionButton/ArrowLeft.show();
			#currentSprite.rotation_degrees = 270;
			currentSprite.rotation = lerp_angle(currentSprite.rotation, deg2rad(270.0), 0.25);
			currentSprite.flip_h = true;
			currentSprite.get_node("Body").flip_h = true;
		"down":
			$DirectionButton/ArrowDown.show();
			#currentSprite.rotation_degrees = 180;
			currentSprite.rotation = lerp_angle(currentSprite.rotation, deg2rad(180.0), 0.25);
			currentSprite.flip_h = true;
			currentSprite.get_node("Body").flip_h = true;
		"up":
			$DirectionButton/ArrowUp.show();
			#currentSprite.rotation_degrees = 0;
			currentSprite.rotation = lerp_angle(currentSprite.rotation, deg2rad(0.0), 0.25);
			currentSprite.flip_h = false;
			currentSprite.get_node("Body").flip_h = false;
	
	if (get_node("../Editor").playing):
		$DirectionButton.hide();
	else:
		$DirectionButton.show();
		
	shadowtop.position = currentSprite.global_position+Vector2(3*3.25, 3*3.25);
	shadowtop.scale = currentSprite.scale;
	shadowtop.rotation_degrees = currentSprite.rotation_degrees;
	shadowbody.position = currentSprite.get_node("Body").global_position+Vector2(3*3.25, 3*3.25);
	shadowbody.scale = currentSprite.get_node("Body").scale;
	shadowbody.rotation_degrees = currentSprite.rotation_degrees;
	
#	var 
#	for key in shadows.keys():
#		if (key == "top"):
#

func styleChanged():
	match (Global.CurrentStyle):
		_:
			pass
	if (shadowtop == null):
		pass
	else:
		shadowtop.queue_free();
	shadowtop = Sprite.new();
	shadowtop.texture = currentSprite.texture;
	shadowtop.scale = currentSprite.scale
	get_node("../ShadowViewport").add_child(shadowtop);
	if (shadowbody == null):
		pass
	else:
		shadowbody.queue_free();
	shadowbody = Sprite.new();
	shadowbody.texture = currentSprite.texture;
	shadowbody.scale = currentSprite.scale
	get_node("../ShadowViewport").add_child(shadowbody);

func _on_DirectionButton_pressed():
	match (seldirection):
		"up":
			seldirection = "right";
		"down":
			seldirection = "left";
		"left":
			seldirection = "up";
		"right":
			seldirection = "down";
	$AudioGrabMove.play();
	if (OS.get_name() == "Android"):
		get_node("../Editor").externalButton = false;

func _on_DirectionButton_mouse_entered():
	get_node("../Editor").externalButton = true;

func _on_DirectionButton_mouse_exited():
	get_node("../Editor").externalButton = false;
