extends StaticBody2D

onready var currentSprite = get_node("SpriteGround");

var grid_origin_def = Vector2(0, 0);
var grid_origin = Vector2(0, 0);
var grid_end_def = Vector2(2, 0);
var grid_end = Vector2(2, 0);
var visual_grid_end = Vector2(2, 2);
var visual_grid_end_def = Vector2(2, 2);

var bye = false;

#var shadows = {
#	"top": null,
#	"body1": null
#}

var shadowtop : Sprite
var shadowbody : Sprite

var shadows = {}

var resizing : bool = false

var currentGrid : Vector2 = Vector2(0, 0);
var toGrid : Vector2 = Vector2(0, 0);

var charonme = false;

func setupExtensionGrids(start = false):
	var a = true;
	var mygrid = get_node("../..").calculateGrid(position.x, position.y)+grid_origin;
	for i in range(grid_end.x+1+(abs(grid_origin.x))):
		for j in range(grid_end.y+1+(abs(grid_origin.y))):
			if (Vector2(i, j) != grid_origin*-1):
				if (get_node("../..").grid[mygrid.x+i][mygrid.y+j] != null && start):
					a = false;
					bye = true;
	return a;

func unSetAllGrids():
	var mygrid = get_node("../..").calculateGrid(position.x, position.y)+grid_origin;
	for i in range(grid_end.x+1+(abs(grid_origin.x))):
		for j in range(grid_end.y+1+(abs(grid_origin.y))):
			get_node("../..").grid_node[mygrid.x+i][mygrid.y+j] = null;
			get_node("../..").grid[mygrid.x+i][mygrid.y+j] = null;

func setGrids(val):
	var mygrid = get_node("../..").calculateGrid(position.x, position.y)+grid_origin;
	for i in range(grid_end.x+1+(abs(grid_origin.x))):
		for j in range(grid_end.y+1+(abs(grid_origin.y))):
			if (Vector2(i, j) != grid_origin*-1):
				get_node("../..").grid_node[mygrid.x+i][mygrid.y+j] = self
				get_node("../..").grid[mygrid.x+i][mygrid.y+j] = val

func render(group, forcerender = false, render_range = 60):
	if (forcerender):
		set_process(true);
		set_physics_process(true);
		return
	if (group != ""):
		if (!is_in_group(group)):
			return
	var scrwidth = get_node("../../Editor/BlackScreen").rect_size.x
	var distance = abs(position.x-Global.campos.x)
	if (distance-(scrwidth/2) > scrwidth*(render_range*0.01)):
		set_process(false);
		set_physics_process(false);
	else:
		set_process(true);
		set_physics_process(true);

func floorErase():
	var delete = false;
	if (get_node("../..").calculateGrid(position.x, position.y).x <= 6):
		if (get_node("../..").calculateGrid(position.x, position.y).y >= get_node("../../LevelFloor").current_grid.y):
			delete = true;
	if (get_node("../..").calculateGrid(position.x, position.y).x >= get_node("../../EndFloor").current_grid.x-1):
		if (get_node("../..").calculateGrid(position.x, position.y).y >= get_node("../../EndFloor").current_grid.y):
			delete = true;

	if (delete):
		get_node("../..").eraseObject(position, false);

func erase():
	get_node("../..").eraseObject(position, false);

func changeStyle():
	var pos = position;
	var grid = get_node("../..").calculateGrid(pos.x, pos.y);
	var obj = get_node("../..").grid[grid.x][grid.y];
	var scene = Global.object[Global.CurrentAppeareance][obj][Global.OP_SCENE];
	var inst = scene.instance();
	get_node("../..").grid_node[grid.x][grid.y] = inst;
	get_node("../..").add_child(inst);
	inst.position = pos;
	var mygrid = get_node("../..").calculateGrid(position.x, position.y);
	for i in range(grid_end.x+1):
		for j in range(grid_end.y+1):
			if (Vector2(i, j) != grid_origin):
				get_node("../..").grid_node[grid.x+i][grid.y+j] = inst;

	queue_free();

