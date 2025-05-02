extends StaticBody2D

onready var currentSprite = get_node("SpriteGround");

var shadow : Sprite;
var shadowhide : Sprite;

func render(group, forcerender = false, render_range = 60):
	if (forcerender):
		set_process(true);
		set_physics_process(true);
		return
	if (group != ""):
		if (!is_in_group(group)):
			return
	var scrwidth = get_node("../Editor/BlackScreen").rect_size.x;
	var distance = abs(position.x-Global.campos.x);
	if (distance-(scrwidth/2) > scrwidth*(render_range*0.01)):
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

func eraseShadow():
	shadow.queue_free();
	shadowhide.queue_free();

func _ready():
	Global.connect("render", self, "render");
	Global.connect("floorErase", self, "floorErase");
	Global.connect("changeStyle", self, "changeStyle");
	Global.connect("erase", self, "erase");
	styleChanged();

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
	shadow.position = currentSprite.global_position+Vector2(3*3.25, 3*3.25);
	shadow.scale = currentSprite.scale;
	shadow.visible = currentSprite.visible;
	shadowhide.position = $Hide.global_position+Vector2(3*3.25, 3*3.25);
	shadowhide.scale = $Hide.scale;
	shadowhide.visible = $Hide.visible;

func styleChanged():
	match (Global.CurrentStyle):
		_:
			currentSprite.hide();
			currentSprite = get_node("SpriteGround");
			currentSprite.show();
	if (shadow == null):
		pass
	else:
		shadow.queue_free();
	shadow = Sprite.new();
	shadow.texture = currentSprite.texture;
	shadow.scale = currentSprite.scale
	get_node("../ViewportShadow/Shadows").add_child(shadow);
	if (shadowhide == null):
		pass
	else:
		shadowhide.queue_free();
	shadowhide = Sprite.new();
	shadowhide.texture = $Hide.texture;
	shadowhide.scale = $Hide.scale
	get_node("../ViewportShadow/Shadows").add_child(shadowhide);
