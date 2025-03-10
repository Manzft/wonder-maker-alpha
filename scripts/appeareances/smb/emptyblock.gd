extends Node2D

onready var currentSprite = get_node("SpriteGround");

var shadow : Sprite = null;

func _process(_delta):
	if (!Global.playing):
		shadow.queue_free();
		queue_free();
	shadow.position = currentSprite.global_position+Vector2(3*3.25, 3*3.25);

func _ready():
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
			currentSprite = get_node("SpriteSnow");
			currentSprite.show();
		_:
			currentSprite.hide();
			currentSprite = get_node("SpriteGround");
			currentSprite.show();
	if (shadow == null):
		pass
	else:
		shadow.queue_free();
	shadow = Sprite.new();
	shadow.texture = currentSprite.texture;
	shadow.scale = scale
	get_node("../ShadowViewport").add_child(shadow);