func eraseShadow():
	for key in shadows.keys():
		shadows[key].queue_free()
		shadows.erase(key)

func _ready():
	Global.connect("render", self, "render");
	Global.connect("floorErase", self, "floorErase");
	Global.connect("changeStyle", self, "changeStyle");
	Global.connect("erase", self, "erase");
	hide()
	
	yield(get_tree(), "idle_frame");
	$ResizeContainer.position.x = (16*(grid_end.x))*3.25;
	$Arrows.position.x = $ResizeContainer.position.x;
	yield(get_tree(), "idle_frame");
	styleChanged()
	updateShape()
	show()

func _process(_delta):
	if (bye):
		eraseShadow();
		queue_free();
	
	if (currentSprite != get_node("SpriteGround")):
		currentSprite.scale = $SpriteGround.scale
	
	if (get_node("../../Editor").playing):
		$ResizeContainer/ResizeButton.hide();
		$Arrows.hide();
		
		if (get_node("../../Character") != null):
			if (get_node("../../Character").position.y <= position.y-49):
				$CollisionShape2D.disabled = false;
			else:
				$CollisionShape2D.disabled = true;
			
			if (get_node("../../Character").currentPowerup == "small"):
				$Area2D/CollisionShape2D.position.y = -49;
			else:
				$Area2D/CollisionShape2D.position.y = -49-20;
	else:
		if !($ResizeContainer/ResizeButton.visible):
			$ResizeContainer/ResizeButton.show();
		$Arrows.visible = resizing;
		
	for key in shadows.keys():
		if (key == "upl"): shadows[key].position = currentSprite.get_node("UpLeft").global_position
		if (key == "upr"): shadows[key].position = currentSprite.get_node("UpRight").global_position
		if (key == "downr"): shadows[key].position = currentSprite.get_node("DownRight").global_position
		if (key == "downl"): shadows[key].position = currentSprite.get_node("DownLeft").global_position
		
		if ("Up" in key): shadows[key].position = currentSprite.get_node("Up").get_node(key).global_position
		if ("Left" in key): shadows[key].position = currentSprite.get_node("Left").get_node(key).global_position
		if ("Right" in key): shadows[key].position = currentSprite.get_node("Right").get_node(key).global_position
		if ("Down" in key): shadows[key].position = currentSprite.get_node("Down").get_node(key).global_position
		if ("Center" in key): shadows[key].position = currentSprite.get_node("Center").get_node(key).global_position
		
		shadows[key].position += Vector2(3*3.25, 3*3.25);

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
		"Sky":
			currentSprite.hide();
			currentSprite = get_node("SpriteSky");
			currentSprite.show();
		"Desert":
			currentSprite.hide();
			currentSprite = get_node("SpriteDesert");
			currentSprite.show();
		"Forest":
			currentSprite.hide();
			currentSprite = get_node("SpriteForest");
			currentSprite.show();
		"Snow":
			currentSprite.hide();
			currentSprite = get_node("SpriteSnow");
			currentSprite.show();
		_:
			currentSprite.hide();
			currentSprite = get_node("SpriteGround");
			currentSprite.show();
	setBodySprites();

func _on_ResizeButton_mouse_entered():
	if (get_node("../..").grab):
		return
	get_node("../../Editor").externalButton = true;

func _on_ResizeButton_mouse_exited():
	if (!resizing):
		get_node("../../Editor").externalButton = false;

func _on_ResizeButton_pressed():
	if (get_node("../..").grab):
		return
	currentGrid = get_node("../..").calculateGrid(position.x, position.y);
	resizing = true;

