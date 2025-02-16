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

func _ready():
	$AnimationPlayer.play("idle");
	
	yield(get_tree(), "idle_frame");
	
	match (direction):
		"right":
			$Sprite.play("right");
		"left":
			$Sprite.play("left");
		
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
		queue_free();
	
	$CollisionShape2D.disabled = nogravity;
	
	$Sprite/Shadow.speed_scale = 0;
	$Sprite/Shadow.frame = $Sprite.frame;
	
	$SpriteExplosion/Shadow.speed_scale = 0;
	$SpriteExplosion/Shadow.frame = $SpriteExplosion.frame;

func _physics_process(_delta):
	if (!dead):
		if (!nogravity):
			motion.y += gravity;
	
	if (motion.y > max_fall && !nogravity):
		motion.y = max_fall;
		
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
	
	if (body.is_in_group("Enemy") && !body.is_in_group("Solid") && !body.is_in_group("Twomp") && !body.is_in_group("DryBones")):
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
				body.hitDead = true;
				body.hit(direction);
				body.currentSprite.get_node("Shadow").hide();
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
	queue_free();
