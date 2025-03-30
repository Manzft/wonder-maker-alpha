extends StaticBody2D

onready var currentSprite = get_node("SpriteGround");

var grid_origin_def = Vector2(0, 0);
var grid_origin = Vector2(0, 0);
var grid_end_def = Vector2(1, 1);
var grid_end = Vector2(1, 1);

var bye = false;

var seldirection = "up";

#var shadows = {
#	"top": null,
#	"body1": null
#}

var shadowtop : Sprite
var shadowbody : Sprite

var resizing : bool = false

var currentGrid : Vector2 = Vector2(0, 0);
var toGrid : Vector2 = Vector2(0, 0);

var pipe_code = -1

var charishere : bool = false

func setupExtensionGrids(start = false):
	var a = true;
	var mygrid = get_parent().calculateGrid(position.x, position.y)+grid_origin;
	for i in range(grid_end.x+1+(abs(grid_origin.x))):
		for j in range(grid_end.y+1+(abs(grid_origin.y))):
			if (Vector2(i, j) != grid_origin*-1):
				if (get_parent().grid[mygrid.x+i][mygrid.y+j] != null && start):
					a = false;
					bye = true;
	return a;

func unSetAllGrids():
	var mygrid = get_parent().calculateGrid(position.x, position.y)+grid_origin;
	for i in range(grid_end.x+1+(abs(grid_origin.x))):
		for j in range(grid_end.y+1+(abs(grid_origin.y))):
			get_parent().grid_node[mygrid.x+i][mygrid.y+j] = null;
			get_parent().grid[mygrid.x+i][mygrid.y+j] = null;

func setGrids(val):
	var mygrid = get_parent().calculateGrid(position.x, position.y)+grid_origin;
	for i in range(grid_end.x+1+(abs(grid_origin.x))):
		for j in range(grid_end.y+1+(abs(grid_origin.y))):
			if (Vector2(i, j) != grid_origin*-1):
				get_parent().grid_node[mygrid.x+i][mygrid.y+j] = self
				get_parent().grid[mygrid.x+i][mygrid.y+j] = val

func render(group, forcerender = false, render_range = 60):
	if (forcerender):
		set_process(true);
		set_physics_process(true);
		return
	if (group != ""):
		if (!is_in_group(group)):
			return
	var scrwidth = OS.get_window_size().x;
	var scrheight = OS.get_window_size().y;
	var multiplier = 720/scrheight;
	var finalscrwidth = scrwidth * multiplier;
	var distance = abs(position.x-Global.campos.x);
	if (distance-(finalscrwidth/2) > finalscrwidth*(render_range*0.01)):
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

func eraseShadow():
	shadowbody.queue_free();
	shadowtop.queue_free();

func _ready():
	Global.connect("render", self, "render");
	Global.connect("floorErase", self, "floorErase");
	Global.connect("changeStyle", self, "changeStyle");
	Global.connect("erase", self, "erase");
	styleChanged();
	
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");
	updateShape();
	yield(get_tree().create_timer(0.125), "timeout");
	match (seldirection):
		"right":
			currentSprite.rotation = deg2rad(90.0);
			currentSprite.flip_h = false;
			currentSprite.get_node("Body").flip_h = false;
		"left":
			currentSprite.rotation = deg2rad(270.0);
			currentSprite.flip_h = false;
			currentSprite.get_node("Body").flip_h = true;
		"down":
			currentSprite.rotation = deg2rad(180.0);
			currentSprite.flip_h = false;
			currentSprite.get_node("Body").flip_h = true;
		"up":
			currentSprite.rotation = deg2rad(0.0);
			currentSprite.flip_h = false;
			currentSprite.get_node("Body").flip_h = false;
	setBodySprites();