func updateShape():
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(52+(26*(1*(grid_end.x-1)))+(26*(1*abs(grid_origin.x))), 52+(26*(1*(grid_end.y-1)))+(26*(1*abs(grid_origin.y))));
	$CollisionShape2D.shape = shape;
	$CollisionShape2D.position.y = 26+(26*(1*(grid_end.y-1)))+(26*(1*(grid_origin.y)));
	$CollisionShape2D.position.x = 26+(26*(1*(grid_end.x-1)))+(26*(1*(grid_origin.x)));
	$StaticBody2D/CollisionShape2D.shape = $CollisionShape2D.shape
	$StaticBody2D/CollisionShape2D.position = $CollisionShape2D.position;
	
	shape = RectangleShape2D.new();
	shape.extents = Vector2(52+(26*(1*(grid_end.x-1)))+(26*(1*abs(grid_origin.x))), 2.5);
	$Area2D/CollisionShape2D.shape = shape;
	$Area2D/CollisionShape2D.position.x = 26+(26*(1*(grid_end.x-1)))+(26*(1*(grid_origin.x)));

func createShadow(texture : Texture, position : Vector2, frames : Vector2, frame_coords : Vector2):
	var inst = Sprite.new()
	inst.texture = texture
	inst.position = position+Vector2(3*3.25, 3*3.25)
	inst.hframes = frames.x
	inst.vframes = frames.y
	inst.frame_coords = frame_coords
	inst.scale = Vector2(3.25, 3.25)
	get_node("../../ViewportShadow/Shadows").add_child(inst)
	return inst;

