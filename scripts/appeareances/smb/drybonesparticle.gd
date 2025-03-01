extends Sprite

var max_walk_speed = 150.0;
var speed_increase = 0.0;
const jump_h  = -250;
const gravity = 30;
const max_fall = jump_h*-3;

var motion = Vector2(0, jump_h*5);

var dir = "";

onready var currentSprite = self

func _physics_process(delta):
	if (dir == ""):
		randomize();
		var ir = round(rand_range(0, 2));
		if (ir >= 1):
			dir = "right";
		else:
			dir = "left";
	
	motion.y += gravity*2.5;
	if (motion.y > max_fall):
		motion.y = max_fall;
	
	if (dir == "left"):
		currentSprite.rotation_degrees -= 17;
		motion.x = -max_walk_speed*2.5;
	elif (dir == "right"):
		currentSprite.rotation_degrees += 17;
		motion.x = +max_walk_speed*2.5;
	
	if (position.y >= 1600):
		queue_free();
	
	position += motion*delta;
