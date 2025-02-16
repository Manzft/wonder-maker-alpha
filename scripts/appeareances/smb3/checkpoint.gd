extends Area2D

onready var currentSprite = get_node("SpriteGround/SpriteFlag");

var extension_grid_size = 3;
var extension_grid = [];
var default_extension_grid = [Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)];

var bye = false;

var seldirection = "up";

var got = false;

func setupExtensionGrids(start = false):
	var a = true;
	for i in range(extension_grid_size):
		var e = default_extension_grid[i];
		var mygrid = get_parent().calculateGrid(position.x, position.y);
		extension_grid[i] = mygrid+e;
		if (get_parent().grid_node[extension_grid[i].x][extension_grid[i].y] != null && start):
			a = false;
			bye = true;
	return a;

func setGrids(val):
	setupExtensionGrids();
	for i in range(extension_grid_size):
		get_parent().grid[extension_grid[i].x][extension_grid[i].y] = val;
		get_parent().grid_node[extension_grid[i].x][extension_grid[i].y] = self;

func _ready():
	styleChanged();
	for i in range(50):
		extension_grid.append([]);
	for i in range(50):
		extension_grid[i] = null;
		
	var mygrid = get_parent().calculateGrid(position.x, position.y);
	mygrid.y += 1;
	if (Global.CheckpointGrid == mygrid):
		got = true;
		currentSprite.play("mario");
	
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");
	$VisibilityEnabler2D.emit_signal("screen_exited")

func _process(_delta):
	if (bye):
		queue_free();
		
	$SpriteGround/SpriteFlag/Shadow.animation = $SpriteGround/SpriteFlag.animation;
		
	$DirectionButton/ArrowLeft.hide();
	$DirectionButton/ArrowRight.hide();
	$DirectionButton/ArrowUp.hide();
	$DirectionButton/ArrowDown.hide();
	match (seldirection):
		"down":
			$DirectionButton/ArrowDown.show();
			$SpriteGround.rotation_degrees = 180;
			$SpriteGround/SpriteFlag/Shadow.position = Vector2(-3, -3);
		"up":
			$DirectionButton/ArrowUp.show();
			$SpriteGround.rotation_degrees = 0;
			$SpriteGround/SpriteFlag/Shadow.position = Vector2(3, 3);
		"left":
			$DirectionButton/ArrowLeft.show();
			$SpriteGround.rotation_degrees = 270;
			$SpriteGround/SpriteFlag/Shadow.position = Vector2(-3, 3);
		"right":
			$DirectionButton/ArrowRight.show();
			$SpriteGround.rotation_degrees = 90;
			$SpriteGround/SpriteFlag/Shadow.position = Vector2(3, -3);
	
	if (get_node("../Editor").playing):
		$DirectionButton.hide();
	else:
		$DirectionButton.show();
		got = false;
		$AnimationPlayer.play("RESET");
		$SpriteGround/SpriteFlag.play("default");

func styleChanged():
	match (Global.CurrentStyle):
		_:
			pass

func _on_Checkpoint_body_entered(body):
	if (body == get_node("../Character") && !got):
		$AnimationPlayer.play("got");
		got = true;
		var mygrid = get_parent().calculateGrid(position.x, position.y);
		mygrid.y += 1;
		Global.CheckpointGrid = mygrid;
		$AudioCheckpoint.play();
		
# For newer appeareances
#		if (body.currentPowerup == "small"):
#			if (body.get_node("PowerupGot").playing):
#				body.get_node("PowerupGot").stop();
#			body.get_node("PowerupGot").play();
#			body.powerup("Mushroom");
		
		yield(get_tree().create_timer(0.4), "timeout");
		currentSprite.play("mario");

func _on_DirectionButton_pressed():
	match (seldirection):
		"down":
			seldirection = "left";
		"left":
			seldirection = "up";
		"up":
			seldirection = "right";
		"right":
			seldirection = "down";
	$AudioGrabMove.play();
	if (OS.get_name() == "Android"):
		get_node("../Editor").externalButton = false;

func _on_DirectionButton_mouse_entered():
	get_node("../Editor").externalButton = true;

func _on_DirectionButton_mouse_exited():
	get_node("../Editor").externalButton = false;
