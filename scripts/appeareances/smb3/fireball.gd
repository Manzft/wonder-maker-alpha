extends KinematicBody2D

var motion = Vector2();

var max_speed = 500;
const jump_h  = -500;
const gravity = 50;
const max_fall = jump_h*-1;

var nogravity = false;
var vdirection = "up";

var dead = false;

var direction = "right";

var shadow : AnimatedSprite
var explosionshadow : AnimatedSprite

func eraseShadow():
	shadow.queue_free();
	explosionshadow.queue_free();

func _ready():
	shadow = AnimatedSprite.new();
	explosionshadow = AnimatedSprite.new();
	
	shadow.frames = $Sprite.frames;
	shadow.animation = $Sprite.animation;
	shadow.scale = $Sprite.scale;
	
	explosionshadow.frames = $SpriteExplosion.frames;
	explosionshadow.animation = $SpriteExplosion.animation;
	explosionshadow.scale = $SpriteExplosion.scale;
	
	get_node("../ShadowViewport").add_child(shadow);
	get_node("../ShadowViewport").add_child(explosionshadow);
	
	$AnimationPlayer.play("idle");
	
	yield(get_tree(), "idle_frame");
	
	match (direction):
		"right":
			$Sprite.play("right");
		"left":
			$Sprite.play("left");
	
	if (!nogravity):
		max_speed += abs(get_node("../Character").motion.x);
	
	if (nogravity):
		match (vdirection):
			"up":
				motion.y = -max_speed*0.25;
			"down":
				motion.y = max_speed*0.25;
	
	match (direction):
		"right":
			motion.x = max_speed;
			if (nogravity):
				motion.x = max_speed*0.25;
		"left":
			motion.x = -max_speed;
			if (nogravity):
				motion.x = -max_speed*0.25;

func _process(_delta):
	if (!get_node("../Editor").playing):
		eraseShadow();
		queue_free();
	
	$CollisionShape2D.disabled = nogravity;
	
	shadow.position = $Sprite.global_position+Vector2(3*3.25, 3*3.25);
	shadow.animation = $Sprite.animation;
	shadow.frame = $Sprite.frame;
	shadow.visible = $Sprite.visible;
	
	explosionshadow.position = $SpriteExplosion.global_position+Vector2(3*3.25, 3*3.25);
	explosionshadow.animation = $SpriteExplosion.animation;
	explosionshadow.frame = $SpriteExplosion.frame;
	explosionshadow.visible = $SpriteExplosion.visible;

func _physics_process(_delta):
	if (!dead):
		if (!nogravity):
			motion.y += gravity;
	
	if (motion.y > max_fall && !nogravity):
		motion.y = max_fall;
		
	if (position.y >= 1600 || position.y <= -16):
		eraseShadow();
		queue_free();
		
	motion = move_and_slide(motion, Vector2(0, -1));

func jump():
	motion.y = jump_h;

func _on_Area2D_body_entered(body):
	if (body == get_node("../Character") && nogravity && !get_node("../Character").invincible && !get_node("../Character").star):
		body.hit();
		motion.y = 0;
		motion.x = 0;
		dead = true;
		$Sprite.hide();
		$SpriteExplosion.frame = 0;
		$SpriteExplosion.play("default");
		$SpriteExplosion.show();
		$DeadTimer.start();
		get_node("../Character/SoundBrick").play();
	
	if (nogravity):
		return;
	
	if (body.is_in_group("Enemy") && !body.is_in_group("Solid")):
		if (!dead && !body.dead):
			motion.y = 0;
			motion.x = 0;
			dead = true;
			$Sprite.hide();
			$SpriteExplosion.frame = 0;
			$SpriteExplosion.play("default");
			$SpriteExplosion.show();
			$DeadTimer.start();
			get_node("../Character/SoundBrick").play();
			if (!body.is_in_group("Twomp") && !body.is_in_group("DryBones")):
				body.hitDead = true;
				body.hit(direction);
	elif (body.is_in_group("Solid") || body.is_in_group("Floor")):
		if (!dead):
			if (body.is_in_group("FalseFloor")):
				if (body.position.y > position.y+12):
					jump();
				else:
					motion.y = 0;
					motion.x = 0;
					dead = true;
					$Sprite.hide();
					$SpriteExplosion.frame = 0;
					$SpriteExplosion.play("default");
					$SpriteExplosion.show();
					$DeadTimer.start();
					get_node("../Character/SoundBrick").play();
			else:
				if (body.position.y-26 > position.y+12):
					jump();
				else:
					motion.y = 0;
					motion.x = 0;
					dead = true;
					$Sprite.hide();
					$SpriteExplosion.frame = 0;
					$SpriteExplosion.play("default");
					$SpriteExplosion.show();
					$DeadTimer.start();
					get_node("../Character/SoundBrick").play();

func _on_Dead_timeout():
	eraseShadow();
	queue_free();
