extends Area2D

onready var currentSprite = get_node("SpriteGround");

var extension_grid_size = 3;
var extension_grid = [];
var default_extension_grid = [Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)];

var bye = false;

var ready = false;

var canSyncAnim = false;

func _ready():
	hide();
	styleChanged();
	for i in range(50):
		extension_grid.append([]);
	for i in range(50):
		extension_grid[i] = null;
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");
	ready = true;
	canSyncAnim = true;
	$VisibilityEnabler2D.emit_signal("screen_exited")

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

func _process(_delta):
	if (bye):
		queue_free();
		
	if (get_node("../Editor").playing):
		currentSprite.speed_scale = 1;
		currentSprite.get_node("Shadow").speed_scale = 0;
		currentSprite.get_node("Shadow").frame = currentSprite.frame;
		
		if (canSyncAnim):
			var nodes = get_tree().get_nodes_in_group("10Coin");
			for node in nodes:
				node.currentSprite.frame = currentSprite.frame;
			nodes = get_tree().get_nodes_in_group("30Coin");
			for node in nodes:
				node.currentSprite.frame = currentSprite.frame;
			nodes = get_tree().get_nodes_in_group("50Coin");
			for node in nodes:
				node.currentSprite.frame = currentSprite.frame;
	else:
		if (!visible && ready):
			show();
		currentSprite.speed_scale = 0;
		currentSprite.frame = 0;
		currentSprite.get_node("Shadow").speed_scale = 0;
		currentSprite.get_node("Shadow").frame = currentSprite.frame;

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
			currentSprite = get_node("SpriteUnderground");
			currentSprite.show();
		_:
			currentSprite.hide();
			currentSprite = get_node("SpriteGround");
			currentSprite.show();

func _on_Coin_body_entered(body):
	if (body.is_in_group("Character") && visible):
		hide();
		body.get_node("Sound10Coin").play();
		
		get_node("../Editor").Score += 200;
		
		if (is_in_group("10Coin")):
			get_parent().get_node("Editor").Coins += 10;
		elif (is_in_group("30Coin")):
			get_parent().get_node("Editor").Coins += 30;
		elif (is_in_group("50Coin")):
			get_parent().get_node("Editor").Coins += 50;
