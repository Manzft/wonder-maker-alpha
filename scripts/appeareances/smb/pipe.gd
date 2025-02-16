extends StaticBody2D

onready var currentSprite = get_node("SpriteGround");

var extension_grid_size = 3;
var extension_grid = [];
var default_extension_grid = [Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)];

var bye = false;

var seldirection = "up";

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
	
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");
	$VisibilityEnabler2D.emit_signal("screen_exited")

func _process(_delta):
	if (bye):
		queue_free();
		
	$DirectionButton/ArrowLeft.hide();
	$DirectionButton/ArrowRight.hide();
	$DirectionButton/ArrowUp.hide();
	$DirectionButton/ArrowDown.hide();
	match (seldirection):
		"right":
			$DirectionButton/ArrowRight.show();
			currentSprite.rotation_degrees = 90;
			currentSprite.get_node("Shadow").position = Vector2(3, -3);
			currentSprite.get_node("Body/Shadow").position = Vector2(3, -3);
			currentSprite.flip_h = false;
			currentSprite.get_node("Body").flip_h = false;
		"left":
			$DirectionButton/ArrowLeft.show();
			currentSprite.rotation_degrees = 270;
			currentSprite.get_node("Shadow").position = Vector2(-3, 3);
			currentSprite.get_node("Body/Shadow").position = Vector2(-3, 3);
			currentSprite.flip_h = true;
			currentSprite.get_node("Body").flip_h = true;
		"down":
			$DirectionButton/ArrowDown.show();
			currentSprite.rotation_degrees = 180;
			currentSprite.get_node("Shadow").position = Vector2(-3, -3);
			currentSprite.get_node("Body/Shadow").position = Vector2(-3, -3);
			currentSprite.flip_h = true;
			currentSprite.get_node("Body").flip_h = true;
		"up":
			$DirectionButton/ArrowUp.show();
			currentSprite.rotation_degrees = 0;
			currentSprite.get_node("Shadow").position = Vector2(3, 3);
			currentSprite.get_node("Body/Shadow").position = Vector2(3, 3);
			currentSprite.flip_h = false;
			currentSprite.get_node("Body").flip_h = false;
	
	if (get_node("../Editor").playing):
		$DirectionButton.hide();
	else:
		$DirectionButton.show();

func styleChanged():
	match (Global.CurrentStyle):
		_:
			pass

func _on_DirectionButton_pressed():
	match (seldirection):
		"up":
			seldirection = "right";
		"down":
			seldirection = "left";
		"left":
			seldirection = "up";
		"right":
			seldirection = "down";
	$AudioGrabMove.play();
	if (OS.get_name() == "Android"):
		get_node("../Editor").externalButton = false;

func _on_DirectionButton_mouse_entered():
	get_node("../Editor").externalButton = true;

func _on_DirectionButton_mouse_exited():
	get_node("../Editor").externalButton = false;
