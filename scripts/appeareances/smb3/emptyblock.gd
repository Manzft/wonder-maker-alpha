extends Node2D

onready var currentSprite = get_node("SpriteGround");

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
		_:
			currentSprite.hide();
			currentSprite = get_node("SpriteGround");
			currentSprite.show();
