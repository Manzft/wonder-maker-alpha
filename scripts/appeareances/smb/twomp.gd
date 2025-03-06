extends KinematicBody2D

const max_walk_speed = 250;
const jump_h  = -700;
const other_jump_h  = -250;
const gravity = 30;
const max_fall = jump_h*-1;
const other_max_fall = other_jump_h*-3;

onready var currentSprite = get_node("SpriteGround");

onready var rcd1 = get_node("RayCast");
onready var rcd2 = get_node("RayCast2");
onready var rcd3 = get_node("RayCast3");
onready var rcd4 = get_node("RayCast4");
onready var rcd5 = get_node("RayCast5");
onready var rcd6 = get_node("RayCast6");
onready var rcd7 = get_node("RayCast7");
onready var rcd8 = get_node("RayCast8");
onready var rcd9 = get_node("RayCast9");
onready var rcd10 = get_node("RayCast10");
onready var rcd11 = get_node("RayCast11");
onready var rcd12 = get_node("RayCast12");
onready var rcd13 = get_node("RayCast13");
onready var rcd14 = get_node("RayCast14");
onready var rcd15 = get_node("RayCast15");

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

var attacking = false;
var comingBack = false;

var temporary_vspeed = 0.0;

var ready = true;

var extension_grid_size = 3;
var extension_grid = [];
var default_extension_grid = [Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)];

var bye = false;

var rendered = true;

var seldirection = "down";

var canswitchonoff = true;
var canswitchonoff2 = true;

func render(group):
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

func _ready():
	Global.connect("render", self, "render");
	hide();
	styleChanged();
	for i in range(50):
		extension_grid.append([]);
	for i in range(50):
		extension_grid[i] = null;
	yield(get_tree(), "idle_frame");
	$AnimationPlayer.play("start");
	startPos = position;
	ready = true;

func setupExtensionGrids(start = false):
	var a = true;
	for i in range(extension_grid_size):
		var e = default_extension_grid[i];
		var mygrid = get_parent().calculateGrid(position.x, position.y);
		extension_grid[i] = mygrid+e;
		if (get_parent().grid_node[extension_grid[i].x][extension_grid[i].y] != null && start):
			a = false;
			bye = true;
	return a;

func setGrids(val):
	setupExtensionGrids();
	for i in range(extension_grid_size):
		get_parent().grid[extension_grid[i].x][extension_grid[i].y] = val;
		get_parent().grid_node[extension_grid[i].x][extension_grid[i].y] = self;

func _process(_delta):
	if (bye):
		queue_free();
	
	currentSprite.get_node("Shadow").frame = currentSprite.frame;
	currentSprite.get_node("Shadow").animation = currentSprite.animation;
	
	$DirectionButton/ArrowLeft.hide();
	$DirectionButton/ArrowRight.hide();
	$DirectionButton/ArrowUp.hide();
	$DirectionButton/ArrowDown.hide();
	match (seldirection):
		"down":
			$DirectionButton/ArrowDown.show();
		"up":
			$DirectionButton/ArrowUp.show();
		"left":
			$DirectionButton/ArrowLeft.show();
		"right":
			$DirectionButton/ArrowRight.show();
	
	if (get_node("../Editor").playing):
		currentSprite.speed_scale = 1;
		currentSprite.scale = Vector2(3.25, 3.25);
		$SweatParticlesLeft.emitting = false;
		$SweatParticlesRight.emitting = false;
		if (get_node("../Character").changingPowerup ||get_node("../Character").invincible || get_node("../Character").star || get_node("../Character").died):
			$StaticBody2D/CollisionShape2D.disabled = true;
		else:
			$StaticBody2D/CollisionShape2D.disabled = false;
		
		$DirectionButton.hide();
		
		if (!visible && ready && !dead):
			show();
		
		#Fall Dead
		if (position.y > 1600):
			if (!dead):
				hitDead = true;
				hit("right");
				get_node("../Character/SoundShellHit").play();
			
		#Wall Dead
		if (!dead && position.y < 1600-26):
			var mygrid = get_parent().calculateGrid(position.x+12, position.y+12);
			if (get_parent().grid_node[mygrid.x][mygrid.y] != null):
				if (!get_parent().grid_node[mygrid.x][mygrid.y].is_in_group("Twomp") &&
				get_parent().grid_node[mygrid.x][mygrid.y].is_in_group("Solid") &&
				!get_parent().grid_node[mygrid.x][mygrid.y].get_node("CollisionShape2D").disabled &&
				get_parent().grid_node[mygrid.x][mygrid.y].position == get_parent().calculateGridPosition(mygrid)):
					hitDead = true;
					hit("right");
					get_node("../Character/SoundShellHit").play();
	else:
		if (insided):
			queue_free();
		
		if (!visible && ready):
			show();
			ready = false;
		if (active):
			motion = Vector2(0.0, 0.0);
			move_and_slide(motion, Vector2(0, -1));
			active = false
			hitCharacter = false;
			position = startPos;
			currentSprite.get_node("Shadow").show();
		
		$DirectionButton.show();
		startPos = position;
		arrived = false;
		exiting = false;
		flip_h = false;
		dead = false;
		hitDead = false;
		currentSprite.rotation_degrees = 0;
		attacking = false;
		comingBack = false;
		$CollisionShape2D.disabled = false;
		$StaticBody2D/CollisionShape2D.disabled = false;
		
		if (get_parent().grab && get_parent().grab_node == self):
			currentSprite.play("attack");
			currentSprite.speed_scale = 2;
			currentSprite.scale = Vector2(4, 4);
			$SweatParticlesLeft.emitting = true;
			$SweatParticlesRight.emitting = true;
			$AnimationPlayer.play("draging");
		else:
			currentSprite.play("sleep");
			currentSprite.speed_scale = 0;
			currentSprite.frame = 0;
			if (currentSprite.scale.x > 3.25):
				currentSprite.scale = Vector2(3.25, 3.25);
			$SweatParticlesLeft.emitting = false;
			$SweatParticlesRight.emitting = false;
			$AnimationPlayer.play("RESET");
		
		#DirectionButton Gamepad Press
		if (Global.CurrentInput == "Gamepad"):
			var gamepad_pos = get_node("../Editor/GamepadCursor").rect_position+get_node("../Camera2D").position;
			var dirbutton_pos = position+$DirectionButton.rect_position;
			var dirbutton_size = $DirectionButton.rect_size;
			if (gamepad_pos.x >= dirbutton_pos.x && gamepad_pos.y >= dirbutton_pos.y &&
			gamepad_pos.x <= dirbutton_pos.x+dirbutton_size.x && gamepad_pos.y <= dirbutton_pos.y+dirbutton_size.y):
					get_node("../Editor").externalButton = true;
					if (Input.is_action_just_pressed("a")):
						_on_DirectionButton_pressed();
			else:
				get_node("../Editor").externalButton = false;

