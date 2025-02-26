extends StaticBody2D

onready var currentSprite = get_node("SpriteGround");

var charonme = false;

func _ready():
	styleChanged();
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");
	$VisibilityEnabler2D.emit_signal("screen_exited")

func _process(_delta):
	if (get_node("../Editor").playing):
		if (get_node("../Character").position.y <= position.y-49):
			$CollisionShape2D.disabled = false;
		else:
			$CollisionShape2D.disabled = true;
		
		if (get_node("../Character").currentPowerup == "small"):
			$Area2D/CollisionShape2D.position.y = -49;
		else:
			$Area2D/CollisionShape2D.position.y = -49-20;

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
		if (!charonme && !body.died && !body.course_clear):
			body.clouds += 1;
			charonme = true;

func _on_Area2D_body_exited(body):
	if (body.is_in_group("Character")):
		if (charonme):
			charonme = false;
			get_node("../Character").clouds -= 1;
