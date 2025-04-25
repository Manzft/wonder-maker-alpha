extends Node2D

var selected = false;
var mouse_entered = false;
var mouse_selected = false;

var current_grid = Vector2();
var mygrid = Vector2();

var currentDefaultPowerup = "small";
var star = false;

var sweats = false;

onready var currentSprite = get_node("SMB");

var shadows = {
	"SMB": null,
	"SMB3": null
}

func add_shadow(ref):
	var sprite = AnimatedSprite.new();
	sprite.scale = scale;
	sprite.frames = ref.frames;
	sprite.animation = ref.animation;
	sprite.add_to_group("CharacterEditorShadow");
	get_node("../ViewportShadow/Shadows").add_child(sprite);
	return sprite

func _ready():
	shadows["SMB"] = add_shadow($SMB);
	shadows["SMB3"] = add_shadow($SMB3);
	yield(get_tree(), "idle_frame");
	calculate(position, true);
	current_grid = mygrid;

func _input(event):
	var chk = (event is InputEventKey);
	if (!chk && !get_node("../Editor").playing && !get_node("../Editor").eraseMode && !get_node("../LevelFloor").selected && !get_node("../EndFloor").selected):
		if (event is InputEventMouseButton):
			if (mouse_entered && Input.is_action_just_pressed("leftclick") && !selected):
				get_node("../Editor/CharTypeMenuTimer").start();
				get_node("../Editor").resetTypeMenu();
				select();
				Input.set_custom_mouse_cursor(load("res://sprites/ui/cursor_grab_editor.png"));
			if (Input.is_action_just_released("leftclick") && selected):
				yield(get_tree(), "idle_frame");
				select();
				Input.set_custom_mouse_cursor(load("res://sprites/ui/cursor_editor.png"));
		if (selected):
			var mpos = Vector2(0, 0);
			if (Global.CurrentInput != "Gamepad"):
				if (event is InputEventScreenDrag || event is InputEventScreenTouch || event is InputEventMouse):
					mpos = event.position+get_parent().get_node("Camera2D").position;
				calculate(mpos);
		if (event is InputEventScreenTouch):
			if (!event.pressed && selected):
				select();
			if (event.pressed):
				get_node("../Editor/CharTypeMenuTimer").start()
				get_node("../Editor").resetTypeMenu();
		elif (event is InputEventScreenDrag):
			if (!event.pressed && selected):
				select();
			if (event.pressed):
				get_node("../Editor/CharTypeMenuTimer").start()
				get_node("../Editor").resetTypeMenu();

func _process(_delta):
	shadows["SMB"].frame = $SMB.frame;
	shadows["SMB"].animation = $SMB.animation;
	shadows["SMB"].position = $SMB.global_position+Vector2(3*3.25, 3*3.25);
	shadows["SMB"].visible = $SMB.visible;
	
	shadows["SMB3"].frame = $SMB3.frame;
	shadows["SMB3"].animation = $SMB3.animation;
	shadows["SMB3"].position = $SMB3.global_position+Vector2(3*3.25, 3*3.25);
	shadows["SMB3"].visible = $SMB3.visible;
	
	if (!visible):
		shadows["SMB"].visible = false;
		shadows["SMB3"].visible = false;
	
	if (Global.CurrentInput == "Gamepad" && selected):
		var mpos = get_parent().get_node("Editor/GamepadCursor").rect_position+get_parent().get_node("Camera2D").position;
		calculate(mpos);
	if (!Global.playing):
		Global.charpos = position;
		
	if (star):
		$AnimationPlayer.play("star");
		$Light2D.enabled = true;
	else:
		$AnimationPlayer.play("RESET");
		$Light2D.enabled = false;
	
	Global.CurrentDefaultPowerup = currentDefaultPowerup;
	if (star):
		Global.CurrentStar = "true";
	else:
		Global.CurrentStar = "false";
	
	if (currentDefaultPowerup != "small"):
		currentSprite.position.y = -8;
	else:
		currentSprite.position.y = 0;
	
	match (Global.CurrentAppeareance):
		Global.APP_SMB:
			if (currentSprite != get_node("SMB")):
				currentSprite.hide()
				currentSprite = get_node("SMB");
				currentSprite.show();
				updateSprite()
		Global.APP_SMB3:
			if (currentSprite != get_node("SMB3")):
				currentSprite.hide()
				currentSprite = get_node("SMB3");
				currentSprite.show();
				updateSprite();

