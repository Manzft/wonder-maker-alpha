extends KinematicBody2D

const max_walk_speed = 100;
const jump_h  = -250;
const gravity = 30;
const max_fall = jump_h*-3;

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

func _ready():
	styleChanged();
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");
	startPos = position;
	$VisibilityEnabler2D.emit_signal("screen_exited")

func _process(_delta):
	currentSprite.speed_scale = 1;
	currentSprite.get_node("Shadow").frame = currentSprite.frame;
	currentSprite.get_node("Shadow").animation = currentSprite.animation;
	currentSprite.get_node("Shadow").flip_h = currentSprite.flip_h;
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
					currentSprite.get_node("Shadow").hide();
		
	#Global Movement Controller
	if (!exiting):
		motion = move_and_slide(motion, Vector2(0, -1));

func hit(dir):
	dead = true;
	hitSide = dir;
	
	motion.x = 0;
	motion.y = 0;
	
	if (hitDead):
		motion.y = jump_h*5;
	currentSprite.get_node("Shadow").hide();
	get_parent().enemyScore(position);

func jump():
	motion.y = jump_h;

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