func _physics_process(delta):
	if (!get_node("../Editor").playing):
		return
	#Head Hit Raycasts
	if (!dead):
		if (seldirection == "down"):
			if (rcd1.is_colliding()): areaCollide(rcd1);
			if (rcd2.is_colliding()): areaCollide(rcd2);
			if (rcd3.is_colliding()): areaCollide(rcd3);
			if (rcd4.is_colliding()): areaCollide(rcd4);
			if (rcd5.is_colliding()): areaCollide(rcd5);
		if (seldirection == "left"):
			if (rcd6.is_colliding()): areaCollide(rcd6);
			if (rcd7.is_colliding()): areaCollide(rcd7);
			if (rcd8.is_colliding()): areaCollide(rcd8);
			if (rcd9.is_colliding()): areaCollide(rcd9);
			if (rcd10.is_colliding()): areaCollide(rcd10);
		if (seldirection == "right"):
			if (rcd11.is_colliding()): areaCollide(rcd11);
			if (rcd12.is_colliding()): areaCollide(rcd12);
			if (rcd13.is_colliding()): areaCollide(rcd13);
			if (rcd14.is_colliding()): areaCollide(rcd14);
			if (rcd15.is_colliding()): areaCollide(rcd15);
	
	if (!active && !exiting):
		active = true;
	
	if (!active && exiting):
		#jump();
		active = true;
		exiting = false;
	
	if (active && dead && hitDead):
		$CollisionShape2D.disabled = true;
		$StaticBody2D/CollisionShape2D.disabled = true;
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
			if (hitDead):
				motion.y += gravity*2.5;
				if (motion.y > other_max_fall):
					motion.y = other_max_fall;
		if (!dead):
			if (!arrived && is_on_floor()):
				arrived = true;
		if (!dead):
			if (!arrived):
				arrived = true;
			
			if (attacking):
				if (seldirection == "down"):
					motion.y += gravity
					if (motion.y > max_fall):
						motion.y = max_fall;
					currentSprite.play("attack");
				if (seldirection == "left"):
					motion.x -= gravity
					if (motion.x < -max_fall):
						motion.x = -max_fall;
					currentSprite.play("attack_side");
					currentSprite.flip_h = false;
				if (seldirection == "right"):
					motion.x += gravity
					if (motion.x > max_fall):
						motion.x = max_fall;
					currentSprite.play("attack_side");
					currentSprite.flip_h = true;
			elif (comingBack):
				if (seldirection == "down"):
					motion.y = -max_walk_speed;
					currentSprite.play("sleep");
					if (position.y <= startPos.y):
						position.y = startPos.y;
						motion.y = 0;
						comingBack = false;
				if (seldirection == "left"):
					motion.x = max_walk_speed;
					currentSprite.play("sleep");
					if (position.x >= startPos.x):
						position.x = startPos.x;
						motion.x = 0;
						comingBack = false;
				if (seldirection == "right"):
					motion.x = -max_walk_speed;
					currentSprite.play("sleep");
					if (position.x <= startPos.x):
						position.x = startPos.x;
						motion.x = 0;
						comingBack = false;
			else:
				if (seldirection == "down"):
					var distance = abs(position.x-get_node("../Character").position.x);
					if (distance <= 52*2.5):
						attacking = true;
					elif (distance <= 52*3.5):
						currentSprite.play("ready");
					else:
						currentSprite.play("sleep");
				else:
					var distance = abs(position.y-get_node("../Character").position.y);
					var distancex = abs(position.x-get_node("../Character").position.x);
					var check = false;
					if (seldirection == "right"):
						if (get_node("../Character").position.x >= position.x):
							check = true;
					if (seldirection == "left"):
						if (get_node("../Character").position.x < position.x):
							check = true;
					
					if (distance <= 52*3 && check && distancex <= 52*5):
						attacking = true;
					elif (distance <= 52*4 && check && distancex <= 52*6):
						currentSprite.play("ready_side");
						if (seldirection == "right"):
							currentSprite.flip_h = true;
						else:
							currentSprite.flip_h = false;
					else:
						currentSprite.play("sleep");
		
		if (hitCharacter && visible && !dead):
			if (!get_node("../Character").invincible && !get_node("../Character").died && !get_node("../Character").changingPowerup):
				if (!get_node("../Character").star):
					get_node("../Character").hit();
		
	#Global Movement Controller
	if (!exiting):
		if (attacking || comingBack):
			motion = move_and_slide(motion, Vector2(0, -1));

