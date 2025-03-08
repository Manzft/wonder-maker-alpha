extends KinematicBody2D

const max_walk_speed = 200;
const jump_h  = -500;
const gravity = 30;
const max_fall = jump_h*-1;

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

func render(group, forcerender = false):
	if (forcerender):
		set_process(true);
		set_physics_process(true);
		return
	if (group != ""): if (!is_in_group(group)): return
	var scrwidth = OS.get_window_size().x;
	var scrheight = OS.get_window_size().y;
	var multiplier = 720/scrheight;
	var finalscrwidth = scrwidth * multiplier;
	var distance = abs(position.x-Global.campos.x);
	if (distance-(finalscrwidth/2) > finalscrwidth*0.5):
		set_process(false); set_physics_process(false);
	else:
		set_process(true); set_physics_process(true);
		
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

func _ready():
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
		pass
		#currentSprite.speed_scale = 1;
	else:
		if (insided):
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

func _physics_process(_delta):
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
			
		if (arrived):
			if (flip_h):
				motion.x = -max_walk_speed;
			else:
				motion.x = max_walk_speed;
		
	#Global Movement Controller
	if (!exiting):
		motion = move_and_slide(motion, Vector2(0, -1));

func jump():
	motion.y = jump_h;

func areaCollide(rc):
	if (!exiting && active):
		var body = rc.get_collider();
		if (body.is_in_group("Solid")):
			#Left
			if (rc == rcd1 && motion.x < 0):
				flip_h = false;
			if (rc == rcd2 && motion.x >= 0):
				flip_h = true;

func styleChanged():
	match (Global.CurrentStyle):
		_:
			currentSprite.hide();
			currentSprite = get_node("SpriteGround");
			currentSprite.show();

func _on_Area2D_body_entered(body):
	if (body.is_in_group("Character") && visible && !exiting && active):
		hide();
		if (body.get_node("PowerupGot").playing):
			body.get_node("PowerupGot").stop();
		body.get_node("PowerupGot").play();
		body.powerup("Mushroom");
		
		var inst = load("res://scenes/appearances/smb/Score.tscn").instance();
		get_parent().add_child(inst);
		inst.position = get_node("../Character").position;
		inst.position.y -= 26
		inst.position.x += 26
		inst.get_node("Text").text = "1000";
		get_node("../Editor").Score += 1000;