func setBodySprites():
	eraseShadow()
	
	var upr = currentSprite.get_node("UpRight");
	var upl = currentSprite.get_node("UpLeft");
	var downr = currentSprite.get_node("DownRight");
	var downl = currentSprite.get_node("DownLeft");
	shadows["upr"] = createShadow(upr.texture, upr.global_position, Vector2(upr.hframes, upr.vframes), upr.frame_coords);
	shadows["upl"] = createShadow(upr.texture, upl.global_position, Vector2(upl.hframes, upl.vframes), upl.frame_coords);
	shadows["downr"] = createShadow(upr.texture, downr.global_position, Vector2(downr.hframes, downr.vframes), downr.frame_coords);
	shadows["downl"] = createShadow(downl.texture, downl.global_position, Vector2(downl.hframes, upr.vframes), downl.frame_coords);
	
	$ResizeContainer.position.x = (16*(grid_end.x))*3.25;
	$Arrows.position.x = $ResizeContainer.position.x;
	
	currentSprite.get_node("UpRight").position.x = -16+(16*grid_end.x);
	currentSprite.get_node("DownRight").position.x = -16+(16*grid_end.x);
	currentSprite.get_node("DownRight").position.y = 16*(visual_grid_end.y-1);
	currentSprite.get_node("DownLeft").position.y = 16*(visual_grid_end.y-1);
	
	#Up
	var inst = currentSprite.get_node("Up/Up0");
	inst.texture = currentSprite.get_node("UpLeft").texture;
	inst.position = Vector2((grid_end.x-2)*8, -16);
	inst.scale = Vector2(grid_end.x-1, 1);
	var material = ShaderMaterial.new();
	material.shader = load("res://shaders/semisolid.gdshader");
	inst.material = material
	inst.material.set_shader_param("tile_amount", Vector2(grid_end.x-1, 1))
	shadows[inst.name] = createShadow(inst.texture, inst.global_position, Vector2(inst.hframes, inst.vframes), inst.frame_coords)
	shadows[inst.name].material = material
	shadows[inst.name].material.set_shader_param("tile_amount", Vector2(grid_end.x-1, 1))
	shadows[inst.name].scale = inst.scale*Vector2(3.25, 3.25)

	#Down
	inst = currentSprite.get_node("Down/Down0");
	inst.texture = currentSprite.get_node("UpLeft").texture;
	inst.position = Vector2((grid_end.x-2)*8, -16+(16*visual_grid_end.y));
	inst.scale = Vector2(grid_end.x-1, 1);
	material = ShaderMaterial.new();
	material.shader = load("res://shaders/semisolid.gdshader");
	inst.material = material
	inst.material.set_shader_param("tile_amount", Vector2(grid_end.x-1, 1))
	shadows[inst.name] = createShadow(inst.texture, inst.global_position, Vector2(inst.hframes, inst.vframes), inst.frame_coords)
	shadows[inst.name].material = material
	shadows[inst.name].material.set_shader_param("tile_amount", Vector2(grid_end.x-1, 1))
	shadows[inst.name].scale = inst.scale*Vector2(3.25, 3.25)
	
	#Left
	inst = currentSprite.get_node("Left/Left0");
	inst.texture = currentSprite.get_node("UpLeft").texture;
	inst.position = Vector2(-16, (visual_grid_end.y-2)*8);
	inst.scale = Vector2(1, visual_grid_end.y-1);
	material = ShaderMaterial.new();
	material.shader = load("res://shaders/semisolid.gdshader");
	inst.material = material;
	inst.material.set_shader_param("tile_amount", Vector2(1, visual_grid_end.y-1));
	shadows[inst.name] = createShadow(inst.texture, inst.global_position, Vector2(inst.hframes, inst.vframes), inst.frame_coords);
	shadows[inst.name].material = material;
	shadows[inst.name].material.set_shader_param("tile_amount", Vector2(1, visual_grid_end.y-1));
	shadows[inst.name].scale = inst.scale*Vector2(3.25, 3.25);
		
	#Right
	inst = currentSprite.get_node("Right/Right0");
	inst.texture = currentSprite.get_node("UpLeft").texture;
	inst.position = Vector2(-16+(16*grid_end.x), (visual_grid_end.y-2)*8);
	inst.scale = Vector2(1, visual_grid_end.y-1);
	material = ShaderMaterial.new();
	material.shader = load("res://shaders/semisolid.gdshader");
	inst.material = material;
	inst.material.set_shader_param("tile_amount", Vector2(1, visual_grid_end.y-1));
	shadows[inst.name] = createShadow(inst.texture, inst.global_position, Vector2(inst.hframes, inst.vframes), inst.frame_coords);
	shadows[inst.name].material = material;
	shadows[inst.name].material.set_shader_param("tile_amount", Vector2(1, visual_grid_end.y-1));
	shadows[inst.name].scale = inst.scale*Vector2(3.25, 3.25);
		
	#Center
	inst = currentSprite.get_node("Center/Center0");
	inst.texture = currentSprite.get_node("UpLeft").texture;
	inst.position = Vector2((grid_end.x-2)*8, (visual_grid_end.y-2)*8);
	inst.scale = Vector2(grid_end.x-1, visual_grid_end.y-1);
	material = ShaderMaterial.new();
	material.shader = load("res://shaders/semisolid.gdshader");
	inst.material = material
	inst.material.set_shader_param("tile_amount", Vector2(grid_end.x-1, visual_grid_end.y-1))
	shadows[inst.name] = createShadow(inst.texture, inst.global_position, Vector2(inst.hframes, inst.vframes), inst.frame_coords)
	shadows[inst.name].material = material
	shadows[inst.name].material.set_shader_param("tile_amount", Vector2(grid_end.x-1, visual_grid_end.y-1))
	shadows[inst.name].scale = inst.scale*Vector2(3.25, 3.25)