func _process(_delta):
	if (bye):
		eraseShadow();
		queue_free();
		
	$DirectionButton/ArrowLeft.hide();
	$DirectionButton/ArrowRight.hide();
	$DirectionButton/ArrowUp.hide();
	$DirectionButton/ArrowDown.hide();
	match (seldirection):
		"right":
			$DirectionButton/ArrowRight.show();
			#currentSprite.rotation_degrees = 90;
			currentSprite.rotation = lerp_angle(currentSprite.rotation, deg2rad(90.0), 0.25);
			currentSprite.flip_h = false;
			currentSprite.get_node("Body").flip_h = false;
			$Arrows.position = Vector2(52, 26);
			$Arrows.rotation_degrees = 90;
		"left":
			$DirectionButton/ArrowLeft.show();
			#currentSprite.rotation_degrees = 270;
			currentSprite.rotation = lerp_angle(currentSprite.rotation, deg2rad(270.0), 0.25);
			currentSprite.flip_h = true;
			currentSprite.get_node("Body").flip_h = true;
			$Arrows.position = Vector2(-17, 26);
			$Arrows.rotation_degrees = 90;
		"down":
			$DirectionButton/ArrowDown.show();
			#currentSprite.rotation_degrees = 180;
			currentSprite.rotation = lerp_angle(currentSprite.rotation, deg2rad(180.0), 0.25);
			currentSprite.flip_h = true;
			currentSprite.get_node("Body").flip_h = true;
			$Arrows.position = Vector2(26, 69);
			$Arrows.rotation_degrees = 0;
		"up":
			$DirectionButton/ArrowUp.show();
			#currentSprite.rotation_degrees = 0;
			currentSprite.rotation = lerp_angle(currentSprite.rotation, deg2rad(0.0), 0.25);
			currentSprite.flip_h = false;
			currentSprite.get_node("Body").flip_h = false;
			$Arrows.position = Vector2(26, 0);
			$Arrows.rotation_degrees = 0;
			
	
	if (get_node("../Editor").playing):
		$ResizeContainer/ResizeButton.hide();
		$DirectionButton.hide();
		$Arrows.hide();
		$EntryButton.hide()
	else:
		$DirectionButton.visible = (grid_end == grid_end_def && grid_origin == grid_origin_def && !resizing);
		$ResizeContainer/ResizeButton.show();
		$Arrows.visible = resizing;
		if (pipe_code != -1):
			$EntryButton.show()
		else:
			$EntryButton.hide()
	shadowtop.position = currentSprite.global_position+Vector2(3*3.25, 3*3.25);
	shadowtop.scale = currentSprite.scale;
	shadowtop.rotation_degrees = currentSprite.rotation_degrees;
	
	shadowbody.position = currentSprite.get_node("Body").global_position+Vector2(3*3.25, (3)*3.25)
	shadowbody.scale = currentSprite.scale;
	
	if (seldirection == "up"):
		shadowbody.position.y += 8*3.25;
		shadowbody.position.y += (8*(grid_end.y-1))*3.25;
		shadowbody.scale.y += (1*(grid_end.y-1)+1*abs(grid_origin.y))*3.25;
	if (seldirection == "down"):
		shadowbody.position.y -= 8*3.25;
		shadowbody.position.y -= (8*abs(grid_origin.y))*3.25;
		shadowbody.scale.y += (1*(grid_end.y-1)+1*abs(grid_origin.y))*3.25;
	
	if (seldirection == "left"):
		shadowbody.position.x += 8*3.25;
		shadowbody.position.x += (8*(grid_end.x-1))*3.25;
		shadowbody.scale.y += (1*(grid_end.x-1)+1*abs(grid_origin.x))*3.25;
	if (seldirection == "right"):
		shadowbody.position.x -= 8*3.25;
		shadowbody.position.x -= (8*abs(grid_origin.x))*3.25;
		shadowbody.scale.y += (1*(grid_end.x-1)+1*abs(grid_origin.x))*3.25;
	
	shadowbody.rotation_degrees = currentSprite.rotation_degrees;
	
	$ResizeContainer.rotation_degrees = shadowtop.rotation_degrees
	$EntryButton.rect_rotation = $ResizeContainer.rotation_degrees
	
	if (grid_end == grid_end_def && grid_origin == grid_origin_def):
		$EntryButton.rect_position = Vector2(40, 43)
		$EntryButton.rect_pivot_offset = Vector2(-14, -17)
	else:
		$EntryButton.rect_position = Vector2(9, 9)
		$EntryButton.rect_pivot_offset = Vector2(17, 17)
	
	if (get_node("../Character") != null):
		var chara = get_node("../Character")
		var inputcheck : bool = false
		match (seldirection):
			"up":
				inputcheck = Input.is_action_just_pressed("down")
			"right":
				inputcheck = Input.is_action_just_pressed("left") && chara.is_on_floor()
			"left":
				inputcheck = Input.is_action_just_pressed("right") && chara.is_on_floor()
			"down":
				inputcheck = Input.is_action_just_pressed("up")
		if (inputcheck && charishere && pipe_code != -1):
			if (!chara.died):
				chara.enterPipe(seldirection, self, pipe_code)

