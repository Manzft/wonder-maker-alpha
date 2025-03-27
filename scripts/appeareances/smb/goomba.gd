extends KinematicBody2D

var def_max_walk_speed = 100;
var def_jump_h  = -250;
var def_gravity = 30;
var def_max_fall = def_jump_h*-3;

var max_walk_speed = 100;
var jump_h  = -250;
var gravity = 30;
var max_fall = jump_h*-3;

var timer = 0.0;

onready var currentSprite = get_node("SpriteGround");

onready var rcd1 = get_node("LeftRayCast");
onready var rcd2 = get_node("RightRayCast");

var motion = Vector2();

var startPos = Vector2();

var active = false;
var exiting = false;
var arrived = false;
var insided = false;

var dead = false;
var hitDead = false;

var flip_h = true;

var hitCharacter = false;

var hitSide = "";

var temporary_vspeed = 0.0;

var rendered = true;

var canActiveTimerStarted = false;
var canActive = false;

var shadow : AnimatedSprite
var dupsprite : AnimatedSprite

var canChain : bool = true;
var chained : bool = false;
var chainObject : Node = null;
var stopChainObject : bool = false;
var chainMoving = "";
var chainMovingTimer = 0.0;

var stopped : bool = false;

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
	dupsprite.queue_free();

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
	if (insided):
		flip_h = false;
	chainAnimation();

func chainAnimation():
	var gr = get_parent().calculateGrid(position.x, position.y);
	$AnimationPlayer.play("start");
	if (Global.isChainable(get_parent().grid[gr.x][gr.y+1])):
		get_parent().grid_node[gr.x][gr.y+1].chainAnimation();

