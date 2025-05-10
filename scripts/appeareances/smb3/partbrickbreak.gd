extends Sprite

const gravity = 45;
var flip = false;
var motioned = false;

var motion = Vector2(0.0, 0.0);

var shadow : Sprite

func eraseShadow():
	shadow.queue_free();

func _ready():
	var app = "smb";
	
	match (Global.CurrentAppeareance):
		Global.APP_SMB:
			app = "smb";
		Global.APP_SMB3:
			app = "smb3";
	
	match (Global.CurrentStyle):
		"Underground":
			texture = load("res://sprites/appeareances/"+app+"/blocks/underground/particle_brick_break_underground.png");
		"Ghosthouse":
			texture = load("res://sprites/appeareances/"+app+"/blocks/underground/particle_brick_break_underground.png");
		"Ghostforest":
			texture = load("res://sprites/appeareances/"+app+"/blocks/ghostforest/particle_brick_break.png");
		"Snow":
			texture = load("res://sprites/appeareances/"+app+"/blocks/snow/particle_brick_break_snow.png");
		_:
			texture = load("res://sprites/appeareances/"+app+"/blocks/ground/particle_brick_break_ground.png");
	if (shadow == null):
		pass
	else:
		shadow.queue_free();
	shadow = Sprite.new();
	shadow.texture = texture;
	shadow.scale = scale
	shadow.position = position+Vector2(3*3.25, 3*3.25);
	get_node("../ViewportShadow/Shadows").add_child(shadow);

func _physics_process(delta):
	if (!Global.playing):
		eraseShadow();
		queue_free();
	if (!motioned):
		randomize();
		var rand = round(rand_range(60, 300));
		if (flip):
			motion.x = rand*-1;
		else:
			motion.x = rand;
		rand = round(rand_range(-540, -780));
		motion.y = rand;
		motioned = true;
	
	if (flip):
		rotation_degrees -= 15;
	else:
		rotation_degrees += 15;
	
	motion.y += gravity;
	if (motion.y >= 900.0):
		motion.y = 900.0;
	
	motion.x = lerp(motion.x, 0.0, 0.01)
	
	position += motion*delta;
	
	shadow.position = position+Vector2(3*3.25, 3*3.25);
	shadow.rotation_degrees = rotation_degrees;

func _on_Timer_timeout():
	shadow.queue_free();
	queue_free();

func _on_PartHit_animation_finished():
	_on_Timer_timeout();
