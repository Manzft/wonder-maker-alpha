extends Node2D

onready var currentSprite = get_node("SpriteGround");

func _ready():
	styleChanged();

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
