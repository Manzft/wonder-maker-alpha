extends StaticBody2D

onready var currentSprite = get_node("SpriteGround");

var down = false;
var downVelocity = 0.0;
var startPos = Vector2();
var moveCharacter = false;

func _ready():
	styleChanged();
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");
	startPos = position;
	$VisibilityEnabler2D.emit_signal("screen_exited")

func _process(delta):
	$SpriteUnderground.scale = $SpriteGround.scale;
	$SpriteUnderground.position = $SpriteGround.position;
	$SpriteGhostforest.scale = $SpriteGround.scale;
	$SpriteGhostforest.position = $SpriteGround.position;
	if (get_node("../Editor").playing):
		if (get_node("../Character").position.y <= position.y-49):
			$CollisionShape2D.disabled = false;
		else:
			$CollisionShape2D.disabled = true;
		
		if (get_node("../Character").currentPowerup == "small"):
			$Area2D/CollisionShape2D.position.y = -49;
		else:
			$Area2D/CollisionShape2D.position.y = -49-20;
	else:
		if (down || !$ToFallTimer.is_stopped() || !$FallTimer.is_stopped() || currentSprite.frame == 1):
			currentSprite.frame = 0;
			$AnimationPlayer.play("RESET");
			down = false;
			$ToFallTimer.stop();
			$FallTimer.stop();
			position = startPos;
			downVelocity = 0.0;
			moveCharacter = false;
		startPos = position;
	
	if (down):
		position.y += (5+downVelocity)/0.016*delta;
		if (moveCharacter && get_node("../Character").donuts > 0 && get_node("../Character").clouds <= 0):
			get_node("../Character").position.y += (5+downVelocity)/0.016*delta/get_node("../Character").donuts;
		downVelocity += (0.125/0.016)*delta;

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

func _on_Area2D_body_entered(body):
	if (body.is_in_group("Character")):
		if ($AnimationPlayer.current_animation != "tofall" && currentSprite.frame == 0 && !down && !body.died && !body.course_clear):
			$AnimationPlayer.play("tofall");
			$ToFallTimer.start();
			currentSprite.frame = 1;
			if (body.donuts > 0):
				body.donuts = 0;
				var nodes = get_tree().get_nodes_in_group("Donut");
				for node in nodes:
					if (node.moveCharacter):
						node.moveCharacter = false;
				yield(get_tree(), "idle_frame");
				body.position.y = position.y-52;

func _on_Area2D_body_exited(body):
	if (body.is_in_group("Character")):
		if (!$ToFallTimer.is_stopped() && !down):
			$ToFallTimer.stop();
			$AnimationPlayer.play("RESET");
			currentSprite.frame = 0;
		if (moveCharacter):
			moveCharacter = false;
			get_node("../Character").donuts -= 1;

func _on_ToFallTimer_timeout():
	$AnimationPlayer.play("RESET");
	$FallTimer.start();
	down = true;
	moveCharacter = true;
	get_node("../Character").donuts += 1;
	
func _on_FallTimer_timeout():
	down = false;
	position = startPos;
	currentSprite.frame = 0;
	$AnimationPlayer.play("start");
	downVelocity = 0.0;
	if (moveCharacter):
		moveCharacter = false;
		get_node("../Character").donuts -= 1;
