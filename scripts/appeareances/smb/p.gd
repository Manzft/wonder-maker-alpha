extends KinematicBody2D

onready var currentSprite = get_node("SpriteGround");

const gravity = 30;

var press = false;

var motion = Vector2();

var startPos = Vector2();

var active = false;
var exiting = false;
var arrived = false;
var insided = false;

var canSyncAnim = false;

var shadow : AnimatedSprite;

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
	startPos = position;
	canSyncAnim = true;

func _process(_delta):
	if (get_node("../Editor").playing):
		currentSprite.speed_scale = 1;
		if (!insided && !active):
			active = true;
			
		if (canSyncAnim && currentSprite.animation != "pressed"):
			var nodes = get_tree().get_nodes_in_group("P");
			for node in nodes:
				node.currentSprite.frame = currentSprite.frame;
	else:
		if (insided):
			eraseShadow();
			queue_free();
		
		if (active || !visible):
			active = false;
			exiting = false;
			arrived = false;
			show();
			position = startPos;
			motion = Vector2(0, 0);
		
		startPos = position;
		press = false;
		
		if (get_parent().grab && get_parent().grab_node == self):
			currentSprite.play("idle");
			currentSprite.speed_scale = 1;
		else:
			currentSprite.play("idle");
			currentSprite.speed_scale = 0;
			currentSprite.frame = 0;
	shadow.position = currentSprite.global_position+Vector2(3*3.25, 3*3.25);
	shadow.frame = currentSprite.frame;
	shadow.animation = currentSprite.animation;
	shadow.scale = currentSprite.scale;
	shadow.visible = visible;

func _physics_process(delta):
	if (get_node("../Editor").playing):
		if (!active && exiting):
			position.y -= 2;
			if (position.y <= startPos.y-52):
				active = true;
				exiting = false;
		
		if (active && !exiting):
			motion.y += gravity
			
			if (!arrived && is_on_floor()):
				arrived = true;
			
			if (visible && currentSprite.animation != "pressed" && press && !get_node("../Character").is_on_floor() && get_node("../Character").position.y < position.y && get_node("../Character").motion.y > 0):
				var nodes = get_tree().get_nodes_in_group("P");
				for node in nodes:
					if (node.currentSprite.animation == "pressed"):
						node.currentSprite.play("idle");
				
				currentSprite.play("pressed");
				get_node("../Character/SoundPButton").play();
				get_parent().gameMusic(false);
				
				get_node("../Character").p = true;
				
				get_node("../Character/SoundTwompHit").play();
				
				if !(Input.is_action_pressed("a") || Input.is_action_pressed("b")):
					get_node("../Character").motion.y = get_node("../Character").jump_h*0.7;
					get_node("../Character").jumping = true;
				else:
					get_node("../Character").motion.y = get_node("../Character").jump_h*1;
					get_node("../Character").jumping = true;
				
				nodes = get_tree().get_nodes_in_group("Coin");
				for node in nodes:
					if (!node.is_in_group("10Coin") && !node.is_in_group("30Coin") && !node.is_in_group("50Coin")):
						if (node.visible && !node.powner && !node.p):
							node.powner = true;
							node.hide();
							var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_BRICK][Global.OP_SCENE].instance();
							inst.position = node.position;
							inst.p = true;
							get_parent().add_child(inst);
				nodes = get_tree().get_nodes_in_group("Brick");
				for node in nodes:
					if (!node.deactivated && node.visible && !node.powner && !node.p):
						node.powner = true;
						node.hide();
						var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_COIN][Global.OP_SCENE].instance();
						inst.position = node.position;
						inst.p = true;
						get_parent().add_child(inst);
				
				yield(get_tree().create_timer(0.25), "timeout");
				hide();
		
		if (!exiting):
			motion = move_and_slide(motion, Vector2(0, -1));

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

func release():
	currentSprite.play("idle");
	
	var nodes = get_tree().get_nodes_in_group("Coin");
	for node in nodes:
		if (!node.is_in_group("10Coin") && !node.is_in_group("30Coin") && !node.is_in_group("50Coin")):
			if (node.powner):
				node.powner = false;
				node.show();
			if (node.p):
				node.eraseShadow();
				node.queue_free();
	nodes = get_tree().get_nodes_in_group("Brick");
	for node in nodes:
		if (node.powner):
			node.powner = false;
			node.show();
		if (node.p):
			node.eraseShadow();
			node.queue_free();

func _on_Area2D_body_entered(body):
	if (body.is_in_group("Character")):
		press = true;

func _on_Area2D_body_exited(body):
	if (body.is_in_group("Character")):
		press = false;
