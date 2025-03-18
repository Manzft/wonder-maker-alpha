extends KinematicBody2D

var def_max_walk_speed = 200;
var def_jump_h  = -500;
var def_gravity = 30;
var def_max_fall = def_jump_h*-1;

var max_walk_speed = 0.0;
var jump_h  = 0.0;
var gravity = 0.0;
var max_fall = 0.0;

var timer = 0.0;

onready var currentSprite = get_node("SpriteGround");

var motion = Vector2();

var startPos = Vector2();

var active = false;
var exiting = false;
var arrived = false;
var insided = false;

var mushroom = false;

var flip_h = false;

var canSyncAnim = false;

var shadow : AnimatedSprite;
var dupsprite : AnimatedSprite;
var dupmushicon : Sprite;

var mushIconVisible : bool = false;

func setMushroom(val):
	mushroom = val;
	$MushroomIcon.visible = mushroom;
	if (mushroom):
		$AnimationPlayer.play("rescale");

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
	dupsprite.queue_free();
	dupmushicon.queue_free();
	shadow.queue_free();

func _ready():
	max_walk_speed = def_max_walk_speed/(Global.ENTITY_PHYSICS_SPEED*0.01);
	jump_h  = def_jump_h/(Global.ENTITY_PHYSICS_SPEED*0.01);
	gravity = def_gravity/(Global.ENTITY_PHYSICS_SPEED*0.01);
	max_fall = def_max_fall/(Global.ENTITY_PHYSICS_SPEED*0.01);
	Global.connect("render", self, "render");
	Global.connect("floorErase", self, "floorErase");
	Global.connect("changeStyle", self, "changeStyle");
	Global.connect("erase", self, "erase");
	styleChanged();
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");
	startPos = position;
	canSyncAnim = true;
	setMushroom(mushroom);
	
	if (mushroom && insided):
		if (get_node("../Character").currentPowerup == "small"):
			var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_MUSHROOM][Global.OP_SCENE].instance();
			inst.position = position;
			inst.exiting = true;
			inst.insided = true;
			get_parent().add_child(inst);
			queue_free();
			
			hide();

func _process(_delta):
	if (get_node("../Editor").playing):
		currentSprite.speed_scale = 1;
		
		if (canSyncAnim):
			var nodes = get_tree().get_nodes_in_group("Fireflower");
			for node in nodes:
				node.currentSprite.frame = currentSprite.frame;
		mushIconVisible = false;
	else:
		mushIconVisible = mushroom;
		if (insided):
			eraseShadow();
			queue_free();
		
		if (!visible):
			show();
		if (active):
			position = startPos;
			motion = Vector2(0.0, 0.0);
			move_and_slide(motion, Vector2(0, -1));
			active = false
		
		startPos = position;
		arrived = false;
		exiting = false;
		flip_h = false;
		
		var delete = false;
		if (get_parent().calculateGrid(position.x, position.y).x <= 6):
			if (get_parent().calculateGrid(position.x, position.y).y >= get_node("../LevelFloor").current_grid.y):
				delete = true;
		if (get_parent().calculateGrid(position.x, position.y).x >= get_node("../EndFloor").current_grid.x):
			if (get_parent().calculateGrid(position.x, position.y).y >= get_node("../EndFloor").current_grid.y):
				delete = true;
		
		if (delete):
			get_parent().eraseObject(position);
		currentSprite.speed_scale = 0;
		currentSprite.frame = 0;
	var pos = dupsprite.position.linear_interpolate(currentSprite.global_position, 0.35)
	currentSprite.hide();
	$MushroomIcon.hide();
	if (Global.playing && Global.PHYSICS_INTERPOLATION && Global.ENTITY_PHYSICS_SPEED < 100.0):
		dupsprite.position = pos;
	else:
		dupsprite.position = currentSprite.global_position;
	
	dupsprite.frame = currentSprite.frame;
	dupsprite.animation = currentSprite.animation;
	dupsprite.rotation_degrees = currentSprite.rotation_degrees+rotation_degrees;
	dupsprite.visible = visible;
	dupsprite.flip_h = currentSprite.flip_h;
	dupsprite.flip_v = currentSprite.flip_v;
	dupsprite.scale = currentSprite.scale;
	dupsprite.z_index = z_index;
	
	shadow.frame = currentSprite.frame;
	shadow.animation = currentSprite.animation;
	shadow.position = dupsprite.global_position+Vector2(3*3.25, 3*3.25);
	shadow.rotation_degrees = currentSprite.rotation_degrees+rotation_degrees;
	shadow.visible = visible;
	shadow.flip_h = currentSprite.flip_h;
	shadow.flip_v = currentSprite.flip_v;
	shadow.scale = currentSprite.scale;
	
	dupmushicon.position = $MushroomIcon.global_position;
	dupmushicon.rotation_degrees = $MushroomIcon.rotation_degrees+rotation_degrees;
	dupmushicon.visible = mushIconVisible;
	dupmushicon.flip_h = $MushroomIcon.flip_h;
	dupmushicon.flip_v = $MushroomIcon.flip_v;
	dupmushicon.scale = $MushroomIcon.scale;
	dupmushicon.z_index = z_index;

func _physics_process(delta):
	if (!get_node("../Editor").playing || !visible):
		return
	
	if (!active && !exiting):
		active = true;
	
	if (!active && exiting):
		position.y -= 2;
		if (position.y <= startPos.y-52):
			active = true;
			exiting = false;
	
	if (active && !exiting):
		motion.y += gravity
		if (!arrived && is_on_floor()):
			arrived = true;
		
	#Global Movement Controller
	timer += delta
	if (timer >= delta/(Global.ENTITY_PHYSICS_SPEED*0.01)):
		timer = 0.0
		if (!exiting):
			motion = move_and_slide(motion, Vector2(0, -1));

func jump():
	motion.y = jump_h;

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
	shadow = AnimatedSprite.new();
	shadow.frames = currentSprite.frames;
	shadow.scale = currentSprite.scale;
	get_node("../ShadowViewport").add_child(shadow);
	
	if (dupsprite == null):
		pass
	else:
		dupsprite.queue_free();
	dupsprite = AnimatedSprite.new();
	dupsprite.frames = currentSprite.frames;
	dupsprite.animation = currentSprite.animation;
	dupsprite.scale = currentSprite.scale;
	dupsprite.position = position;
	dupsprite.add_to_group("SpriteClone");
	get_parent().add_child(dupsprite);
	
	if (dupmushicon == null):
		pass
	else:
		dupmushicon.queue_free();
	dupmushicon = Sprite.new();
	dupmushicon.texture = $MushroomIcon.texture;
	dupmushicon.scale = $MushroomIcon.scale;
	dupmushicon.position = $MushroomIcon.global_position;
	dupmushicon.add_to_group("SpriteClone");
	get_parent().add_child(dupmushicon);

func _on_Area2D_body_entered(body):
	if (body.is_in_group("Character") && visible && !exiting && active):
		shadow.hide();
		dupsprite.hide();
		hide();
		if (body.get_node("PowerupGot").playing):
			body.get_node("PowerupGot").stop();
		body.get_node("PowerupGot").play();
		body.powerup("Fireflower");
		
		var inst = load("res://scenes/appearances/smb/Score.tscn").instance();
		get_parent().add_child(inst);
		inst.position = get_node("../Character").position;
		inst.position.y -= 26
		inst.position.x += 26
		inst.get_node("Text").text = "1000";
		get_node("../Editor").Score += 1000;
