extends KinematicBody2D

const max_walk_speed = 200;
const jump_h  = -500;
const gravity = 30;
const max_fall = jump_h*-1;

onready var currentSprite = get_node("SpriteGround");

onready var rcd1 = get_node("LeftRayCast");
onready var rcd2 = get_node("RightRayCast");

var motion = Vector2();

var startPos = Vector2();

var active = false;
var exiting = false;
var arrived = false;
var insided = false;

var mushroom = false;

var flip_h = false;

var canSyncAnim = false;

func setMushroom(val):
	mushroom = val;
	$MushroomIcon.visible = mushroom;
	if (mushroom):
		$AnimationPlayer.play("rescale");

func _ready():
	styleChanged();
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");
	startPos = position;
	canSyncAnim = true;
	setMushroom(mushroom);
	$VisibilityEnabler2D.emit_signal("screen_exited")
	
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
		$MushroomIcon.hide();
	else:
		$MushroomIcon.visible = mushroom;
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
	Global.rendering(self);

func _physics_process(_delta):
	if (!get_node("../Editor").playing || !visible):
		return
	#Head Hit Raycasts
	#if (rcd1.is_colliding()): areaCollide(rcd1);
	#elif (rcd2.is_colliding()): areaCollide(rcd2);
	
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
			
		#if (arrived):
		#	if (flip_h):
		#		motion.x = -max_walk_speed;
		#	else:
		#		motion.x = max_walk_speed;
		
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
			if (rc == rcd2 && motion.x > 0):
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
		body.powerup("Fireflower");
		
		var inst = load("res://scenes/appearances/smb3/Score.tscn").instance();
		get_parent().add_child(inst);
		inst.position = get_node("../Character").position;
		inst.position.y -= 26
		inst.position.x += 26
		inst.get_node("Text").text = "1000";
		get_node("../Editor").Score += 1000;