func styleChanged():
	match (Global.CurrentStyle):
		_:
			pass
	if (shadowtop == null):
		pass
	else:
		shadowtop.queue_free();
	shadowtop = Sprite.new();
	shadowtop.texture = currentSprite.texture;
	shadowtop.scale = currentSprite.scale
	get_node("../ShadowViewport").add_child(shadowtop);
	if (shadowbody == null):
		pass
	else:
		shadowbody.queue_free();
	shadowbody = Sprite.new();
	shadowbody.texture = currentSprite.texture;
	shadowbody.vframes = currentSprite.get_node("Body").vframes;
	shadowbody.frame = currentSprite.get_node("Body").frame;
	shadowbody.scale = currentSprite.scale
	get_node("../ShadowViewport").add_child(shadowbody);

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
	if (get_parent().grab):
		return
	get_node("../Editor").externalButton = true;

func _on_DirectionButton_mouse_exited():
	get_node("../Editor").externalButton = false;
	resizing = false;

func _on_ResizeButton_mouse_exited():
	if (!resizing):
		get_node("../Editor").externalButton = false;

func _on_ResizeButton_pressed():
	if (get_parent().grab):
		return
	currentGrid = get_parent().calculateGrid(position.x, position.y);
	resizing = true;

func updateShape():
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(52+(26*(1*(grid_end.x-1)))+(26*(1*abs(grid_origin.x))), 52+(26*(1*(grid_end.y-1)))+(26*(1*abs(grid_origin.y))));
	$CollisionShape2D.shape = shape;
	$CollisionShape2D.position.y = 26+(26*(1*(grid_end.y-1)))+(26*(1*(grid_origin.y)));
	$CollisionShape2D.position.x = 26+(26*(1*(grid_end.x-1)))+(26*(1*(grid_origin.x)));

func setBodySprites():
	#Erase all body sprites
	for node in currentSprite.get_children():
		if (node.name != "Body" && node.name != "Area2D"):
			node.queue_free();
	
	if (grid_end != grid_end_def):
		#Up
		if (grid_end.y > grid_end_def.y):
			for i in range(grid_end.y-1):
				var inst = Sprite.new();
				inst.texture = currentSprite.get_node("Body").texture;
				inst.offset = currentSprite.get_node("Body").offset;
				inst.vframes = currentSprite.get_node("Body").vframes;
				inst.frame = currentSprite.get_node("Body").frame;
				inst.flip_h = currentSprite.get_node("Body").flip_h;
				inst.position.y += 16*(i+1);
				inst.name = "Body"+str(i+2);
				currentSprite.add_child(inst);
		#Left
		if (grid_end.x > grid_end_def.x):
			for i in range(grid_end.x-1):
				var inst = Sprite.new();
				inst.texture = currentSprite.get_node("Body").texture;
				inst.offset = currentSprite.get_node("Body").offset;
				inst.vframes = currentSprite.get_node("Body").vframes;
				inst.frame = currentSprite.get_node("Body").frame;
				inst.flip_h = currentSprite.get_node("Body").flip_h;
				inst.position.y += 16*(i+1);
				inst.name = "Body"+str(i+2);
				currentSprite.add_child(inst);
	
	if (grid_origin != grid_origin_def):
		#Down
		if (grid_origin.y < grid_origin_def.y):
			for i in range(abs(grid_origin.y)):
				var inst = Sprite.new();
				inst.texture = currentSprite.get_node("Body").texture;
				inst.offset = currentSprite.get_node("Body").offset;
				inst.vframes = currentSprite.get_node("Body").vframes;
				inst.frame = currentSprite.get_node("Body").frame;
				inst.flip_h = currentSprite.get_node("Body").flip_h;
				inst.position.y += 16*(i+1);
				inst.name = "Body"+str(i+2);
				currentSprite.add_child(inst);
		#Right
		if (grid_origin.x < grid_origin_def.x):
			for i in range(abs(grid_origin.x)):
				var inst = Sprite.new();
				inst.texture = currentSprite.get_node("Body").texture;
				inst.offset = currentSprite.get_node("Body").offset;
				inst.vframes = currentSprite.get_node("Body").vframes;
				inst.frame = currentSprite.get_node("Body").frame;
				inst.flip_h = currentSprite.get_node("Body").flip_h;
				inst.position.y += 16*(i+1);
				inst.name = "Body"+str(i+2);
				currentSprite.add_child(inst);

