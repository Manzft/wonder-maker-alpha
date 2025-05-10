extends Node2D

onready var currentSprite = get_node("SpriteGround");

var shadow : AnimatedSprite;

func eraseShadow():
	shadow.queue_free();

func _ready():
	get_node("../Editor").Coins += 1;
	get_node("../Editor").Score += 200;
	
	if (get_node("../Character/SoundCoin").playing):
			get_node("../Character/SoundCoin").stop();
	get_node("../Character/SoundCoin").play();
	
	$AnimationPlayer.play("start");
	
	match (Global.CurrentStyle):
		"Underground":
			currentSprite.hide();
			currentSprite = get_node("SpriteUnderground");
			currentSprite.show();
		"Ghosthouse":
			currentSprite.hide();
			currentSprite = get_node("SpriteUnderground");
			currentSprite.show();
		"Ghostforest":
			currentSprite.hide();
			currentSprite = get_node("SpriteGhostforest");
			currentSprite.show();
		"Snow":
			currentSprite.hide();
			currentSprite = get_node("SpriteUnderground");
			currentSprite.show();
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
	shadow.scale = currentSprite.scale;
	get_node("../ViewportShadow/Shadows").add_child(shadow);

func _process(delta):
	var nodes = get_children();
	for node in nodes:
		if (node.get_name() == "Shadow"):
			node.frame = node.get_parent().frame;
			if (node.speed_scale != 0): node.speed_scale = 0;
	shadow.position = currentSprite.global_position+Vector2(3*3.25, 3*3.25);
	shadow.frame = currentSprite.frame;
	shadow.animation = currentSprite.animation;
	shadow.scale = scale;
	shadow.visible = visible;
	
	$SpriteGhostforest.position = $SpriteGround.position;

func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "start"):
		eraseShadow();
		queue_free();
