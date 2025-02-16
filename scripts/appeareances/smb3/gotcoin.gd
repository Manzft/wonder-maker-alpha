extends Node2D

onready var currentSprite = get_node("SpriteGround");

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
		_:
			currentSprite.hide();
			currentSprite = get_node("SpriteGround");
			currentSprite.show();
			
func _process(delta):
	var nodes = get_children();
	for node in nodes:
		if (node.get_name() == "Shadow"):
			node.frame = node.get_parent().frame;
			if (node.speed_scale != 0): node.speed_scale = 0;
	Global.rendering(self);

func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "start"):
		queue_free();
