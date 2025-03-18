extends KinematicBody2D

var def_max_walk_speed = 250;
var def_jump_h  = -400;
var def_gravity = 30;
var def_max_fall = def_jump_h*-1;

var max_walk_speed = 0.0;
var jump_h  = 0.0;
var gravity = 0.0;
var max_fall = 0.0;

var timer = 0.0;

onready var currentSprite = get_node("SpriteGround");

onready var rcd1 = get_node("LeftRayCast");
onready var rcd2 = get_node("RightRayCast");

var rcd1coll = false;
var rcd2coll = false;

var motion = Vector2();

var startPos = Vector2();

var active = false;
var exiting = false;
var arrived = false;
var insided = false;

var flip_h = false;

var shadow : AnimatedSprite;
var dupsprite : AnimatedSprite;

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

func _process(_delta):
	if (get_node("../Editor").playing):
		currentSprite.speed_scale = 1;
	else:
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
		currentSprite.speed_scale = 0;
		currentSprite.frame = 0;
	var pos = dupsprite.position.linear_interpolate(currentSprite.global_position, 0.35)
	currentSprite.hide();
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

func _physics_process(delta):
	if (!get_node("../Editor").playing):
		return
	#Head Hit Raycasts
	if (rcd1.is_colliding() && !rcd1coll):
		areaCollide(rcd1);
		rcd1coll = true;
	elif (!rcd1.is_colliding() && rcd1coll):
		rcd1coll = false;
	if (rcd2.is_colliding() && !rcd2coll):
		areaCollide(rcd2);
		rcd2coll = true;
	elif (!rcd2.is_colliding() && rcd2coll):
		rcd2coll = false;
	
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
			
		if (is_on_floor()):
			jump_star();
			
		if (arrived):
			if (flip_h):
				motion.x = -max_walk_speed;
			else:
				motion.x = max_walk_speed;
		
	#Global Movement Controller
	timer += delta
	if (timer >= delta/(Global.ENTITY_PHYSICS_SPEED*0.01)):
		timer = 0.0
		if (!exiting):
			motion = move_and_slide(motion, Vector2(0, -1));

func jump():
	motion.y = jump_h;
	
func jump_star():
	motion.y = jump_h*2;

func areaCollide(rc):
	if (!exiting && active):
		var body = rc.get_collider();
		if (body.is_in_group("Solid")):
			#Left
			if (rc == rcd1 && motion.x < 0):
				flip_h = false;
			if (rc == rcd2 && motion.x > 0):
				flip_h = true;

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

func _on_Area2D_body_entered(body):
	if (body.is_in_group("Character") && visible && !exiting && active):
		hide();
		if (body.get_node("PowerupGot").playing):
			body.get_node("PowerupGot").stop();
		body.get_node("PowerupGot").play();
		body.powerup("Star");
		var inst = load("res://scenes/appearances/smb3/Score.tscn").instance();
		get_parent().add_child(inst);
		inst.position = get_node("../Character").position;
		inst.position.y -= 26
		inst.position.x += 26
		inst.get_node("Text").text = "1000";
		get_node("../Editor").Score += 1000;
