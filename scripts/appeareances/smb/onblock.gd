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
		#1
		if (is_in_group("OnBlock")):
			if (get_node("../Character").onoff):
				$CollisionShape2D.disabled = false;
				currentSprite.show();
				$Hide.hide();
			else:
				$CollisionShape2D.disabled = true;
				currentSprite.hide();
				$Hide.show();
		elif (is_in_group("OffBlock")):
			if (!get_node("../Character").onoff):
				$CollisionShape2D.disabled = false;
				currentSprite.show();
				$Hide.hide();
			else:
				$CollisionShape2D.disabled = true;
				currentSprite.hide();
				$Hide.show();
		#2
		if (is_in_group("OnBlock2")):
			if (get_node("../Character").onoff2):
				$CollisionShape2D.disabled = false;
				currentSprite.show();
				$Hide.hide();
			else:
				$CollisionShape2D.disabled = true;
				currentSprite.hide();
				$Hide.show();
		elif (is_in_group("OffBlock2")):
			if (!get_node("../Character").onoff2):
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
