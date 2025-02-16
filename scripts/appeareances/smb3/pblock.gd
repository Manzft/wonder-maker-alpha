extends StaticBody2D

onready var currentSprite = get_node("SpriteGround");

func _ready():
	styleChanged();
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");
	$VisibilityEnabler2D.emit_signal("screen_exited")

func _process(_delta):
	if (get_node("../Editor").playing):
		if (get_node("../Character").p):
			$CollisionShape2D.disabled = false;
			currentSprite.show();
			$Hide.hide();
		else:
			$CollisionShape2D.disabled = true;
			currentSprite.hide();
			$Hide.show();
	else:
		$CollisionShape2D.disabled = false;
		currentSprite.show();
		$Hide.hide();

func styleChanged():
	match (Global.CurrentStyle):
		_:
			currentSprite.hide();
			currentSprite = get_node("SpriteGround");
			currentSprite.show();