func _process(delta):
	if (get_node("../Editor").playing):
		if (dead):
			z_index = 2;
		else:
			z_index = 1;
		
		if (chained && chainObject != null):
			if (chainObject.dead):
				chained = false;
				canChain = false;
				motion.x = -max_walk_speed;
		
		if (canChain && !chained && !dead):
			var gr = get_parent().calculateGrid(position.x, position.y);
			if (Global.isChainable(get_parent().grid[gr.x][gr.y+1])):
				chained = true;
				chainObject = get_parent().grid_node[gr.x][gr.y+1];
				arrived = true;
			
			var ir = round(rand_range(0, 1));
			if (ir == 1):
				chainMoving = "";
			else:
				chainMoving = "2"
			
		if (is_on_floor() || dead):
			canChain = false;
			
		if (stopped && chained):
			stopChainObject = true;
		if (!stopped && !dead && chained):
			stopChainObject = false;
			if (chainObject != null):
				chainObject.stopped = false;
		
		if (stopChainObject && chainObject != null):
			chainObject.stopped = true;
		
		if (chained):
			if (chainObject != null):
				if ("inbones" in chainObject):
					if (chainObject.inbones):
						chained = false;
						chainObject = null;
				if ("inshell" in chainObject):
					if (chainObject.inshell):
						chained = false;
						chainObject = null;
				
				if (chainObject.visible):
					position.y = chainObject.position.y-51;
					if (chainObject.stopped):
						if (currentSprite.animation != "idle"):
							currentSprite.animation = "idle";
					else:
						if (currentSprite.animation != "walk"):
							currentSprite.animation = "walk";
							#$AnimationPlayer.play("incolumn"+chainMoving);
					
					if (chainMoving == ""):
						currentSprite.position.x = lerp(currentSprite.position.x, -4, 0.25);
						if (currentSprite.position.x <= -3.9):
							chainMoving = "2";
					else:
						currentSprite.position.x = lerp(currentSprite.position.x, 4, 0.25);
						if (currentSprite.position.x >= 3.9):
							chainMoving = "";
						
					motion.x = chainObject.motion.x;
					
					if (abs(position.x-chainObject.position.x) > 13):
						motion.y = 0;
						chained = false;
						chainObject = null;
			else:
				chainObject = null;
				chained = false;
				
		if (!chained && currentSprite.position.x != 0):
			currentSprite.position.x = 0;
		
		currentSprite.speed_scale = 1;
		if (currentSprite.scale.x > 3.25):
			currentSprite.scale = Vector2(3.25, 3.25);
		$SweatParticlesLeft.emitting = false;
		$SweatParticlesRight.emitting = false;
		
		if (!canActiveTimerStarted):
			$CanActiveTimer.start();
			canActiveTimerStarted = true;
		
		#Fall Dead
		if (position.y > 1600):
			if (!dead):
				hitDead = true;
				hit("right");
				get_node("../Character/SoundShellHit").play();
		
		#Wall Dead
		if (!dead && position.y < 1600 && position.y > 0):
			var mygrid = get_parent().calculateGrid(position.x, position.y);
			if (get_parent().grid_node[mygrid.x][mygrid.y] != null):
				if (get_parent().grid_node[mygrid.x][mygrid.y].is_in_group("Solid") &&
				!get_parent().grid_node[mygrid.x][mygrid.y].get_node("CollisionShape2D").disabled &&
				get_parent().grid_node[mygrid.x][mygrid.y].position == get_parent().calculateGridPosition(mygrid)):
					hitDead = true;
					hit("right");
					get_node("../Character/SoundShellHit").play();
	else:
		if (insided):
			eraseShadow();
			queue_free();
		
		if (!visible):
			show();
		if (active):
			motion = Vector2(0.0, 0.0);
			move_and_slide(motion, Vector2(0, -1));
			active = false
			hitCharacter = false;
			position = startPos;
		
		chainMoving = "";
		chainMovingTimer = 0.0;
		stopped = false;
		stopChainObject = false;
		chainObject = null;
		canChain = true;
		chained = false;
		startPos = position;
		arrived = false;
		canActiveTimerStarted = false;
		canActive = false;
		exiting = false;
		flip_h = true;
		dead = false;
		hitDead = false;
		currentSprite.rotation_degrees = 0;
		$CollisionShape2D.disabled = false;
		
		if ($AnimationPlayer.current_animation != "start"):
			if (get_parent().grab && get_parent().grab_node == self):
				currentSprite.play("walk");
				currentSprite.speed_scale = 2;
				currentSprite.scale = Vector2(4, 4);
				$SweatParticlesLeft.emitting = true;
				$SweatParticlesRight.emitting = true;
				$AnimationPlayer.play("draging");
			else:
				currentSprite.play("idle");
				currentSprite.speed_scale = 0;
				currentSprite.frame = 0;
				if (currentSprite.scale.x > 3.25):
					currentSprite.scale = Vector2(3.25, 3.25);
				$SweatParticlesLeft.emitting = false;
				$SweatParticlesRight.emitting = false;
				$AnimationPlayer.play("RESET");
	
	var pos = dupsprite.position.linear_interpolate(currentSprite.global_position, 0.35)
	currentSprite.hide();
	if (Global.playing && Global.PHYSICS_INTERPOLATION && Global.ENTITY_PHYSICS_SPEED < 100.0):
		dupsprite.position = pos;
	else:
		dupsprite.position = currentSprite.global_position;
	
	if (!dupsprite.visible):
		dupsprite.position = currentSprite.global_position;
		dupsprite.show();
	
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
	if (!dead):
		if (rcd1.is_colliding()): areaCollide(rcd1);
		if (rcd2.is_colliding()): areaCollide(rcd2);
	
	if (!active && !exiting):
		active = true;
	
	if (!active && exiting):
		jump();
		active = true;
		exiting = false;
	
	if (active && dead && hitDead):
		$CollisionShape2D.disabled = true;
		if (hitSide == "right"):
			currentSprite.rotation_degrees += 17;
			motion.x = max_walk_speed*2.5;
		#	position.x += (max_walk_speed*2.5)*delta;
		if (hitSide == "left"):
			currentSprite.rotation_degrees -= 17;
			motion.x = -max_walk_speed*2.5;
	
	if (active && !exiting):
		if (dead && !hitDead):
			pass
		else:
			if (!hitDead):
				motion.y += gravity
				if (motion.y > max_fall):
					motion.y = max_fall;
			else:
				motion.y += gravity*2.5;
				if (motion.y > max_fall):
					motion.y = max_fall;
		if (!dead && !chained && !stopped):
			if (!arrived && is_on_floor() && canActive):
				arrived = true;
				
			if (arrived):
				if (is_on_floor()):
					if (flip_h):
						motion.x = -max_walk_speed;
					else:
						motion.x = max_walk_speed;
					currentSprite.play("walk");
			if (!is_on_floor()):
				if (motion.y < 0):
					currentSprite.play("jump");
				else:
					currentSprite.play("fall");
		
		if (stopped && !dead):
			currentSprite.play("idle");
			if (chained):
				position.x = chainObject.position.x;
			motion.x = 0;
		
		if (chained):
			motion.y = 0;
		
		if (hitCharacter && visible && !dead):
			if (!get_node("../Character").invincible && !get_node("../Character").died && !get_node("../Character").changingPowerup):
				if (!get_node("../Character").star):
					get_node("../Character").hit();
				else:
					hitDead = true;
					match (get_node("../Character").current_sprite.flip_h):
						false:
							hit("right");
						true:
							hit("left");
					get_node("../Character/SoundShellHit").play();
	
	#Global Movement Controller
	timer += delta
	if (timer >= delta/(Global.ENTITY_PHYSICS_SPEED*0.01)):
		timer = 0.0
		if (!exiting):
			motion = move_and_slide(motion, Vector2(0, -1));

