extends KinematicBody2D

const max_walk_speed = 100;
var speed_increase = 0.0;
const jump_h  = -250;
const gravity = 30;
const max_fall = jump_h*-3;

onready var currentSprite = get_node("SpriteGround");

onready var rcd1 = get_node("LeftRayCast");
onready var rcd2 = get_node("RightRayCast");

var motion = Vector2();

var startPos = Vector2();

var active = false;
var exiting = false;
var arrived = false;
var insided = false;

var waking = false;

var dead = false;
var hitDead = false;

var hitCharacter = false;

var hitSide = "";

var temporary_vspeed = 0.0;

var inShell = false;
var moving = false;

var canAttack = true;

var rendered = true;

var canActiveTimerStarted = false;
var canActive = false;

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
	styleChanged();
	currentSprite.flip_h = true;
	yield(get_tree(), "idle_frame");
	$AnimationPlayer.play("start");
	startPos = position;
	if (insided):
		currentSprite.flip_h = false;

func _process(_delta):
	currentSprite.get_node("Shadow").frame = currentSprite.frame;
	currentSprite.get_node("Shadow").animation = currentSprite.animation;
	currentSprite.get_node("Shadow").flip_h = currentSprite.flip_h;
	currentSprite.get_node("Shadow").flip_v = currentSprite.flip_v;
	
	if (get_node("../Editor").playing):
		currentSprite.speed_scale = 1;
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
		if (!dead && position.y < 1600 && canAttack):
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
			queue_free();
		
		if (!visible):
			show();
		if (active):
			motion = Vector2(0.0, 0.0);
			move_and_slide(motion, Vector2(0, -1));
			active = false
			hitCharacter = false;
			position = startPos;
			currentSprite.get_node("Shadow").show();
			$AnimationPlayer.play("RESET");
		
		startPos = position;
		canActiveTimerStarted = false;
		canActive = false;
		inShell = false;
		arrived = false;
		exiting = false;
		currentSprite.flip_h = true;
		currentSprite.flip_v = false;
		dead = false;
		hitDead = false;
		canAttack = true;
		waking = false;
		moving = false;
		currentSprite.rotation_degrees = 0;
		currentSprite.position.y = -14;
		$CollisionShape2D.disabled = false;
		
		if (get_parent().grab && get_parent().grab_node == self):
			currentSprite.play("walk");
			currentSprite.speed_scale = 2;
			currentSprite.scale = Vector2(4, 4);
			$SweatParticlesLeft.emitting = true;
			$SweatParticlesRight.emitting = true;
			$AnimationPlayer.play("draging");
		else:
			currentSprite.play("walk");
			currentSprite.speed_scale = 0;
			currentSprite.frame = 0;
			if (currentSprite.scale.x > 3.25):
				currentSprite.scale = Vector2(3.25, 3.25);
			$SweatParticlesLeft.emitting = false;
			$SweatParticlesRight.emitting = false;
			$AnimationPlayer.play("RESET");

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
		if (!dead):
			if (!arrived && is_on_floor() && canActive):
				arrived = true;
			if (!inShell):
				if (arrived):
					if (is_on_floor()):
						if (currentSprite.flip_h):
							motion.x = -max_walk_speed;
						else:
							motion.x = max_walk_speed;
						currentSprite.play("walk");
					else:
						if (motion.y < 0):
							currentSprite.play("jump");
						else:
							currentSprite.play("fall");
			elif (inShell && moving):
				if (currentSprite.flip_h):
					motion.x = -max_walk_speed*4.25-speed_increase;
				else:
					motion.x = max_walk_speed*4.25+speed_increase;
				currentSprite.play("moving");
		
		var chck = (!inShell && !moving) || (inShell && moving);
		if (hitCharacter && visible && !dead && chck):
			if (!get_node("../Character").invincible && !get_node("../Character").died && !get_node("../Character").changingPowerup):
				if (!get_node("../Character").star && canAttack):
					get_node("../Character").hit();
				elif (canAttack && get_node("../Character").star):
					hitDead = true;
					match (get_node("../Character").current_sprite.flip_h):
						false:
							hit("right");
						true:
							hit("left");
					get_node("../Character/SoundShellHit").play();
		
	#Global Movement Controller
	if (!exiting):
		motion = move_and_slide(motion, Vector2(0, -1));

func hit(dir, inshell = false, byblock = false, move = false):
	$AnimationPlayer.play("RESET");
	$BigWakeTimer.stop();
	waking = false;
	if (move):
		currentSprite.play("moving");
		match (dir):
			"left":
				currentSprite.flip_h = true;
			"right":
				currentSprite.flip_h = false;
		speed_increase = abs(get_node("../Character").motion.x/2);
		moving = true;
	elif (!inshell):
		dead = true;
		hitDead = true;
		hitSide = dir;
		currentSprite.play("dead");
		currentSprite.position.y = 0;
		currentSprite.get_node("Shadow").hide();
		dead = true;
		
		motion.x = 0;
		motion.y = 0;
		if (hitDead):
			motion.y = jump_h*5;
		currentSprite.get_node("Shadow").hide();
		get_parent().enemyScore(position);
	else:
		currentSprite.play("down");
		inShell = true;
		$BigWakeTimer.start();
		motion.x = 0;

func jump(var down = false):
	if (down):
		motion.y = jump_h*3;
		currentSprite.flip_v = true;
		currentSprite.position.y = 16;
	else:
		motion.y = jump_h;

