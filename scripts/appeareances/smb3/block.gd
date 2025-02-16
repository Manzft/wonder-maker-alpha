extends StaticBody2D

onready var currentSprite = get_node("SpriteGround");

var mycampos = Vector2(0, 0);

func _ready():
	styleChanged();
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");
	$VisibilityEnabler2D.emit_signal("screen_exited")

func _process(_delta):
	pass
	#perspective();

func perspective():
	if (mycampos != Global.campos):
		mycampos = Global.campos;
		
		var camdif = Vector2(get_node("../Editor/GamepadCursorDefaultPosition").rect_position.x,
		get_node("../Editor/GamepadCursorDefaultPosition").rect_position.y);
		
		var center = Global.campos+camdif;
		
		var mydif = Vector2(0, 0);
		mydif.x = position.x-center.x;
		mydif.y = position.y-center.y;
		
		$Viewport/Camera.translation.x = (mydif.x*0.02)*-1;
		$Viewport/Camera.translation.y = (mydif.y*0.02)*-1;
		
		var campos = Vector2($Viewport/Camera.translation.x, $Viewport/Camera.translation.y);
		$Sprite.position = Vector2(campos.x*26, campos.y*26);

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
		_:
			currentSprite.hide();
			currentSprite = get_node("SpriteGround");
			currentSprite.show();
