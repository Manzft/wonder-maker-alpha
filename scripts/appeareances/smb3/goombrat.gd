extends KinematicBody2D

const max_walk_speed = 100;
const jump_h  = -250;
const gravity = 30;
const max_fall = jump_h*-3;

onready var currentSprite = get_node("SpriteGround");

onready var rcd1 = get_node("LeftRayCast");
onready var rcd2 = get_node("RightRayCast");

onready var downLeftRayCast = get_node("DownLeftRayCast");
onready var downRightRayCast = get_node("DownRightRayCast");

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

var canActiveTimerStarted = false;
var canActive = false;

var rendered = true;

func _ready():
	styleChanged();
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");
	startPos = position;
	if (insided):
		flip_h = false;
	$VisibilityEnabler2D.emit_signal("screen_exited")

func _process(_delta):
	currentSprite.get_node("Shadow").frame = currentSprite.frame;
	currentSprite.get_node("Shadow").animation = currentSprite.animation;
	if (get_node("../Editor").playing):
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
		
		startPos = position;
		canActiveTimerStarted = false;
		canActive = false;
		arrived = false;
		exiting = false;
		flip_h = true;
		dead = false;
		hitDead = false;
		currentSprite.rotation_degrees = 0;
		currentSprite.flip_h = true;
		$CollisionShape2D.disabled = false;
		
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
				
			if (arrived):
				if (is_on_floor()):
					if (currentSprite.flip_h):
						motion.x = -max_walk_speed;
						if (!downLeftRayCast.is_colliding()):
							currentSprite.flip_h = false;
					else:
						motion.x = max_walk_speed;
						if (!downRightRayCast.is_colliding()):
							currentSprite.flip_h = true;
					currentSprite.play("walk");
			if (!is_on_floor()):
				if (motion.y < 0):
					currentSprite.play("jump");
				else:
					currentSprite.play("fall");
		
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
					currentSprite.get_node("Shadow").hide();
		
	#Global Movement Controller
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
	currentSprite.get_node("Shadow").hide();
	get_parent().enemyScore(position);

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
				currentSprite.flip_h = false;
			if (rc == rcd2):
				currentSprite.flip_h = true;

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

func _on_Area2D_body_exited(body):
	if (body.is_in_group("Character")):
		hitCharacter = false;

func _on_DeadTimer_timeout():
	hide();

func _on_Area2D2_body_entered(body):
	if (body.is_in_group("Character")):
		if (!get_node("../Character").star):
			if (!dead && !body.died && !body.changingPowerup && body.motion.y != 0):
				match (get_node("../Character").current_sprite.flip_h):
					false:
						hit("right");
						var inst = load("res://scenes/appearances/smb3/particles/parthit.tscn").instance();
						get_parent().add_child(inst);
						inst.position.x = position.x-12.5;
						inst.position.y = position.y-18;
					true:
						hit("left");
						var inst = load("res://scenes/appearances/smb3/particles/parthit.tscn").instance();
						get_parent().add_child(inst);
						inst.position.x = position.x+12.5;
						inst.position.y = position.y-18;
				currentSprite.play("dead");
				$DeadTimer.start();
				
				body.get_node("SoundEnemyHit").play();
				
				if !(Input.is_action_pressed("a") || Input.is_action_pressed("b")):
					get_node("../Character").motion.y = get_node("../Character").jump_h/2;
					get_node("../Character").jumping = true;
				else:
					get_node("../Character").motion.y = get_node("../Character").jump_h*1.1;
					get_node("../Character").jumping = true;

func _on_CanActiveTimer_timeout():
	canActive = true;
