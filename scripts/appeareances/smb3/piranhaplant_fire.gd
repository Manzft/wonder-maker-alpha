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

var motion = Vector2();

var startPos = Vector2();

var active = false;
var exiting = false;
var arrived = false;
var insided = false;

var dead = false;
var hitDead = false;

var flip_h = false;

var hitCharacter = false;

var hitSide = "";

var temporary_vspeed = 0.0;

var rendered = true;

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
	currentSprite.speed_scale = 1;
	if (get_node("../Editor").playing):
		currentSprite.scale = Vector2(3.25, 3.25);
		$SweatParticlesLeft.emitting = false;
		$SweatParticlesRight.emitting = false;
		
		#Fall Dead
		if (position.y > 1600):
			if (!dead):
				hitDead = true;
				hit("right");
				get_node("../Character/SoundShellHit").play();
		
		#Wall Dead
		if (!dead && position.y < 1600):
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
		
		startPos = position;
		arrived = false;
		exiting = false;
		flip_h = false;
		dead = false;
		hitDead = false;
		currentSprite.rotation_degrees = 0;
		currentSprite.flip_h = false;
		$CollisionShape2D.disabled = false;
		
		if (get_parent().grab && get_parent().grab_node == self):
			currentSprite.play("up");
			currentSprite.speed_scale = 2;
			currentSprite.scale = Vector2(4, 4);
			$SweatParticlesLeft.emitting = true;
			$SweatParticlesRight.emitting = true;
			$AnimationPlayer.play("draging");
		else:
			currentSprite.play("up");
			currentSprite.speed_scale = 0;
			currentSprite.frame = 0;
			if (currentSprite.scale.x > 3.25):
				currentSprite.scale = Vector2(3.25, 3.25);
			$SweatParticlesLeft.emitting = false;
			$SweatParticlesRight.emitting = false;
			$AnimationPlayer.play("RESET");
	shadow.frame = currentSprite.frame;
	shadow.animation = currentSprite.animation;
	shadow.position = currentSprite.global_position+Vector2(3*3.25, 3*3.25);
	shadow.rotation_degrees = currentSprite.rotation_degrees;
	shadow.visible = visible;
	shadow.flip_h = currentSprite.flip_h;
	shadow.flip_v = currentSprite.flip_v;

func _physics_process(delta):
	if (!get_node("../Editor").playing || !visible):
		return
	
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
				
				#Controller
				if (get_node("../Character").position.y <= position.y+16):
					currentSprite.animation = "up";
				else:
					currentSprite.animation = "down";
				
				if (get_node("../Character").position.x < position.x):
					currentSprite.flip_h = false;
				else:
					currentSprite.flip_h = true;
			else:
				motion.y += gravity*2.5;
				if (motion.y > max_fall):
					motion.y = max_fall;
		if (!dead):
			if (!arrived && is_on_floor()):
				arrived = true;
		
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
	
	motion.x = 0;
	motion.y = 0;
	
	if (hitDead):
		motion.y = jump_h*5;
	get_parent().enemyScore(position);

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
	shadow.animation = currentSprite.animation;
	shadow.scale = currentSprite.scale;
	get_node("../ShadowViewport").add_child(shadow);

func _on_Area2D_body_entered(body):
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

func _on_Area2D_body_exited(body):
	if (body.is_in_group("Character")):
		hitCharacter = false;

func _on_DeadTimer_timeout():
	hide();

func _on_Area2D2_body_entered(body):
	pass

func _on_AttackTimer_timeout():
	if (get_node("../Editor").playing && !dead):
		#Generate Fireball
		var inst = get_parent().fireball[Global.CurrentAppeareance].instance();
		inst.position = position;
		inst.position.y -= 13;
		inst.nogravity = true;
		get_parent().add_child(inst);
		if (!currentSprite.flip_h):
			inst.direction = "left";
		else:
			inst.direction = "right";
			
		inst.vdirection = currentSprite.animation;
