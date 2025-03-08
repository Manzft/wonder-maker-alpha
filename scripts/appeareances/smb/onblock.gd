extends StaticBody2D

onready var currentSprite = get_node("SpriteGround");

func render(group, forcerender = false):
	if (forcerender):
		set_process(true);
		set_physics_process(true);
		return
	if (group != ""): if (!is_in_group(group)): return
	var scrwidth = OS.get_window_size().x;
	var scrheight = OS.get_window_size().y;
	var multiplier = 720/scrheight;
	var finalscrwidth = scrwidth * multiplier;
	var distance = abs(position.x-Global.campos.x);
	if (distance-(finalscrwidth/2) > finalscrwidth*0.5):
		set_process(false); set_physics_process(false);
	else:
		set_process(true); set_physics_process(true);
		
func floorErase():
	var delete = false;
	if (get_parent().calculateGrid(position.x, position.y).x <= 6):
		if (get_parent().calculateGrid(position.x, position.y).y >= get_node("../LevelFloor").current_grid.y):
			delete = true;
	if (get_parent().calculateGrid(position.x, position.y).x >= get_node("../EndFloor").current_grid.x-1):
		if (get_parent().calculateGrid(position.x, position.y).y >= get_node("../EndFloor").current_grid.y):
			delete = true;
	if (delete): get_parent().eraseObject(position, false);

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
	queue_free();

func _ready():
	Global.connect("render", self, "render");
	Global.connect("floorErase", self, "floorErase");
	Global.connect("changeStyle", self, "changeStyle");
	Global.connect("erase", self, "erase");
	styleChanged();
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");

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