func calculate(mpos, start = false, var fl = false):
	var grid = get_parent().calculateGrid(mpos.x, mpos.y);
	
	position = mpos;
	
	if (grid != mygrid):
		mygrid = grid;
		if (!start && !fl):
			get_node("../Selection").position = get_parent().calculateGridPosition(grid);
			if (!get_node("../Editor/AudioGrabMove").playing):
				get_node("../Editor/AudioGrabMove").pitch_scale = rand_range(0.8, 1.2);
				get_node("../Editor/AudioGrabMove").play();
	
	if (!start):
		var limitdown = get_node("../Editor/SectionRight2").rect_position.y-25;
		var limitright = get_node("../Editor/SectionRightContainer/SectionRight").rect_position.x-48;
		var limitleft = get_node("../Editor/SectionLeft").rect_position.x+get_node("../Editor/SectionLeft").rect_size.x+25;
		if (get_node("../Editor/AppeareancesMenu").visible || get_node("../Editor/StylesMenu").visible):
			limitleft += 396;
		var limitup = get_node("../Editor/SectionTop").rect_position.y+get_node("../Editor/SectionTop").rect_size.y+25;
		
		var check = false;
		if (position.x-get_node("../Camera2D").position.x >= limitleft && position.x-get_node("../Camera2D").position.x <= limitright):
			if (position.y-get_node("../Camera2D").position.y >= limitup && position.y-get_node("../Camera2D").position.y <= limitdown):
				check = true;
		var check2 = get_parent().grid[grid.x][grid.y] != null;
		
		var poscheck = true;
		if (grid.x <= 6): 
			if (grid.y >= get_node("../LevelFloor").current_grid.y):
				poscheck = false;
		if (grid.x >= get_node("../EndFloor").current_grid.x):
			if (grid.y >= get_node("../EndFloor").current_grid.y):
				poscheck = false;
		
		if (!fl):
			if (check2 || !check || !poscheck):
				if (get_node("../Selection/AnimationPlayer").current_animation != "error"):
					get_node("../Selection/AnimationPlayer").play("error");
			else:
				get_node("../Selection/AnimationPlayer").play("RESET");

func select(var sel = null, var fl = false):
	if (sel != null):
		selected = sel;
	match (selected):
		true:
			currentSprite.play(currentDefaultPowerup+"_idle");
			selected = false;
			if (sweats):
				sweats_toggle();
			var limitdown = get_node("../Editor/SectionRight2").rect_position.y-25;
			var limitright = get_node("../Editor/SectionRightContainer/SectionRight").rect_position.x-48;
			var limitleft = get_node("../Editor/SectionLeft").rect_position.x+get_node("../Editor/SectionLeft").rect_size.x+25;
			if (get_node("../Editor/AppeareancesMenu").visible || get_node("../Editor/StylesMenu").visible):
				limitleft += 396;
			var limitup = get_node("../Editor/SectionTop").rect_position.y+get_node("../Editor/SectionTop").rect_size.y+25;
			
			var check = false;
			if (position.x-get_node("../Camera2D").position.x >= limitleft && position.x-get_node("../Camera2D").position.x <= limitright):
				if (position.y-get_node("../Camera2D").position.y >= limitup && position.y-get_node("../Camera2D").position.y <= limitdown):
					check = true;
					
			var poscheck = true;
			if (mygrid.x <= 6): 
				if (mygrid.y >= get_node("../LevelFloor").current_grid.y):
					poscheck = false;
			if (mygrid.x >= get_node("../EndFloor").current_grid.x):
				if (mygrid.y >= get_node("../EndFloor").current_grid.y):
					poscheck = false;
			
			if (fl):
				check = true;
			
			if (check && poscheck && get_parent().grid[mygrid.x][mygrid.y] == null):
				position = get_parent().calculateGridPosition(mygrid);
				current_grid = mygrid;
			else:
				position = get_parent().calculateGridPosition(current_grid);
			
			if (!fl):
				get_node("../Selection").queue_free();
			
			#texture = load("res://sprites/ui/editor/floor_level.png");
		false:
			currentSprite.play(currentDefaultPowerup+"_walk");
			selected = true;
			mouse_selected = true;
			var inst = load("res://scenes/ui/selection.tscn").instance();
			get_parent().add_child(inst);
			
			var part = load("res://scenes/ui/partgrab.tscn").instance();
			part.position = position;
			get_parent().add_child(part);
			
			if (!get_parent().get_node("Editor/AudioGrab").playing):
				get_parent().get_node("Editor/AudioGrab").pitch_scale = rand_range(0.8, 1.2);
				get_parent().get_node("Editor/AudioGrab").play();
			#texture = load("res://sprites/ui/editor/floor_level_selected.png");

func updateSprite():
	currentSprite.play(currentDefaultPowerup+"_idle");

func sweats_toggle():
	match (sweats):
		false:
			sweats = true;
			$SweatParticlesLeft.emitting = true;
			$SweatParticlesRight.emitting = true;
			currentSprite.play(currentDefaultPowerup+"_crouch");
		true:
			sweats = false;
			$SweatParticlesLeft.emitting = false;
			$SweatParticlesRight.emitting = false;
			currentSprite.play(currentDefaultPowerup+"_idle");

func _on_Area2D_mouse_entered():
	mouse_entered = true;

func _on_Area2D_mouse_exited():
	mouse_entered = false;
	if (!selected):
		mouse_selected = false;

func _on_Area2D_input_event(viewport, event, shape_idx):
	if (event is InputEventScreenTouch):
		if (event.pressed && !selected):
			select();
	elif (event is InputEventScreenDrag):
		if (!event.pressed && !selected):
			select();
