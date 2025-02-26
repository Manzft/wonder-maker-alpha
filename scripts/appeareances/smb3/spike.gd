extends StaticBody2D

onready var currentSprite = get_node("SpriteGround");

var hitCharacter = false;

var canSyncAnim = false;

func _ready():
	styleChanged();
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");
	canSyncAnim = true;
	$VisibilityEnabler2D.emit_signal("screen_exited")

func _process(_delta):
	if (get_node("../Editor").playing):
		currentSprite.speed_scale = 1;
		currentSprite.get_node("Shadow").frame = currentSprite.frame;
	else:
		if (!visible):
			show();
		currentSprite.speed_scale = 0;
		currentSprite.frame = 0;
		currentSprite.get_node("Shadow").frame = 0;
		
	if (hitCharacter):
		if (!get_node("../Character").invincible && !get_node("../Character").star && !get_node("../Character").died && !get_node("../Character").changingPowerup):
			get_node("../Character").hit();

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
		_:
			currentSprite.hide();
			currentSprite = get_node("SpriteGround");
			currentSprite.show();

func _on_Area2D_body_entered(body):
	if (body.is_in_group("Character")):
		hitCharacter = true;

func _on_Area2D_body_exited(body):
	if (body.is_in_group("Character")):
		hitCharacter = false;