func _input(event):
	var a = (event is InputEventMouseButton && event.button_index == BUTTON_LEFT && !event.is_pressed());
	var b = (event is InputEventScreenTouch && !event.is_pressed());
	if (a || b):
		if (resizing):
			resizing = false;
			toGrid = currentGrid;
			get_node("../Editor").externalButton = false;
	
	a = (event is InputEventMouseMotion);
	b = (event is InputEventScreenDrag);
	if (a || b):
		if (resizing):
			if (get_parent().grab):
				get_node("../Editor").gamepadReleaseGrab();
			var eventpos = Vector2(event.position.x, event.position.y);
			var thisToGrid = get_parent().calculateGrid(eventpos.x+get_parent().get_node("Camera2D").position.x, eventpos.y+get_parent().get_node("Camera2D").position.y);
			if (thisToGrid.y < 0 || thisToGrid.y > 29 || thisToGrid.x < 0):
				return
			if (currentGrid != thisToGrid && thisToGrid != toGrid):
				toGrid = thisToGrid;
				match (seldirection):
					"up":
						if (toGrid.y < currentGrid.y):
							var can = true;
							for i in range(grid_end.x+1+(abs(grid_origin.x))):
								if (Vector2(i, currentGrid.y-1) != grid_origin*-1):
									if (get_parent().grid[currentGrid.x+i][currentGrid.y-1] != null):
										can = false;
							if (can):
								unSetAllGrids();
								currentGrid = Vector2(currentGrid.x, currentGrid.y-1);
								grid_end = Vector2(grid_end.x, grid_end.y+1);
								position = get_parent().calculateGridPosition(currentGrid);
								setGrids(Global.OBJ_PIPE);
								get_parent().grid[currentGrid.x][currentGrid.y] = Global.OBJ_PIPE;
								get_parent().grid_node[currentGrid.x][currentGrid.y] = self;
								
								setBodySprites();
								
								$AudioGrabMove.play();
								updateShape();
						if (toGrid.y > currentGrid.y && grid_end != grid_end_def):
							unSetAllGrids();
							currentGrid = Vector2(currentGrid.x, currentGrid.y+1);
							grid_end = Vector2(grid_end.x, grid_end.y-1);
							position = get_parent().calculateGridPosition(currentGrid);
							setGrids(Global.OBJ_PIPE);
							get_parent().grid[currentGrid.x][currentGrid.y] = Global.OBJ_PIPE;
							get_parent().grid_node[currentGrid.x][currentGrid.y] = self;
							
							setBodySprites();
							
							$AudioGrabMove.play();
							updateShape();
					"left":
						if (toGrid.x < currentGrid.x):
							var can = true;
							for j in range(grid_end.y+1+(abs(grid_origin.x))):
								if (Vector2(currentGrid.x-1, j) != grid_origin*-1):
									if (get_parent().grid[currentGrid.x-1][currentGrid.y+j] != null):
										can = false;
							if (can):
								unSetAllGrids();
								currentGrid = Vector2(currentGrid.x-1, currentGrid.y);
								grid_end = Vector2(grid_end.x+1, grid_end.y);
								position = get_parent().calculateGridPosition(currentGrid);
								setGrids(Global.OBJ_PIPE);
								get_parent().grid[currentGrid.x][currentGrid.y] = Global.OBJ_PIPE;
								get_parent().grid_node[currentGrid.x][currentGrid.y] = self;
								
								setBodySprites();
								
								$AudioGrabMove.play();
								updateShape();
						if (toGrid.x > currentGrid.x && grid_end != grid_end_def):
							unSetAllGrids();
							currentGrid = Vector2(currentGrid.x+1, currentGrid.y);
							grid_end = Vector2(grid_end.x-1, grid_end.y);
							position = get_parent().calculateGridPosition(currentGrid);
							setGrids(Global.OBJ_PIPE);
							get_parent().grid[currentGrid.x][currentGrid.y] = Global.OBJ_PIPE;
							get_parent().grid_node[currentGrid.x][currentGrid.y] = self;
							
							setBodySprites();
							
							$AudioGrabMove.play();
							updateShape();
					"right":
						if (toGrid.x > currentGrid.x+grid_end.x):
							var can = true;
							for j in range(grid_end.y+1+(abs(grid_origin.y))):
								if (Vector2(currentGrid.x+grid_end.x+1, j) != grid_origin*-1):
									if (get_parent().grid[currentGrid.x+grid_end.x+1][currentGrid.y+j] != null):
										can = false;
							if (can):
								unSetAllGrids();
								grid_origin.x -= 1;
								currentGrid = Vector2(currentGrid.x+1, currentGrid.y);
								grid_end = Vector2(grid_end.x, grid_end.y);
								position = get_parent().calculateGridPosition(currentGrid);
								setGrids(Global.OBJ_PIPE);
								get_parent().grid[currentGrid.x][currentGrid.y] = Global.OBJ_PIPE;
								get_parent().grid_node[currentGrid.x][currentGrid.y] = self;
								
								setBodySprites();
								
								$AudioGrabMove.play();
								updateShape();
						if (toGrid.x < currentGrid.x+grid_end.x && grid_origin != grid_origin_def):
							unSetAllGrids();
							grid_origin.x += 1;
							currentGrid = Vector2(currentGrid.x-1, currentGrid.y);
							grid_end = Vector2(grid_end.x, grid_end.y);
							position = get_parent().calculateGridPosition(currentGrid);
							setGrids(Global.OBJ_PIPE);
							get_parent().grid[currentGrid.x][currentGrid.y] = Global.OBJ_PIPE;
							get_parent().grid_node[currentGrid.x][currentGrid.y] = self;
							
							setBodySprites();
							
							$AudioGrabMove.play();
							updateShape();
					"down":
						if (toGrid.y > currentGrid.y+grid_end.y):
							var can = true;
							for i in range(grid_end.x+1+(abs(grid_origin.x))):
								if (Vector2(i, currentGrid.y+grid_end.y+1) != grid_origin*-1):
									if (get_parent().grid[currentGrid.x+i][currentGrid.y+grid_end.y+1] != null):
										can = false;
							if (can):
								unSetAllGrids();
								grid_origin.y -= 1;
								currentGrid = Vector2(currentGrid.x, currentGrid.y+1);
								grid_end = Vector2(grid_end.x, grid_end.y);
								position = get_parent().calculateGridPosition(currentGrid);
								setGrids(Global.OBJ_PIPE);
								get_parent().grid[currentGrid.x][currentGrid.y] = Global.OBJ_PIPE;
								get_parent().grid_node[currentGrid.x][currentGrid.y] = self;
								
								setBodySprites();
								
								$AudioGrabMove.play();
								updateShape();
						if (toGrid.y < currentGrid.y+grid_end.y && grid_origin != grid_origin_def):
							unSetAllGrids();
							grid_origin.y += 1;
							currentGrid = Vector2(currentGrid.x, currentGrid.y-1);
							grid_end = Vector2(grid_end.x, grid_end.y);
							position = get_parent().calculateGridPosition(currentGrid);
							setGrids(Global.OBJ_PIPE);
							get_parent().grid[currentGrid.x][currentGrid.y] = Global.OBJ_PIPE;
							get_parent().grid_node[currentGrid.x][currentGrid.y] = self;
							
							setBodySprites();
							
							$AudioGrabMove.play();
							updateShape();

func _on_Pipe_tree_exiting():
	get_node("../Editor").externalButton = false;

func _on_Area2D_body_entered(body):
	if (body.is_in_group("Character")):
		charishere = true

func _on_Area2D_body_exited(body):
	if (body.is_in_group("Character")):
		charishere = false

func _on_EntryButton_pressed():
	if (pipe_code == -1):
		return
	var chara = get_node("../CharacterEditor")
	for node in get_tree().get_nodes_in_group("Pipe"):
		if (node != self):
			if (node.pipe_code == pipe_code):
				match (node.seldirection):
					"up":
						chara.position.x = node.position.x+26
						chara.position.y = node.position.y-52
					"left":
						chara.position.y = node.position.y+26+18
						chara.position.x = node.position.x-52
					"right":
						chara.position.y = node.position.y+26+18
						chara.position.x = node.position.x+52+52
					"down":
						chara.position.x = node.position.x+26
						chara.position.y = node.position.y+52+52
				$SoundEnterPipe.play()