func areaCollide(rc):
	if (!exiting && active && !dead):
		var body = rc.get_collider();
		var chck = false;
		var invBlockCheck = false;
		if (body.is_in_group("InvisibleLuckyblock") && !moving && !inShell):
			invBlockCheck = true;
		if (body == self || !body.visible || invBlockCheck):
			return
		if (body.is_in_group("Enemy") && !inShell && !moving):
			if (!body.dead && body.rendered):
				chck = true;
		if (body.is_in_group("Solid") || chck):
			if (rc == rcd1):
				currentSprite.flip_h = false;
			if (rc == rcd2):
				currentSprite.flip_h = true;
			if (moving && inShell && !body.is_in_group("OnOffSwitch") && !body.is_in_group("OnOffSwitch2")):
				get_node("../Character/SoundBrick").play();
			if (body.is_in_group("Insideable") || body.is_in_group("OnOffSwitch") || body.is_in_group("OnOffSwitch2")):
				if (moving && inShell):
					if (body.is_in_group("Brick")):
						body.hit(true);
					else:
						if (body.get_name() == "SubCollider"):
							body.get_parent().hit();
						else:
							body.hit();
					if (body.is_in_group("OnOffSwitch") || body.is_in_group("OnOffSwitch2")):
						get_node("../Character/SoundOnOffSwitch").play();

func styleChanged():
	match (Global.CurrentStyle):
		_:
			currentSprite.hide();
			currentSprite = get_node("SpriteGround");
			currentSprite.show();

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
			currentSprite.get_node("Shadow").hide();
			get_node("../Character/SoundShellHit").play();

func _on_Area2D_area_entered(area):
	if (area.is_in_group("Coin") && area.visible):
		if (!dead && visible && !exiting && active && inShell && moving):
			get_node("../Character/SoundCoin").play();
			get_parent().get_node("Editor").Coins += 1;
			get_node("../Editor").Score += 200;
			area.hide();

func _on_Area2D_body_exited(body):
	if (body.is_in_group("Character")):
		hitCharacter = false;

func _on_DeadTimer_timeout():
	hide();

func _on_Area2D2_body_entered(body):
	if (body.is_in_group("Character")):
		if (!get_node("../Character").star):
			if (!inShell && !moving):
				if (!dead && !body.died && !body.is_on_floor() && !body.changingPowerup):
					match (get_node("../Character").current_sprite.flip_h):
						false:
							hit("right", true);
							var inst = load("res://scenes/appearances/smb/particles/parthit.tscn").instance();
							get_parent().add_child(inst);
							inst.position.x = position.x-12.5;
							inst.position.y = position.y-18;
						true:
							hit("left", true);
							var inst = load("res://scenes/appearances/smb/particles/parthit.tscn").instance();
							get_parent().add_child(inst);
							inst.position.x = position.x+12.5;
							inst.position.y = position.y-18;
					currentSprite.play("down");
					#$DeadTimer.start();
					
					body.get_node("SoundEnemyHit").play();
					
					if !(Input.is_action_pressed("a") || Input.is_action_pressed("b")):
						get_node("../Character").motion.y = get_node("../Character").jump_h*0.7;
						get_node("../Character").jumping = true;
					else:
						get_node("../Character").motion.y = get_node("../Character").jump_h*1;
						get_node("../Character").jumping = true;
					get_parent().enemyScore(position);
			elif (inShell && !moving):
				if (!dead && !body.died && !body.changingPowerup):
					if (get_node("../Character").position.x >= position.x):
						hit("left", false, false, true);
						var inst = load("res://scenes/appearances/smb/particles/parthit.tscn").instance();
						get_parent().add_child(inst);
						inst.position.x = position.x-12.5;
						inst.position.y = position.y-18;
					else:
						hit("right", false, false, true);
						var inst = load("res://scenes/appearances/smb/particles/parthit.tscn").instance();
						get_parent().add_child(inst);
						inst.position.x = position.x+12.5;
						inst.position.y = position.y-18;
					
					canAttack = false;
					$AttackTimer.start();
					
					body.get_node("SoundShellHit").play();
			elif (inShell && moving):
				if (!dead && !body.died && !body.is_on_floor() && !body.changingPowerup):
					currentSprite.play("down");
					#$DeadTimer.start();
					moving = false;
					motion.x = 0;
					
					$BigWakeTimer.start();
					
					if (get_node("../Character").position.x < position.x):
						hitSide = "left";
						var inst = load("res://scenes/appearances/smb/particles/parthit.tscn").instance();
						get_parent().add_child(inst);
						inst.position.x = position.x-12.5;
						inst.position.y = position.y-18;
					elif (get_node("../Character").position.x >= position.x):
						hitSide = "right";
						var inst = load("res://scenes/appearances/smb/particles/parthit.tscn").instance();
						get_parent().add_child(inst);
						inst.position.x = position.x+12.5;
						inst.position.y = position.y-18;
					
					body.get_node("SoundEnemyHit").play();
					
					if !(Input.is_action_pressed("a") || Input.is_action_pressed("b")):
						get_node("../Character").motion.y = get_node("../Character").jump_h/2;
						get_node("../Character").jumping = true;
					else:
						get_node("../Character").motion.y = get_node("../Character").jump_h*1.1;
						get_node("../Character").jumping = true;
					get_parent().enemyScore(position);

func _on_AttackTimer_timeout():
	canAttack = true;

func _on_WakeTimer_timeout():
	if (waking):
		$AnimationPlayer.play("RESET");
		waking = false;
		currentSprite.play("walk");
		inShell = false;
		currentSprite.flip_v = false;
		currentSprite.position.y = -14;

func _on_BigWakeTimer_timeout():
	if (!moving && inShell && !dead):
		waking = true;
		$WakeTimer.start();
		$AnimationPlayer.play("waking");
		currentSprite.play("waking");

func _on_CanActiveTimer_timeout():
	canActive = true;
