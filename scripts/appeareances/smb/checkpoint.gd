extends Area2D

onready var currentSprite = get_node("SpriteGround/SpriteFlag");

var grid_origin = Vector2(0, 0);
var grid_end = Vector2(1, 1);

var bye = false;

var seldirection = "up";

var got = false;

func setupExtensionGrids(start = false):
	var a = true;
	var mygrid = get_parent().calculateGrid(position.x, position.y);
	for i in range(grid_end.x+1):
		for j in range(grid_end.y+1):
			if (Vector2(i, j) != grid_origin):
				if (get_parent().grid_node[mygrid.x+i][mygrid.y+j] != null && start):
					a = false;
					bye = true;
	
	return a;

func setGrids(val):
	var mygrid = get_parent().calculateGrid(position.x, position.y);
	for i in range(grid_end.x+1):
		for j in range(grid_end.y+1):
			if (Vector2(i, j) != grid_origin):
				get_parent().grid_node[mygrid.x+i][mygrid.y+j] = self
				get_parent().grid[mygrid.x+i][mygrid.y+j] = val

func render(group, forcerender = false):
	if (forcerender):
		set_process(true);
		set_physics_process(true);
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
		
func floorErase():
	var delete = false;
	if (get_parent().calculateGrid(position.x, position.y).x <= 6):
		if (get_parent().calculateGrid(position.x, position.y).y >= get_node("../LevelFloor").current_grid.y):
			delete = true;
	if (get_parent().calculateGrid(position.x, position.y).x >= get_node("../EndFloor").current_grid.x-1):
		if (get_parent().calculateGrid(position.x, position.y).y >= get_node("../EndFloor").current_grid.y):
			delete = true;

	if (delete):
		get_parent().eraseObject(position, false);

func erase():
	get_parent().eraseObject(position, false);

func changeStyle():
	var pos = position;
	var grid = get_parent().calculateGrid(pos.x, pos.y);
	var obj = get_parent().grid[grid.x][grid.y];
	var scene = Global.object[Global.CurrentAppeareance][obj][Global.OP_SCENE];
	var inst = scene.instance();
	get_parent().grid_node[grid.x][grid.y] = inst;
	get_parent().add_child(inst);
	inst.position = pos;
	inst.seldirection = seldirection;
	var mygrid = get_parent().calculateGrid(position.x, position.y);
	for i in range(grid_end.x+1):
		for j in range(grid_end.y+1):
			if (Vector2(i, j) != grid_origin):
				get_parent().grid_node[grid.x+i][grid.y+j] = inst;

	queue_free();

func _ready():
	Global.connect("render", self, "render");
	Global.connect("floorErase", self, "floorErase");
	Global.connect("changeStyle", self, "changeStyle");
	Global.connect("erase", self, "erase");
	styleChanged();
	var mygrid = get_parent().calculateGrid(position.x, position.y);
	mygrid.y += 1;
	if (Global.CheckpointGrid == mygrid):
		got = true;
		currentSprite.play("mario");
	
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");

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
