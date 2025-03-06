extends StaticBody2D

onready var currentSprite = get_node("SpriteGround");

var charonme = false;

func render(group):
	if (group != ""):
		if (!is_in_group(group)):
			return
	var scrwidth = OS.get_window_size().x;
	var scrheight = OS.get_window_size().y;
	var multiplier = 720/scrheight;
	var finalscrwidth = scrwidth * multiplier;
	var distance = abs(position.x-Global.campos.x);
	if (distance-(finalscrwidth/2) > finalscrwidth*0.5):
		set_process(false);
		set_physics_process(false);
	else:
		set_process(true);
		set_physics_process(true);

func _ready():
	Global.connect("render", self, "render");
	styleChanged();
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");

func _process(_delta):
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
		if (!charonme && !body.died && !body.course_clear):
			body.clouds += 1;
			charonme = true;

func _on_Area2D_body_exited(body):
	if (body.is_in_group("Character")):
		if (charonme):
			charonme = false;
			get_node("../Character").clouds -= 1;