func hit(dir):
	dead = true;
	hitSide = dir;
	temporary_vspeed = jump_h/15;
	currentSprite.play("fall");
	
	motion.x = 0;
	motion.y = 0;
	
	if (hitDead):
		motion.y = jump_h*5;
	
	get_parent().enemyScore(position);
	
	if (chained && !hitDead):
		stopChainObject = true;
	chained = false;

func jump():
	motion.y = jump_h;

func areaCollide(rc):
	if (!exiting && active && !dead):
		var body = rc.get_collider();
		var chck = false;
		if (body == self || !body.visible):
			return
		if (body.is_in_group("Enemy")):
			if (!body.dead && body.rendered):
				chck = true;
		if (body.is_in_group("Solid") || chck):
			if (rc == rcd1):
				flip_h = false;
			if (rc == rcd2):
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
	dupsprite.hide();
	dupsprite.add_to_group("SpriteClone");
	get_parent().add_child(dupsprite);

func _on_Area2D_body_entered(body):
	if (body == self):
		return
	if (body.is_in_group("Character") && visible && !exiting && active):
		hitCharacter = true;
	if (body.is_in_group("HasShell")):
		if (!dead && visible && !exiting && active && body.moving && body.inShell):
			hitDead = true;
			if (body.position.x >= position.x):
				hit("left");
			else:
				hit("right");
			get_node("../Character/SoundShellHit").play();
	if (canChain && !chained && !body.is_in_group("Character") && body.position.y > position.y):
		if (Global.isChainable(Global.getObjectCode(body))):
			if (!body.dead):
				chained = true;
				chainObject = body;
				var ir = round(rand_range(0, 1));
				if (ir == 1):
					chainMoving = "";
				else:
					chainMoving = "2"

func _on_Area2D_body_exited(body):
	if (body.is_in_group("Character")):
		hitCharacter = false;

func _on_DeadTimer_timeout():
	if (chainObject != null):
		chainObject.stopped = false;
	stopChainObject = false;
	chainObject = null;
	hide();

func _on_Area2D2_body_entered(body):
	if (body.is_in_group("Character")):
		if (!get_node("../Character").star):
			if (!dead && !body.died && !body.changingPowerup && body.motion.y != 0):
				match (get_node("../Character").current_sprite.flip_h):
					false:
						hit("right");
						var inst = load("res://scenes/appearances/smb/particles/parthit.tscn").instance();
						get_parent().add_child(inst);
						inst.position.x = position.x-12.5;
						inst.position.y = position.y-18;
					true:
						hit("left");
						var inst = load("res://scenes/appearances/smb/particles/parthit.tscn").instance();
						get_parent().add_child(inst);
						inst.position.x = position.x+12.5;
						inst.position.y = position.y-18;
				currentSprite.play("dead");
				$DeadTimer.start();
				
				body.get_node("SoundEnemyHit").play();
				
				get_node("../Character").motion.y = get_node("../Character").jump_h;
				get_node("../Character").jumping = true;
				get_node("../Character").jump_timer = 0.0;
				get_node("../Character").falling = false;

func _on_CanActiveTimer_timeout():
	canActive = true;
