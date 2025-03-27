extends KinematicBody2D

onready var currentSprite = get_node("SpriteGround");

var def_gravity = 30;
var def_max_h_speed = 500;

var gravity = 30;
var max_h_speed = 500;

var timer = 0.0;

var press = false;

var motion = Vector2();

var startPos = Vector2();

var active = false;
var exiting = false;
var arrived = false;
var insided = false;

var canSyncAnim = false;

var carrying = false;

var speed_increase = 0;

var shadow : AnimatedSprite;
var dupsprite : AnimatedSprite;

var canPickTimer = 0.0;
var canPick = true;

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
	gravity = def_gravity/(Global.ENTITY_PHYSICS_SPEED*0.01);
	max_h_speed = def_max_h_speed/(Global.ENTITY_PHYSICS_SPEED*0.01);
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

func _process(delta):
	if (get_node("../Editor").playing):
		canPickTimer += delta;
		if (canPickTimer >= 0.5):
			canPickTimer = 0.0;
			canPick = true;
		
		if (carrying):
			z_index = 1;
		else:
			z_index = 0;
		
		currentSprite.speed_scale = 1;
		if (!insided && !active):
			active = true;
			
		#Carried by Player
		var chara = get_node("../Character");
		if (currentSprite.animation != "pressed" && visible && carrying && chara.carrying):
			var charpos = chara.position;
			var dif = 0;
			if (chara.current_sprite.flip_h):
				dif = -32;
			else:
				dif = 32;
			
			position.x = charpos.x+dif;
			position.y = charpos.y-5;
			
			if (!chara.running):
				carrying = false;
				chara.carrying = false;
				
				motion.y = 0;
				
				if (!chara.died && !chara.changingPowerup):
					speed_increase = (abs(get_node("../Character").motion.x/2))/(Global.ENTITY_PHYSICS_SPEED*0.01);
					if (Input.is_action_pressed("down") || Input.is_action_pressed("ddown")):
						if (chara.position.x >= position.x):
							position.x -= speed_increase*0.025;
							motion.x = (-70/(Global.ENTITY_PHYSICS_SPEED*0.01))-speed_increase;
						else:
							position.x += speed_increase*0.025;
							motion.x = (70/(Global.ENTITY_PHYSICS_SPEED*0.01))+speed_increase;
					else:
						chara.get_node("KickingTimer").start();
						chara.kicking = true;
						if (chara.position.x >= position.x):
							var inst = load("res://scenes/appearances/smb3/particles/parthit.tscn").instance();
							get_parent().add_child(inst);
							inst.position.x = position.x-12.5;
							inst.position.y = position.y;
							position.x -= speed_increase*0.05;
							motion.x = -max_h_speed-speed_increase;
						else:
							var inst = load("res://scenes/appearances/smb3/particles/parthit.tscn").instance();
							get_parent().add_child(inst);
							inst.position.x = position.x+12.5;
							inst.position.y = position.y;
							position.x += speed_increase*0.05;
							motion.x = max_h_speed+speed_increase;
						chara.get_node("SoundShellHit").play();
	else:
		if (insided):
			eraseShadow()
			queue_free();
		
		if (active || !visible):
			active = false;
			exiting = false;
			arrived = false;
			show();
			position = startPos;
			motion = Vector2(0, 0);
			$CollisionShape2D.disabled = false;
		
		canPick = true;
		carrying = false;
		startPos = position;
		press = false;
		
		if (get_parent().grab && get_parent().grab_node == self):
			currentSprite.play("idle");
			currentSprite.speed_scale = 1;
		else:
			currentSprite.play("idle");
			currentSprite.speed_scale = 0;
			currentSprite.frame = 0;
	var pos = dupsprite.position.linear_interpolate(currentSprite.global_position, 0.45)
	currentSprite.hide();
	if (Global.playing && Global.PHYSICS_INTERPOLATION && Global.ENTITY_PHYSICS_SPEED < 100.0 && !carrying):
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
			
			if (!carrying && visible && currentSprite.animation != "pressed" && press && !get_node("../Character").is_on_floor() && get_node("../Character").position.y < position.y && get_node("../Character").motion.y > 0):
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
				$CollisionShape2D.disabled = true;
				yield(get_tree().create_timer(0.25), "timeout");
				hide();
				
			#Carrying
			if (canPick && visible && currentSprite.animation != "pressed" && press && !carrying && get_node("../Character").running && !get_node("../Character").carrying && !get_node("../Character").sneaking):
				carrying = true;
				canPick = false;
				canPickTimer = 0.0;
				get_node("../Character").carrying = true;
		
		if (!exiting && !carrying && visible):
			$CollisionShape2D.disabled = false;
			if (abs(motion.x) <= 70/(Global.ENTITY_PHYSICS_SPEED*0.01)):
				motion.x = lerp(motion.x, 0.0, 0.125);
			else:
				motion.x = lerp(motion.x, 0.0, 0.03125);
		else:
			$CollisionShape2D.disabled = true;
		
		timer += delta
		if (timer >= delta/(Global.ENTITY_PHYSICS_SPEED*0.01)):
			timer = 0.0
			if (!exiting && !carrying && visible):
				motion = move_and_slide(motion, Vector2(0, -1));

func styleChanged():
	match (Global.CurrentStyle):
		_:
			currentSprite.hide();
			currentSprite = get_node("SpriteGround");
			currentSprite.show();
	shadow = AnimatedSprite.new();
	shadow.frames = currentSprite.frames;
	shadow.animation = currentSprite.animation;
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

func release():
	currentSprite.play("idle");
	
	var nodes = get_tree().get_nodes_in_group("Coin");
	for node in nodes:
		if (!node.is_in_group("10Coin") && !node.is_in_group("30Coin") && !node.is_in_group("50Coin")):
			if (node.powner):
				node.powner = false;
				node.show();
			if (node.p):
				node.queue_free();
	nodes = get_tree().get_nodes_in_group("Brick");
	for node in nodes:
		if (node.powner):
			node.powner = false;
			node.show();
		if (node.p):
			node.queue_free();

func _on_Area2D_body_entered(body):
	if (body.is_in_group("Character")):
		press = true;

func _on_Area2D_body_exited(body):
	if (body.is_in_group("Character")):
		press = false;