func hit(dir):
	dead = true;
	hitSide = dir;
	
	motion.x = 0;
	motion.y = 0;
	
	if (hitDead):
		motion.y = other_jump_h*5;
	currentSprite.get_node("Shadow").hide();
	get_parent().enemyScore(position);

func jump():
	motion.y = jump_h;

func areaCollide(rc):
	if (attacking && !exiting && active && !dead && !comingBack && $ComeBackTimer.is_stopped()):
		var body = rc.get_collider();
		if (body.is_in_group("Insideable") || body.is_in_group("OnOffSwitch") || body.is_in_group("OnOffSwitch2")):
			if (body.is_in_group("Brick")):
				body.hit(true);
			else:
				if (body.is_in_group("OnOffSwitch") || body.is_in_group("OnOffSwitch2")):
					if (body.is_in_group("OnOffSwitch")):
						if (canswitchonoff):
							body.hit();
							canswitchonoff = false;
							$CanSwitchOnOffTimer.start();
						else:
							body.hit(false);
					else:
						if (canswitchonoff2):
							body.hit();
							canswitchonoff2 = false;
							$CanSwitchOnOffTimer.start();
						else:
							body.hit(false);
				else:
					if (body.get_name() == "SubCollider"):
						body.get_parent().hit();
					else:
						body.hit();
			if (body.is_in_group("OnOffSwitch") || body.is_in_group("OnOffSwitch2")):
				get_node("../Character/SoundOnOffSwitch").play();
			else:
				get_node("../Character/SoundBrick").play();
		if (body.is_in_group("Solid") || body.is_in_group("Floor")):
			if (attacking):
				get_node("../Character/SoundTwompHit").play();
				yield(get_tree(), "idle_frame");
				$ComeBackTimer.start();

func styleChanged():
	match (Global.CurrentStyle):
		_:
			currentSprite.hide();
			currentSprite = get_node("SpriteGround");
			currentSprite.show();

func _on_Area2D_body_entered(body):
	if (body.is_in_group("Character") && visible && !exiting && active):
		hitCharacter = true;

func _on_Area2D_body_exited(body):
	if (body.is_in_group("Character")):
		hitCharacter = false;

func _on_DeadTimer_timeout():
	hide();

func _on_Area2D2_body_entered(body):
	pass

func _on_ComeBackTimer_timeout():
	if (attacking):
		attacking = false;
		comingBack = true;

func _on_DirectionButton_pressed():
	match (seldirection):
		"down":
			seldirection = "left";
		"left":
			seldirection = "right";
		"right":
			seldirection = "down";
	$AudioGrabMove.play();
	if (OS.get_name() == "Android"):
		get_node("../Editor").externalButton = false;

func _on_DirectionButton_mouse_entered():
	get_node("../Editor").externalButton = true;

func _on_DirectionButton_mouse_exited():
	get_node("../Editor").externalButton = false;

func _on_CanSwitchOnOffTimer_timeout():
	canswitchonoff = true;
	canswitchonoff2 = true;
