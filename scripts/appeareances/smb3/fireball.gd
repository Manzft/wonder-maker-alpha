extends KinematicBody2D

var motion = Vector2();

var def_max_speed = 500;
var def_jump_h  = -500;
var def_gravity = 50;
var def_max_fall = def_jump_h*-1;

var max_speed = 0;
var jump_h  = 0;
var gravity = 0;
var max_fall = 0;

var additionalSpeed : Vector2 = Vector2(0, 0);

var timer = 0.0;

var nogravity = false;
var vdirection = "up";

var spriteVisible = true;

var dead = false;

var direction = "right";

var shadow : AnimatedSprite
var explosionshadow : AnimatedSprite
var dupsprite : AnimatedSprite

var limit_time = 0.0;

func eraseShadow():
	dupsprite.queue_free();
	shadow.queue_free();
	explosionshadow.queue_free();

func _ready():
	limit_time = Global.ENTITY_PHYSICS_SPEED*0.01;
	max_speed = def_max_speed/(Global.ENTITY_PHYSICS_SPEED*0.01);
	jump_h  = def_jump_h/(Global.ENTITY_PHYSICS_SPEED*0.01);
	gravity = def_gravity/(Global.ENTITY_PHYSICS_SPEED*0.01);
	max_fall = def_max_fall/(Global.ENTITY_PHYSICS_SPEED*0.01);
	
	shadow = AnimatedSprite.new();
	explosionshadow = AnimatedSprite.new();
	dupsprite = AnimatedSprite.new();
	
	shadow.frames = $Sprite.frames;
	shadow.animation = $Sprite.animation;
	shadow.scale = $Sprite.scale;
	
	explosionshadow.frames = $SpriteExplosion.frames;
	explosionshadow.animation = $SpriteExplosion.animation;
	explosionshadow.scale = $SpriteExplosion.scale;
	
	dupsprite.frames = $Sprite.frames;
	dupsprite.animation = $Sprite.animation;
	dupsprite.scale = $Sprite.scale;
	dupsprite.position = $Sprite.global_position;
	dupsprite.light_mask = $Sprite.light_mask;
	dupsprite.add_to_group("SpriteClone");
	
	get_node("../ViewportShadow/Shadows").add_child(shadow);
	get_node("../ViewportShadow/Shadows").add_child(explosionshadow);
	get_parent().add_child(dupsprite);
	
	yield(get_tree(), "idle_frame")
	
	match (direction):
		"right":
			$Sprite.play("right");
		"left":
			$Sprite.play("left");
	
	if (!nogravity):
		max_speed += abs(get_node("../Character").motion.x/(Global.ENTITY_PHYSICS_SPEED*0.01))/2
	
	if (nogravity):
		match (vdirection):
			"up":
				motion.y = -max_speed*0.25;
			"down":
				motion.y = max_speed*0.25;
	
	match (direction):
		"right":
			motion.x = max_speed*1.25;
			if (nogravity):
				motion.x = max_speed*0.25;
		"left":
			motion.x = -max_speed*1.25;
			if (nogravity):
				motion.x = -max_speed*0.25;
	
	yield(get_tree(), "idle_frame");
	
	motion.x += additionalSpeed.x;
	motion.y += additionalSpeed.y;

func _process(_delta):
	if (!get_node("../Editor").playing):
		eraseShadow();
		queue_free();
	
	if (nogravity):
		$CollisionShape2D.disabled = true
	
	var position_difference = dupsprite.position.distance_to($Sprite.global_position)
	var pos = dupsprite.position.linear_interpolate($Sprite.global_position, 0.35)
	$Sprite.hide();
	if (Global.playing && Global.PHYSICS_INTERPOLATION && Global.ENTITY_PHYSICS_SPEED < 100.0):
		dupsprite.position = pos;
	else:
		dupsprite.position = $Sprite.global_position;
	
	dupsprite.frame = $Sprite.frame;
	dupsprite.animation = $Sprite.animation;
	dupsprite.rotation_degrees = $Sprite.rotation_degrees+rotation_degrees;
	dupsprite.visible = spriteVisible;
	dupsprite.flip_h = $Sprite.flip_h;
	dupsprite.flip_h = $Sprite.flip_v;
	dupsprite.scale = $Sprite.scale;
	dupsprite.z_index = z_index;
	
	$Light2D.global_position = dupsprite.position;
	
	shadow.position = dupsprite.position+Vector2(3*3.25, 3*3.25);
	shadow.animation = $Sprite.animation;
	shadow.frame = $Sprite.frame;
	shadow.visible = dupsprite.visible;
	
	explosionshadow.position = $SpriteExplosion.global_position+Vector2(3*3.25, 3*3.25)
	explosionshadow.animation = $SpriteExplosion.animation
	explosionshadow.frame = $SpriteExplosion.frame
	explosionshadow.visible = $SpriteExplosion.visible

func _physics_process(delta):
	if (!dead):
		if (!nogravity):
			motion.y += gravity;
	
	if (motion.y > max_fall && !nogravity):
		motion.y = max_fall;
		
	if (position.y >= 1600 || position.y <= -16):
		eraseShadow();
		queue_free();
	
	timer += delta
	if (timer >= delta/limit_time):
		timer = 0.0
		motion = move_and_slide(motion, Vector2(0, -1));

func jump():
	motion.y = jump_h;

func _on_Area2D_body_entered(body):
	if (!dead && body == get_node("../Character") && nogravity && !get_node("../Character").invincible && !get_node("../Character").star):
		body.hit();
		motion.y = 0;
		motion.x = 0;
		dead = true;
		spriteVisible = false;
		$SpriteExplosion.frame = 0;
		$SpriteExplosion.play("default");
		$SpriteExplosion.show();
		$DeadTimer.start();
		$CollisionShape2D.disabled = true
		get_node("../Character/SoundBrick").play();
	
	if (body.is_in_group("Enemy") && !body.is_in_group("Solid") && !nogravity):
		if (!dead && !body.dead):
			motion.y = 0;
			motion.x = 0;
			dead = true;
			spriteVisible = false;
			$SpriteExplosion.frame = 0;
			$SpriteExplosion.play("default");
			$SpriteExplosion.show();
			$DeadTimer.start();
			$CollisionShape2D.disabled = true
			get_node("../Character/SoundBrick").play();
			if (!body.is_in_group("Twomp") && !body.is_in_group("DryBones")):
				body.hitDead = true;
				body.hit(direction);
	elif (body.is_in_group("Solid") || body.is_in_group("Floor")):
		if (!dead):
			if (body.is_in_group("FalseFloor")):
				if (body.position.y > position.y+12 && !nogravity):
					jump();
				else:
					motion.y = 0;
					motion.x = 0;
					dead = true;
					spriteVisible = false;
					$SpriteExplosion.frame = 0;
					$SpriteExplosion.play("default");
					$SpriteExplosion.show();
					$DeadTimer.start();
					$CollisionShape2D.disabled = true
					get_node("../Character/SoundBrick").play();
			else:
				if (body.position.y-26 > position.y+12 && !nogravity):
					jump();
				else:
					motion.y = 0;
					motion.x = 0;
					dead = true;
					spriteVisible = false;
					$SpriteExplosion.frame = 0;
					$SpriteExplosion.play("default");
					$SpriteExplosion.show();
					$DeadTimer.start();
					$CollisionShape2D.disabled = true
					get_node("../Character/SoundBrick").play();

func _on_Dead_timeout():
	eraseShadow();
	queue_free();
