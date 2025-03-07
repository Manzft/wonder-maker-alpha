extends Sprite

signal endFloorChanged(grid)

var selected = false;
var mouse_entered = false;

var current_grid = Vector2();

var myfloor = null;
var myflagpole = null;

var startPosition = Vector2();

func _ready():
	get_parent().get_node("Editor").connect("appearanceChanged", self, "appearanceChanged");
	yield(get_tree().create_timer(0.0625), "timeout");
	startPosition = position;
	calculate(position, true);
	$AnimationPlayer.play("selected");

func appearanceChanged(app):
	createLevelFloorObjects(app);

func _input(event):
	var chk = (event is InputEventKey);
	if (!chk):
		if (event is InputEventMouseButton):
			if (mouse_entered && Input.is_action_just_pressed("leftclick") && !selected):
				select();
				Input.set_custom_mouse_cursor(load("res://sprites/ui/cursor_grab_editor.png"));
			if (Input.is_action_just_released("leftclick") && selected):
				select();
				Input.set_custom_mouse_cursor(load("res://sprites/ui/cursor_editor.png"));
		if (selected):
			var mpos = Vector2(0, 0);
			if (Global.CurrentInput != "Gamepad"):
				if (event is InputEventScreenDrag || event is InputEventScreenTouch || event is InputEventMouse):
					mpos = event.position+get_parent().get_node("Camera2D").position;
			else:
				mpos = get_parent().get_node("Editor/GamepadCursor").rect_position+get_parent().get_node("Camera2D").position;
			calculate(mpos);
		if (event is InputEventScreenTouch):
			if (!event.pressed && selected):
				select();
		elif (event is InputEventScreenDrag):
			if (!event.pressed && selected):
				select();

func createLevelFloorObjects(customAppearance):
	if (customAppearance == null):
		customAppearance = Global.CurrentAppeareance;
	
	var inst;
	#Floor
	if (myfloor != null):
		myfloor.queue_free();
	match (customAppearance):
		Global.APP_SMB:
			inst = load("res://scenes/appearances/smb/blocks/falsefloor.tscn").instance();
		Global.APP_SMB3:
			inst = load("res://scenes/appearances/smb3/blocks/falsefloor.tscn").instance();
	get_parent().add_child(inst);
	myfloor = inst;
	inst.position = Vector2(position.x-26-52, position.y-26);
	#Flag Pole
	if (myflagpole != null):
		myflagpole.queue_free();
	match (customAppearance):
		Global.APP_SMB:
			inst = load("res://scenes/appearances/smb/flag_pole.tscn").instance();
		Global.APP_SMB3:
			inst = load("res://scenes/appearances/smb3/flag_pole.tscn").instance();
	myflagpole = inst;
	get_parent().add_child(inst);
	inst.position.x = position.x;
	inst.position.y = position.y-26;

func calculate(mpos, start = false, createLevelFloorObjectsAgain = false, customAppearance = null):
	yield(get_tree().create_timer(0.125), "timeout");
	var grid;
	if (start):
		grid = get_parent().calculateGlobalGrid(mpos.x, mpos.y);
	else:
		grid = get_parent().calculateGrid(mpos.x, mpos.y);
	if (grid.y > 29):
		return
	if (grid != current_grid && grid != null && grid.y >= 0 && grid.y <= get_parent().grid_size.y-1 && grid.x >= 25 && grid.x <= get_parent().grid_size.x-10):
		var changeCharPos = false;
		if (!start && get_node("../CharacterEditor").current_grid.y == current_grid.y-1 && get_parent().calculateGrid(get_node("../CharacterEditor").position.x, 0).x >= current_grid.x):
			changeCharPos = true;
		
		current_grid = grid;
		position = get_parent().calculateGridPosition(current_grid);
		
		if (myfloor == null || createLevelFloorObjectsAgain):
			createLevelFloorObjects(customAppearance);
		
		myfloor.position = Vector2(position.x-26-52, position.y-26);
		
		if (!start):
			get_node("../Editor/AudioGrabMove").play();
		
		if (myflagpole != null):
			myflagpole.position.x = position.x;
			myflagpole.position.y = position.y-26;
			
		if (changeCharPos):
			var charpos = get_node("../CharacterEditor").position;
			get_node("../CharacterEditor").calculate(Vector2(charpos.x, position.y-get_parent().increase), false, true);
			get_node("../CharacterEditor").select(true, true);
		
		emit_signal("endFloorChanged", current_grid);
		Global.emit_signal("floorErase");

func select():
	match (selected):
		true:
			selected = false;
			texture = load("res://sprites/ui/editor/floor_level.png");
			$ArrowUp.hide(); $BodyUp.hide();
			$ArrowDown.hide(); $BodyDown.hide();
			$ArrowLeft.hide(); $BodyLeft.hide();
			$ArrowRight.hide(); $BodyRight.hide();
			
			$MoveLeft.show();
			$MoveRight.show();
		false:
			selected = true;
			texture = load("res://sprites/ui/editor/floor_level_selected.png");
			$ArrowUp.show(); $BodyUp.show();
			$ArrowDown.show(); $BodyDown.show();
			$ArrowLeft.show(); $BodyLeft.show();
			$ArrowRight.show(); $BodyRight.show();
			get_node("../Editor/AudioGrab").play();
			
			$MoveLeft.hide();
			$MoveRight.hide();

func _on_ClickArea_gui_input(event):
	if (event is InputEventScreenTouch || event is InputEventScreenDrag):
		if (event.pressed && !selected):
			select();

func _on_ClickArea_mouse_entered():
	mouse_entered = true;

func _on_ClickArea_mouse_exited():
	mouse_entered = false;


func _on_LeftClickArea_gui_input(event):
	if (selected):
		return
	if (event is InputEventScreenTouch || event is InputEventScreenDrag || event is InputEventMouseButton):
		if (!event.pressed):
			calculate(Vector2(position.x-52, position.y));

func _on_RightClickArea_gui_input(event):
	if (selected):
		return
	if (event is InputEventScreenTouch || event is InputEventScreenDrag || event is InputEventMouseButton):
		if (!event.pressed):
			calculate(Vector2(position.x+52, position.y));
