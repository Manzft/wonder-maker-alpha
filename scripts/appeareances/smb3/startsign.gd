extends Node2D

onready var currentSprite = get_node("SpriteGround");

var shadow : Sprite = null

func _ready():
	styleChanged();

func _process(delta):
		shadow.position = currentSprite.global_position+Vector2(3*3.25, 3*3.25);

func styleChanged():
	match (Global.CurrentStyle):
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
	shadow.offset = currentSprite.offset;
	get_node("../ShadowViewport").add_child(shadow);
