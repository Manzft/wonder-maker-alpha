extends StaticBody2D

onready var currentSprite = get_node("SpriteGround");

func _ready():
	styleChanged();
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");
	$VisibilityEnabler2D.emit_signal("screen_exited")

func _process(_delta):
	$SpriteUnderground.scale = $SpriteGround.scale;
	$SpriteUnderground.position = $SpriteGround.position;
	$SpriteGhostforest.scale = $SpriteGround.scale;
	$SpriteGhostforest.position = $SpriteGround.position;

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
