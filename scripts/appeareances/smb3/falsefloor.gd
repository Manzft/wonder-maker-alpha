extends Node2D

var floorlevel = false;
var endlevel = false;

onready var currentSprite = get_node("SpriteGround");

func _ready():
	styleChanged();

func styleChanged():
	match (Global.CurrentStyle):
		"Underground":
			currentSprite.hide();
			currentSprite = get_node("SpriteUnderground");
			currentSprite.show();
		"Ghosthouse":
			currentSprite.hide();
			currentSprite = get_node("SpriteUnderground");
			currentSprite.show();
		"Sky":
			currentSprite.hide();
			currentSprite = get_node("SpriteSky");
			currentSprite.show();
		"Forest":
			currentSprite.hide();
			currentSprite = get_node("SpriteForest");
			currentSprite.show();
		"Snow":
			currentSprite.hide();
			currentSprite = get_node("SpriteSnow");
			currentSprite.show();
		"Desert":
			currentSprite.hide();
			currentSprite = get_node("SpriteDesert");
			currentSprite.show();
		"Ghostforest":
			currentSprite.hide();
			currentSprite = get_node("SpriteGhostforest");
			currentSprite.show();
		_:
			currentSprite.hide();
			currentSprite = get_node("SpriteGround");
			currentSprite.show();