func _input(event):
	var a = (event is InputEventMouseButton && event.button_index == BUTTON_LEFT && !event.is_pressed());
	var b = (event is InputEventScreenTouch && !event.is_pressed());
	if (a || b):
		if (resizing):
			resizing = false;
			toGrid = currentGrid;
			get_node("../../Editor").externalButton = false;
	
	a = (event is InputEventMouseMotion);
	b = (event is InputEventScreenDrag);
	if (a || b):
		if (resizing):
			if (get_node("../..").grab):
				get_node("../../Editor").gamepadReleaseGrab();
			var eventpos = Vector2(event.position.x, event.position.y);
			var thisToGrid = get_node("../..").calculateGrid(eventpos.x+get_node("../..").get_node("Camera2D").position.x, eventpos.y+get_node("../..").get_node("Camera2D").position.y);
			if (thisToGrid.y < 0 || thisToGrid.y > 29 || thisToGrid.x < 0):
				return
			if (currentGrid != thisToGrid && thisToGrid != toGrid):
				toGrid = thisToGrid;
				if (toGrid.y < currentGrid.y):
					var can = true;
					for i in range(grid_end.x+1+(abs(grid_origin.x))):
						if (Vector2(i, currentGrid.y-1) != grid_origin*-1):
							if (get_node("../..").grid[currentGrid.x+i][currentGrid.y-1] != null):
								can = false;
					if (can):
						unSetAllGrids();
						currentGrid = Vector2(currentGrid.x, currentGrid.y-1);
						visual_grid_end = Vector2(grid_end.x, visual_grid_end.y+1);
						position = get_node("../..").calculateGridPosition(currentGrid);
						setGrids(Global.OBJ_SEMISOLID);
						get_node("../..").grid[currentGrid.x][currentGrid.y] = Global.OBJ_SEMISOLID;
						get_node("../..").grid_node[currentGrid.x][currentGrid.y] = self;

						setBodySprites();

						$AudioGrabMove.play();
						updateShape();
				if (toGrid.y > currentGrid.y && visual_grid_end.y > visual_grid_end_def.y):
					var can = true;
					for i in range(grid_end.x+1+(abs(grid_origin.x))):
						if (Vector2(i, currentGrid.y-1) != grid_origin*-1):
							if (get_node("../..").grid[currentGrid.x+i][currentGrid.y+1] != null):
								can = false;
					if (can):
						unSetAllGrids();
						currentGrid = Vector2(currentGrid.x, currentGrid.y+1);
						visual_grid_end = Vector2(grid_end.x, visual_grid_end.y-1);
						position = get_node("../..").calculateGridPosition(currentGrid);
						setGrids(Global.OBJ_SEMISOLID);
						get_node("../..").grid[currentGrid.x][currentGrid.y] = Global.OBJ_SEMISOLID;
						get_node("../..").grid_node[currentGrid.x][currentGrid.y] = self;
						setBodySprites();
						$AudioGrabMove.play();
						updateShape();
				if (toGrid.x > currentGrid.x+grid_end.x):
					var can = true;
					for j in range(grid_end.y+1+(abs(grid_origin.y))):
						if (Vector2(currentGrid.x+grid_end.x+1, j) != grid_origin*-1):
							if (get_node("../..").grid[currentGrid.x+grid_end.x+1][currentGrid.y+j] != null):
								can = false;
					if (can):
						unSetAllGrids();
						grid_end.x += 1;
						currentGrid = Vector2(currentGrid.x, currentGrid.y);
						position = get_node("../..").calculateGridPosition(currentGrid);
						setGrids(Global.OBJ_SEMISOLID);
						get_node("../..").grid[currentGrid.x][currentGrid.y] = Global.OBJ_SEMISOLID;
						get_node("../..").grid_node[currentGrid.x][currentGrid.y] = self;
						
						setBodySprites();
						
						$AudioGrabMove.play();
						updateShape();
				if (toGrid.x < currentGrid.x+grid_end.x && grid_end.x > grid_end_def.x):
					unSetAllGrids();
					grid_end.x -= 1;
					currentGrid = Vector2(currentGrid.x, currentGrid.y);
					position = get_node("../..").calculateGridPosition(currentGrid);
					setGrids(Global.OBJ_SEMISOLID);
					get_node("../..").grid[currentGrid.x][currentGrid.y] = Global.OBJ_SEMISOLID;
					get_node("../..").grid_node[currentGrid.x][currentGrid.y] = self;
					
					setBodySprites();
					
					$AudioGrabMove.play();
					updateShape();

func _on_Pipe_tree_exiting():
	get_node("../../Editor").externalButton = false;

func _on_Area2D_body_entered(body):
	if (body.is_in_group("Character")):
		if (!charonme && !body.died && !body.course_clear):
			#body.clouds += 1;
			charonme = true;

func _on_Area2D_body_exited(body):
	if (body.is_in_group("Character")):
		if (charonme):
			charonme = false;
			#get_node("../../Character").clouds -= 1;
