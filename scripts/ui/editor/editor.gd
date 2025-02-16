extends CanvasLayer

signal appearanceChanged

#var thread = Thread.new();

var timer = 0.0;

var gamepadCursor = false;

var CurrentMenu = "Editor";
var mouseFocus = "";
var savedFocus;
var buttonsClosed = false;

var eraseMode = false;

var playing = false;

var camera_speed = 1000;

var Score = 0;
var Coins = 0;
var time = 0.0;

var selected_objects = [];

var branchmenu = false;

var editingText = false;

var automaticSprint = false;

var editingSeaLevel = false;
var editingLavaLevel = false;

var changingLevel = false;
var changingTopLevel = false;

var currentTypeMenuObject = null;

var externalButton = false;

func checkSO(grid, code):
	var socheck = false;
	var gr = get_parent().grid[grid.x][grid.y];
	if (gr == Global.OBJ_BRICK || gr == Global.OBJ_LUCKYBLOCK || gr == Global.OBJ_INVISIBLE_LUCKYBLOCK):
		match (code):
			Global.OBJ_COIN:
				socheck = true;
			Global.OBJ_1UP:
				socheck = true;
			Global.OBJ_STAR:
				socheck = true;
			Global.OBJ_MUSHROOM:
				socheck = true;
			Global.OBJ_FIREFLOWER:
				socheck = true;
			Global.OBJ_GOOMBA:
				socheck = true;
			Global.OBJ_KOOPATROOPA:
				socheck = true;
			Global.OBJ_KOOPATROOPA_RED:
				socheck = true;
			Global.OBJ_SPINY:
				socheck = true;
			Global.OBJ_PIRANHAPLANT:
				socheck = true;
			Global.OBJ_P:
				socheck = true;
			Global.OBJ_PIRANHAPLANT_FIRE:
				socheck = true;
			Global.OBJ_GOOMBRAT:
				socheck = true;
			Global.OBJ_DRYBONES:
				socheck = true;
	return socheck;

func insideNode(code, node):
	match (code):
		Global.OBJ_COIN:
			node.coinInside = true;
			node.insided = true;
		Global.OBJ_1UP:
			node.oneup = true;
			node.insided = true;
		Global.OBJ_STAR:
			node.star = true;
			node.insided = true;
		Global.OBJ_MUSHROOM:
			node.mushroom = true;
			node.insided = true;
		Global.OBJ_FIREFLOWER:
			node.fireflower = true;
			node.insided = true;
			if (get_parent().grab_node.mushroom):
				node.a_mushroom = true;
		Global.OBJ_GOOMBA:
			node.goomba = true;
			node.insided = true;
		Global.OBJ_KOOPATROOPA:
			node.koopatroopa = true;
			node.insided = true;
		Global.OBJ_KOOPATROOPA_RED:
			node.koopatroopa_red = true;
			node.insided = true;
		Global.OBJ_SPINY:
			node.spiny = true;
			node.insided = true;
			if (get_parent().grab_node.alreadydead):
				node.a_alreadydead = true;
		Global.OBJ_PIRANHAPLANT:
			node.piranhaplant = true;
			node.insided = true;
		Global.OBJ_P:
			node.withp = true;
			node.insided = true;
		Global.OBJ_PIRANHAPLANT_FIRE:
			node.piranhaplantfire = true;
			node.insided = true;
		Global.OBJ_GOOMBRAT:
			node.goombrat = true;
			node.insided = true;
		Global.OBJ_DRYBONES:
			node.drybones = true;
			node.insided = true;

func _input(event):
	if (editingText):
		return;
	
	if (Global.coursePlaying || get_parent().startmenu):
		return;
	
	var chk = (event is InputEventKey);
	if (!playing && !chk):
		if (Global.CurrentInput == "Gamepad"):
			updateFocusSprite();
			$Controls.hide();
		var check = (event is InputEventScreenDrag || event is InputEventScreenTouch);
		#var check0 = (check && event.pressed);
		
		if !(event is InputEventJoypadButton || event is InputEventJoypadMotion):
			var chck = check || Input.is_action_pressed("leftclick") || Input.is_action_pressed("rightclick");
			var cpos = event.position+get_parent().get_node("Camera2D").position;
			if (eraseMode && abs(get_node("../CharacterEditor").position.x-cpos.x) <= 90 && abs(get_node("../CharacterEditor").position.y-cpos.y) <= 90):
				if (chck):
					if (!get_node("../CharacterEditor").sweats):
						get_node("../CharacterEditor").sweats_toggle();
			else:
				if (get_node("../CharacterEditor").sweats):
					get_node("../CharacterEditor").sweats_toggle();
		
		if (Input.is_action_pressed("leftclick") || check):
			if ($TypeMenu.visible):
				if (!check):
					closeMenus();
				else:
					if (check && event.pressed):
						closeMenus();
				return;
			if (externalButton && !check):
				return;
			
			#Sea Level Editing
			if (changingLevel):
				$SeaLevelButton.rect_global_position.y = event.position.y-26;
				
				if ($SeaLevelButton.rect_position.y < $SeaLevelTopButton.rect_position.y-6):
					$SeaLevelButton.rect_position.y = $SeaLevelTopButton.rect_position.y-6;
			
			if (changingTopLevel):
				$SeaLevelTopButton.rect_global_position.y = event.position.y-19;
				if ($SeaLevelTopButton.rect_position.y > $SeaLevelButton.rect_position.y+6):
					$SeaLevelTopButton.rect_position.y = $SeaLevelButton.rect_position.y+6;
			
			if (get_parent().editing && savedFocus == null && CurrentMenu == "Editor"):
				var limitdown = $SectionRight2.rect_position.y-25;
				var limitright = $SectionRightContainer/SectionRight.rect_position.x+$SectionRightContainer.rect_position.x-48;
				var limitleft = $SectionLeft.rect_position.x+$SectionLeft.rect_size.x+25;
				if ($AppeareancesMenu.visible || $StylesMenu.visible || $CameraMenu.visible || $TimeMenu.visible):
					limitleft += 396;
				if ($CoursebotMenuContainer/CoursebotMenu.visible):
					limitright -= 396;
				if ($CourseViewer.visible):
					limitdown -= 90;
				var limitup = $SectionTop.rect_position.y+$SectionTop.rect_size.y+25;
				
				if (check && get_parent().objSelected == -50 && !eraseMode && !get_parent().grab && !get_node("../EndFloor").selected && !get_node("../LevelFloor").selected && !get_node("../CharacterEditor").selected):
					#Up
					if (event.position.x >= limitleft-25 && event.position.x <= limitright+48):
						if (event.position.y >= limitup-25 && event.position.y <= limitup-25+80):
							Input.action_press("rup");
						
					#Down
					if (event.position.x >= limitleft-25 && event.position.x <= limitright+48):
						if (event.position.y >= limitdown+25-80 && event.position.y <= limitdown+25):
							Input.action_press("rdown");
					#Left
					if (event.position.x >= limitleft-25 && event.position.x <= limitleft-25+80):
						if (event.position.y >= limitup-25 && event.position.y <= limitdown+25):
							Input.action_press("rleft");
					#Right
					if (event.position.x >= limitright+48-80 && event.position.x <= limitright+48):
						if (event.position.y >= limitup-25 && event.position.y <= limitdown+25):
							Input.action_press("rright");
							
					if !(event is InputEventScreenDrag):
						if (!event.pressed):
							Input.action_release("rup");
							Input.action_release("rleft");
							Input.action_release("rright");
							Input.action_release("rdown");
						
					limitdown -= 80;
					limitup += 80;
					limitleft += 80;
					limitright -= 80;
				
				if (event.position.x >= limitleft && event.position.x <= limitright):
					if (event.position.y >= limitup && event.position.y <= limitdown):
							if (!get_parent().grab && !editingLavaLevel && !editingSeaLevel):
								if (!eraseMode):
									var press = false;
									if (event is InputEventMouseButton || event is InputEventScreenTouch):
										if (event.pressed):
											press = true;
									get_parent().placeObject(event.position+get_parent().get_node("Camera2D").position, press);
								else:
									Input.set_custom_mouse_cursor(load("res://sprites/ui/erasing_cursor.png"));
									get_parent().eraseObject(event.position+get_parent().get_node("Camera2D").position);
		var check2 = (event is InputEventScreenDrag || event is InputEventScreenTouch);
		var check3 = (check2 && !event.pressed);
		if (Input.is_action_just_released("leftclick") || check3):
			if (get_parent().editing && savedFocus == null && CurrentMenu == "Editor"):
				if (get_parent().grab):
					Input.set_custom_mouse_cursor(load("res://sprites/ui/cursor_editor.png"));
					#Move object in grid system
					var togrid;
					var eventpos = event.position;
					if (get_parent().grab_node.is_in_group("Extensible")):
						eventpos -= get_parent().grab_offset;
					togrid = get_parent().calculateGrid(eventpos.x+get_parent().get_node("Camera2D").position.x, eventpos.y+get_parent().get_node("Camera2D").position.y);
					
					#Object inside (or Special Object)
					var gr = get_parent().grab_grid;
					var socheck = checkSO(togrid, get_parent().grid[gr.x][gr.y]);
					if (socheck):
						var nodes =  get_tree().get_nodes_in_group("Insideable");
						for node in nodes:
							if (node.position == get_parent().calculateGridPosition(togrid)):
								insideNode(get_parent().grid[gr.x][gr.y], node);
								
						get_parent().grab_node.queue_free();
						get_parent().grid[gr.x][gr.y] = null;
						get_parent().grid_node[gr.x][gr.y] = null;
					
					var limitdown = $SectionRight2.rect_position.y-25;
					var limitright = $SectionRightContainer/SectionRight.rect_position.x+$SectionRightContainer.rect_position.x
					var limitleft = $SectionLeft.rect_position.x+$SectionLeft.rect_size.x+25;
					if ($AppeareancesMenu.visible || $StylesMenu.visible || $CameraMenu.visible || $TimeMenu.visible):
						limitleft += 396;
					if ($CoursebotMenuContainer/CoursebotMenu.visible):
						limitright -= 396;
					if ($CourseViewer.visible):
						limitdown -= 90;
					var limitup = $SectionTop.rect_position.y+$SectionTop.rect_size.y+25;
					
					check = false;
					if (event.position.x >= limitleft && event.position.x <= limitright):
						if (event.position.y >= limitup && event.position.y <= limitdown):
							check = true;
							
					var poscheck = true;
					if (togrid.x <= 6): 
						if (togrid.y >= get_node("../LevelFloor").current_grid.y):
							poscheck = false;
					if (togrid.x >= get_node("../EndFloor").current_grid.x):
						if (togrid.y >= get_node("../EndFloor").current_grid.y):
							poscheck = false;
					
					#Multiple Grids
					var mgcheck = true;
					if (get_parent().grab_node.is_in_group("Extensible")):
						for i in get_parent().grab_node.extension_grid_size:
							var g = get_parent().grab_node.default_extension_grid[i];
							if (get_parent().grid[togrid.x+g.x][togrid.y+g.y] != null && get_parent().grid_node[togrid.x+g.x][togrid.y+g.y] != get_parent().grab_node):
								mgcheck = false;
						if (get_parent().grid[togrid.x][togrid.y] != null && get_parent().grid_node[togrid.x][togrid.y] != get_parent().grab_node):
								mgcheck = false;
					else:
						mgcheck = !(get_parent().grid[togrid.x][togrid.y] != null && get_parent().grid_node[togrid.x][togrid.y] != get_parent().grab_node);
					
					if (!socheck):
						if (check && poscheck && mgcheck):
							if (get_parent().grab_node.is_in_group("Extensible")):
								for g in get_parent().grab_node.default_extension_grid:
									get_parent().grid[g.x+get_parent().grab_grid.x][g.y+get_parent().grab_grid.y] = null;
									get_parent().grid_node[g.x+get_parent().grab_grid.x][g.y+get_parent().grab_grid.y] = null;
								for g in get_parent().grab_node.default_extension_grid:
									get_parent().grid[g.x+togrid.x][g.y+togrid.y] = get_parent().grab_id;
									get_parent().grid_node[g.x+togrid.x][g.y+togrid.y] = get_parent().grab_node;
									
							get_parent().grid[get_parent().grab_grid.x][get_parent().grab_grid.y] = null;
							get_parent().grid_node[get_parent().grab_grid.x][get_parent().grab_grid.y] = null;
							get_parent().grid[togrid.x][togrid.y] = get_parent().grab_id;
							get_parent().grid_node[togrid.x][togrid.y] = get_parent().grab_node;
							get_parent().grab_node.position = get_parent().calculateGridPosition(togrid);
							
							if (get_parent().grab_node.is_in_group("Extensible")):
								get_parent().grab_node.setupExtensionGrids();
						else:
							get_parent().grab_node.position = get_parent().calculateGridPosition(get_parent().grab_grid);
						
						get_parent().grab_node.z_index = get_parent().grab_node_z_index;
				
					#Delete selection square
					get_node("../Selection").queue_free();
					
					#Deactivate grab mode
					get_parent().grab = false;
						
		if (get_parent().grab && Global.CurrentInput != "Gamepad"):
			Input.set_custom_mouse_cursor(load("res://sprites/ui/cursor_grab_editor.png"));
			var eventpos = event.position;
			if (get_parent().grab_node.is_in_group("Extensible")):
				eventpos -= get_parent().grab_offset;
			var grid = get_parent().calculateGrid(eventpos.x+get_parent().get_node("Camera2D").position.x, eventpos.y+get_parent().get_node("Camera2D").position.y);
			get_node("../Selection").position = get_parent().calculateGridPosition(grid);
			get_parent().grab_node.position = event.position+get_parent().get_node("Camera2D").position;
			get_parent().grab_node.position -= get_parent().grab_offset;
			
			if (grid != get_parent().current_grab_grid):
				if (!$AudioGrabMove.playing):
					$AudioGrabMove.pitch_scale = rand_range(0.8, 1.2);
					$AudioGrabMove.play();
				get_parent().current_grab_grid = grid;
			
			var limitdown = $SectionRight2.rect_position.y-25;
			var limitright = $SectionRightContainer/SectionRight.rect_position.x+$SectionRightContainer.rect_position.x
			var limitleft = $SectionLeft.rect_position.x+$SectionLeft.rect_size.x+25;
			if ($AppeareancesMenu.visible || $StylesMenu.visible || $CameraMenu.visible || $TimeMenu.visible):
				limitleft += 396;
			if ($CoursebotMenuContainer/CoursebotMenu.visible):
				limitright -= 396;
			if ($CourseViewer.visible):
				limitdown -= 90;
			var limitup = $SectionTop.rect_position.y+$SectionTop.rect_size.y+25;
			
			check = false;
			if (event.position.x >= limitleft && event.position.x <= limitright):
				if (event.position.y >= limitup && event.position.y <= limitdown):
					check = true;
			
			
			var poscheck = true;
			if (grid.x <= 6): 
				if (grid.y >= get_node("../LevelFloor").current_grid.y):
					poscheck = false;
			if (grid.x >= get_node("../EndFloor").current_grid.x):
				if (grid.y >= get_node("../EndFloor").current_grid.y):
					poscheck = false;
					
			var mgcheck = false;
			check2 = false;
			if (get_parent().grab_node.is_in_group("Extensible")):
				for i in get_parent().grab_node.extension_grid_size:
					var g = get_parent().grab_node.default_extension_grid[i];
					if (get_parent().grid[grid.x+g.x][grid.y+g.y] != null && get_parent().grid_node[grid.x+g.x][grid.y+g.y] != get_parent().grab_node):
						check2 = true;
				if (get_parent().grid[grid.x][grid.y] != null && get_parent().grid_node[grid.x][grid.y] != get_parent().grab_node):
						check2 = true;
			else:
				check2 = get_parent().grid[grid.x][grid.y] != null && get_parent().grid_node[grid.x][grid.y] != get_parent().grab_node;
			
			if (check2 || !check || !poscheck || mgcheck):
				if (get_node("../Selection/AnimationPlayer").current_animation != "error"):
					get_node("../Selection/AnimationPlayer").play("error");
			else:
				get_node("../Selection/AnimationPlayer").play("RESET");
			var gr = get_parent().grab_grid;
			var socheck = checkSO(grid, get_parent().grid[gr.x][gr.y]);
			
			if (socheck):
				if (get_node("../Selection/AnimationPlayer").current_animation != "so"):
					get_node("../Selection/AnimationPlayer").play("so");
		
		if (Input.is_action_pressed("rightclick")):
			if (get_parent().editing && savedFocus == null && CurrentMenu == "Editor"):
				if ($TypeMenu.visible):
					closeMenus();
					return
				var limitdown = $SectionRight2.rect_position.y-25;
				var limitright = $SectionRightContainer/SectionRight.rect_position.x+$SectionRightContainer.rect_position.x
				var limitleft = $SectionLeft.rect_position.x+$SectionLeft.rect_size.x+25;
				var limitup = $SectionTop.rect_position.y+$SectionTop.rect_size.y+25;
				
				if (event.position.x >= limitleft && event.position.x <= limitright):
					if (event.position.y >= limitup && event.position.y <= limitdown):
							if (!eraseMode):
								toggle_eraseMode();
								Input.set_custom_mouse_cursor(load("res://sprites/ui/erasing_cursor.png"));
							get_parent().eraseObject(event.position+get_parent().get_node("Camera2D").position);
		if (Input.is_action_just_released("rightclick")):
			if (eraseMode):
				toggle_eraseMode();
		if (Input.is_action_just_released("leftclick")):
			if (eraseMode):
				Input.set_custom_mouse_cursor(load("res://sprites/ui/erase_cursor.png"));

func getFocusNode():
	var nodes = get_tree().get_nodes_in_group("Button");
	for node in nodes:
		if (node.has_focus() || get_node(mouseFocus) == node):
			return node;

func focus_change():
	$AudioSelectButton.play();

func changeInput():
	var nodes = get_tree().get_nodes_in_group("Button");
	if (Global.CurrentInput == "Mouse"):
		if (!playing):
			mouseFocus = "";
			$FPS.grab_focus();
			
			gamepadCursor = false;
			$GamepadCursor.hide();
			hide_guides();
			if (buttonsClosed):
				$AnimationPlayer.play("in");
				buttonsClosed = false;
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	if (Global.CurrentInput == "Gamepad"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);
		if (CurrentMenu == "Editor"):
			if (!playing):
				$SectionTop/GamepadCursorGuide.show();
				$SectionTop/GamepadCursorGuideQuit.hide();
	if (savedFocus == null):
		changeFocus();
		
func hide_guides():
	$SectionTop/GamepadCursorGuide.hide();
	$SectionTop/GamepadCursorGuideQuit.hide();
	$SectionTop/GamepadButtonsQuitGuide.hide();
	$SectionTop/GamepadCursorSprintGuide.hide();
	$ShowButtonsGuide.hide();

func changeFocus():
	if (Global.CurrentInput == "Gamepad"):
		if (!gamepadCursor):
			match (CurrentMenu):
				"Editor":
					if (!playing):
						closeMenus();
						$SectionRightContainer/SectionRight/StartButton.grab_focus();
					else:
						$FPS.grab_focus();
		updateFocusSprite();
	else:
		updateFocusSprite();

func updateFocusSprite():
	var nodes = get_tree().get_nodes_in_group("Button");
	for node in nodes:
		var check;
		if (mouseFocus != "" && Global.CurrentInput != "Gamepad"):
			check = node.has_focus() || get_node(mouseFocus) == node;
		else:
			check = node.has_focus()
		if (check):
			node.get_node("Selection").show();
			node.get_node("Selection/AnimationPlayer").play("idle");
			#node.texture_normal = node.texture_hover;
		else:
			#node.texture_normal = node.texture_disabled;
			node.get_node("Selection").hide();
			node.get_node("Selection/AnimationPlayer").play("RESET");

func editorMusic(a, pause = false):
	var music = null;
	match (Global.CurrentAppeareance):
		Global.APP_SMB:
			music = get_node("EditorMusic/SMB/"+Global.CurrentStyle);
		Global.APP_SMB3:
			music = get_node("EditorMusic/SMB3/"+Global.CurrentStyle);
	
	if (music != null):
		if (!pause):
			var nodes = get_tree().get_nodes_in_group("Music");
			for node in nodes:
				node.stop();
			if (a):
				music.play();
			else:
				music.stop();
		else:
			if (a):
				music.stream_paused = true;
			else:
				music.stream_paused = false;

func _ready():
	#$AnimationPlayer.play("RESET");
	Global.connect("gameLoaded", self, "gameLoaded");
	
	#Transition
	Global.transition();
	
	$SeaLevelButton/AnimationPlayer.play("selected");
	$SeaLevelTopButton/AnimationPlayer.play("selected");
	$TimeMenu/Buttons/ClockMan/AnimationPlayer.play("round");
	
	yield(get_tree().create_timer(0.1), "timeout");
	
	if (Global.coursePlaying):
		pass
		#RichPresence.update_activity("PlayingCoursebot")
	
	if (!get_parent().startmenu && !Global.coursePlaying):
		editorMusic(true);
		#RichPresence.update_activity("Editing");
	
	for i in range(12): 
		selected_objects.append([]);
		selected_objects[i] = -50;
	
	selected_objects[0] = Global.OBJ_FLOOR;
	selected_objects[1] = Global.OBJ_BLOCK;
	selected_objects[2] = Global.OBJ_BRICK;
	selected_objects[3] = Global.OBJ_COIN;
	selected_objects[4] = Global.OBJ_LUCKYBLOCK;
	selected_objects[5] = Global.OBJ_PIPE;
	selected_objects[6] = Global.OBJ_MUSHROOM;
	selected_objects[7] = Global.OBJ_GOOMBA;
	selected_objects[8] = Global.OBJ_PIRANHAPLANT;
	selected_objects[9] = Global.OBJ_KOOPATROOPA;
	selected_objects[10] = Global.OBJ_10COIN;
	selected_objects[11] = Global.OBJ_ONOFFSWITCH2;
	
	updateObjectButtons();
	
	changeInput();
	
	#Connect button focus signals
	var nodes = get_tree().get_nodes_in_group("Button");
	for node in nodes:
		node.connect("focus_entered", self, "focus_change");
	
	yield(get_tree().create_timer(0.125), "timeout");
	
	prepareLoad();
	
func prepareLoad():
	if (Global.toLoad):
		Global.loadCourseData();
		if (!get_parent().startmenu):
			Global.toLoad = false;
		#savedFocus = getFocusNode();
		#Global.showMessage("Nivel cargado correctamente.", self);
		appearanceChange(Global.CurrentAppeareance, true);
		styleChange(Global.CurrentStyle, true);
	else:
		Global.currentlevel = "res://title level.wm"
		Global.currentCourseName = "Title Level";
		Global.loadCourseData();
		appearanceChange(Global.CurrentAppeareance, true);
		styleChange(Global.CurrentStyle, true);

func gameLoaded():
	if (Global.coursePlaying || get_parent().startmenu):
		_on_Play_pressed();
		get_parent().editing = false;

func toggle_gamepadCursor(closeMenus = true):
	if (!gamepadCursor):
		if (closeMenus):
			closeMenus();
		gamepadCursor = true;
		$GamepadCursor.show();
		$GamepadCursor.rect_position = $GamepadCursorDefaultPosition.rect_position;
		$GamepadCursor.grab_focus();
		$SectionTop/GamepadCursorGuide.hide();
		$SectionTop/GamepadCursorGuideQuit.show();
		$GamepadCursor/SprintGuide/AnimationPlayer.play("start");
		$SectionTop/GamepadButtonsQuitGuide.show();
		$SectionTop/GamepadCursorSprintGuide.show();
	else:
		toggle_buttons();

func toggle_buttons():
	if (!buttonsClosed):
		$AnimationPlayer.play("out");
		buttonsClosed = true;
		if (Global.CurrentInput == "Gamepad"):
			$SectionTop/GamepadCursorGuide.hide();
			$SectionTop/GamepadCursorGuideQuit.hide();
			$SectionTop/GamepadButtonsQuitGuide.hide();
			$SectionTop/GamepadCursorSprintGuide.hide();
	else:
		$AnimationPlayer.play("in");
		buttonsClosed = false;
		if (Global.CurrentInput == "Gamepad"):
			$SectionTop/GamepadCursorGuide.hide();
			$SectionTop/GamepadCursorGuideQuit.show();
			$SectionTop/GamepadButtonsQuitGuide.show();
			$SectionTop/GamepadCursorSprintGuide.show();

func selObj():
	var done = false;
	for i in range(12):
		if (selected_objects[i] == get_parent().objSelected):
			for j in range(12):
				if (11-j < i):
					selected_objects[11-j+1] = selected_objects[11-j];
			selected_objects[0] = get_parent().objSelected;
			done = true;
			break;
	if (!done):
		for j in range(12):
			if (11-j < 11):
				selected_objects[11-j+1] = selected_objects[11-j];
		selected_objects[0] = get_parent().objSelected;
		done = true;
	updateObjectButtons();

func toggle_eraseMode():
	if (eraseMode):
		eraseMode = false;
		if (Global.CurrentInput == "Gamepad"):
			$GamepadCursor.texture = load("res://sprites/ui/cursor_editor.png");
		else:
			Input.set_custom_mouse_cursor(load("res://sprites/ui/cursor_editor.png"));
		$SectionTop/EraseGuide.hide();
		$EraseBorder.hide();
		$AudioErase.stop();
	else:
		if (Global.CurrentInput == "Gamepad"):
			$GamepadCursor.texture = load("res://sprites/ui/erase_cursor.png");
		else:
			Input.set_custom_mouse_cursor(load("res://sprites/ui/erase_cursor.png"));
		#get_parent().objSelected = -50;
		#updateObjectButtons();
		eraseMode = true;
		$SectionTop/EraseGuide.show();
		$EraseBorder.show();
		$AudioErase.play();

func closeMenus():
	if ($AppeareancesMenu.visible):
		$AppeareancesMenu/AnimationPlayer.play("out");
		
		if (Global.CurrentInput == "Gamepad"):
			$SectionLeft/AspectButton.grab_focus();
			updateFocusSprite();
		$AudioOpenMenu.play();
	if ($StylesMenu.visible):
		$StylesMenu/AnimationPlayer.play("out");
		
		if (Global.CurrentInput == "Gamepad"):
			$SectionLeft/StyleButton.grab_focus();
			updateFocusSprite();
		$AudioOpenMenu.play();
	if ($CoursebotMenuContainer/CoursebotMenu.visible):
		$CoursebotMenuContainer/CoursebotMenu/AnimationPlayer.play("out");
		
		if (Global.CurrentInput == "Gamepad"):
			$SectionRightContainer/SectionRight/SavebotButton.grab_focus();
			updateFocusSprite();
		$AudioOpenMenu.play();
	if ($CameraMenu.visible):
		$CameraMenu/AnimationPlayer.play("out");
		
		if (Global.CurrentInput == "Gamepad"):
			$SectionLeft/RecButton.grab_focus();
			updateFocusSprite();
		$AudioOpenMenu.play();
	if ($CourseViewer.visible):
		$CourseViewer.hide();
		$SectionRightContainer/SectionRight/CourseViewerButton.show();
		
		if (Global.CurrentInput == "Gamepad"):
			$SectionRightContainer/SectionRight/CourseViewerButton.grab_focus();
			updateFocusSprite();
		$AudioOpenMenu.play();
	if ($TypeMenu.visible):
		$TypeMenu/AnimationPlayer.play("out");
		
		if (Global.CurrentInput == "Gamepad"):
			toggle_gamepadCursor(false);
	if (editingSeaLevel):
		editingSeaLevel = false;
		
		if (Global.CurrentInput == "Gamepad"):
			$SectionLeft/SeaLevelButton.grab_focus();
			updateFocusSprite();
	if ($TimeMenu.visible):
		$TimeMenu/AnimationPlayer.play("out");
		
		if (Global.CurrentInput == "Gamepad"):
			$SectionLeft/TimeButton.grab_focus();
			updateFocusSprite();
		$AudioOpenMenu.play();
	if (editingLavaLevel):
		editingLavaLevel = false;
		
		if (Global.CurrentInput == "Gamepad"):
			$SectionLeft/SeaLevelButton.grab_focus();
			updateFocusSprite();

func updateObjectButtons():
	for i in range(12):
		if (selected_objects[i] == -50):
			var a = "";
			a = str(i+1);
			get_node("SectionTop/ObjectButton"+a+"/Icon").texture = null;
			get_node("SectionTop/ObjectButton"+a).texture_normal = load("res://sprites/ui/editor/pick_object.png");
		else:
			var a = "";
			a = str(i+1);
			var selected = "";
			get_node("SectionTop/ObjectButton"+a+"/Icon").texture = Global.object[Global.CurrentAppeareance][selected_objects[i]][Global.OP_ICON];
			
			if (selected_objects[i] == get_parent().objSelected):
				selected = "_selected";
				get_node("SectionTop/ObjectButton"+a+"/Icon/AnimationPlayer").play("in");
			else:
				get_node("SectionTop/ObjectButton"+a+"/Icon/AnimationPlayer").play("RESET");
			
			get_node("SectionTop/ObjectButton"+a+"/HasVariants").visible = Global.hasVariants(selected_objects[i]);
			
			var category = Global.getCategory(selected_objects[i]);
			match (category):
				"Terrain":
					get_node("SectionTop/ObjectButton"+a).texture_normal = load("res://sprites/ui/editor/pick_object_terrain"+selected+".png");
				"Items":
					get_node("SectionTop/ObjectButton"+a).texture_normal = load("res://sprites/ui/editor/pick_object_items"+selected+".png");
				"Enemies":
					get_node("SectionTop/ObjectButton"+a).texture_normal = load("res://sprites/ui/editor/pick_object_enemies"+selected+".png");
				"Gizmos":
					get_node("SectionTop/ObjectButton"+a).texture_normal = load("res://sprites/ui/editor/pick_object"+selected+".png");

var moveCamToChar = false;

func _process(delta):
	Global.playing = playing;
	
	match (Global.CurrentAppeareance):
		Global.APP_SMB:
			$SectionLeft/AspectButton/Card.texture = load("res://sprites/ui/editor/appeareances/card_smb.png");
		Global.APP_SMB3:
			$SectionLeft/AspectButton/Card.texture = load("res://sprites/ui/editor/appeareances/card_smb3.png");
	
	if ($TimeMenu/Buttons/ClockMan.frame == 0):
		$TimeMenu/Buttons/ClockMan/Stick.position.y = -19;
	else:
		$TimeMenu/Buttons/ClockMan/Stick.position.y = -6;
		
	var seconds = "";
	var zeros = "000";

	seconds = str(Global.CurrentTime);
	
	zeros.erase(0, seconds.length());
	seconds = zeros+seconds;
		
	$SectionLeft/TimeButton/Text.text = seconds;
	$TimeMenu/Buttons/Time.text = seconds;
	
	var check = (Global.CurrentInput != "Gamepad" || playing);
	if (check && $ShowButtonsGuide.visible):
		$ShowButtonsGuide.hide();
		
	if (Global.CurrentMusic == "true"):
		$SectionLeft/MusicButton/IconOff.hide();
		$SectionLeft/MusicButton/IconOn.show();
	else:
		$SectionLeft/MusicButton/IconOn.hide();
		$SectionLeft/MusicButton/IconOff.show();
	
	var node = null;
	match Global.CurrentAppeareance:
		Global.APP_SMB:
			node = get_node("GameplayUI/SMB");
		Global.APP_SMB3:
			node = get_node("GameplayUI/SMB3");
	
	if (playing):
		if (Global.CurrentAppeareance == Global.APP_SMB):
			if (Coins > 99):
				get_node("../Character").get_node("1up").play();
				Coins = 0;
				var inst = load("res://scenes/appearances/smb/Score.tscn").instance();
				add_child(inst);
				inst.position = get_node("../Character").position;
				inst.position.y -= 26
				inst.get_node("Text").text = "1UP";
			
			if (time > -1 && !get_node("../Character").died && !get_node("../Character").in_flag_pole &&
			!get_node("../Character").course_clear):
				time -= delta;
			elif (!get_node("../Character").died && !get_node("../Character").in_flag_pole &&
			!get_node("../Character").course_clear):
				get_node("../Character").die();
			
			var coins = "";
			if (Coins < 10):
				coins = "0"+str(Coins);
			else:
				coins = str(Coins);
			node.get_node("CoinsIcon/CoinsText").text = "x"+coins;
			node.get_node("CoinsIcon/CoinsText/Shadow").text = "x"+coins;
			
			var score = "";
			zeros = "000000000";

			score = str(Score);
			
			zeros.erase(0, score.length());
			score = zeros+score;
			
			node.get_node("ScoreText").text = score;
			node.get_node("ScoreText/Shadow").text = score;
			
			seconds = "";
			zeros = "000";

			var tim = abs(round(time+1));
			if (tim > Global.CurrentTime):
				tim = Global.CurrentTime;
			seconds = str(tim);
			
			zeros.erase(0, seconds.length());
			seconds = zeros+seconds;
			
			node.get_node("ClockIcon/ClockText").text = seconds;
			node.get_node("ClockIcon/ClockText/Shadow").text = seconds;
		
		if (Global.CurrentAppeareance == Global.APP_SMB3):
			if (Coins > 99):
				get_node("../Character").get_node("1up").play();
				Coins = 0;
				var inst = load("res://scenes/appearances/smb3/Score.tscn").instance();
				add_child(inst);
				inst.position = get_node("../Character").position;
				inst.position.y -= 26
				inst.get_node("Text").hide()
				inst.get_node("1UP").show();
			
			if (time > -1 && !get_node("../Character").died && !get_node("../Character").in_flag_pole &&
			!get_node("../Character").course_clear):
				time -= delta;
			elif (!get_node("../Character").died && !get_node("../Character").in_flag_pole &&
			!get_node("../Character").course_clear):
				get_node("../Character").die();
			
			var coins = "";
			if (Coins < 10):
				coins = "0"+str(Coins);
			else:
				coins = str(Coins);
			node.get_node("CoinsIcon/CoinsText").text = "x"+coins;
			
			var score = "";
			zeros = "000000000";

			score = str(Score);
			
			zeros.erase(0, score.length());
			score = zeros+score;
			
			node.get_node("ScoreText").text = score;
			
			seconds = "";
			zeros = "000";

			var tim = abs(round(time+1));
			if (tim > Global.CurrentTime):
				tim = Global.CurrentTime;
			seconds = str(tim);
			
			zeros.erase(0, seconds.length());
			seconds = zeros+seconds;
			
			node.get_node("ClockIcon/ClockText").text = seconds;
			
			#Ready to Fly System
			var rtf = get_node("../Character").currentRTFLevel;
			if (rtf > 0):
				node.get_node("ReadyToFly/AnimationPlayer").play(str(rtf));
			else:
				node.get_node("ReadyToFly/AnimationPlayer").play("RESET");
	
	if (editingText):
		return;
	if (Global.toLoad):
		return;
	if (Global.coursePlaying):
		return;
	
	if (!playing):
		if (Global.CurrentStyle == "Forest"):
			$SectionLeft/SeaLevelButton.show();
		else:
			$SectionLeft/SeaLevelButton.hide();
			
		match (Global.CurrentSpeed):
			"None":
				$SectionLeft/RecButton/Icon.texture = load("res://sprites/ui/editor/rec_icon.png");
			"Slow":
				$SectionLeft/RecButton/Icon.texture = load("res://sprites/ui/editor/camera_speed_slow_icon.png");
			"Normal":
				$SectionLeft/RecButton/Icon.texture = load("res://sprites/ui/editor/camera_speed_normal_icon.png");
			"Fast":
				$SectionLeft/RecButton/Icon.texture = load("res://sprites/ui/editor/camera_speed_fast_icon.png");
		
		if ($CourseViewer.visible):
			#Meta
			var finalpos = 0;
			var endfloor_grid = Vector2();
			
			node = get_node("../EndFloor");
			endfloor_grid = get_parent().calculateGrid(node.position.x, node.position.y);
			
			finalpos = endfloor_grid.x/500;
			$CourseViewer/End.rect_position.x = 16+(804*finalpos);
			if ($CourseViewer/End.rect_position.x < 128):
				$CourseViewer/End.rect_position.x = 128;
			if ($CourseViewer/End.rect_position.x > 790):
				$CourseViewer/End.rect_position.x = 790;
				
			#Current Camera Position
			finalpos = 0;
			var campos = Vector2($GamepadCursorDefaultPosition.rect_position.x, $GamepadCursorDefaultPosition.rect_position.y);
			node = get_node("../Camera2D");
			var camera_grid = get_parent().calculateGrid(node.position.x-campos.x, node.position.y);
			
			finalpos = camera_grid.x/500;
			$CourseViewer/Position.rect_position.x = 16+32+((804-49)*finalpos);
			if ($CourseViewer/Position.rect_position.x < 66):
				$CourseViewer/Position.rect_position.x = 66;
			if ($CourseViewer/Position.rect_position.x+(63/2) > $CourseViewer/End.rect_position.x-26-4):
				$CourseViewer/Position.rect_position.x = $CourseViewer/End.rect_position.x-26-(63/2)-4;
		
		if (editingLavaLevel || editingSeaLevel):
			$BlackScreen.show();
			$SeaLevelButton.show();
			$SeaLevelTopButton.show();
			
			$SeaLevel.show();

			$SeaLevel.rect_position.y = $SeaLevelButton.rect_position.y;
			
			if ($SeaLevelButton.rect_position.y < $SeaLevelTopButton.rect_position.y-6):
				$SeaLevelButton.rect_position.y = $SeaLevelTopButton.rect_position.y-6;
			
			if ($SeaLevelTopButton.rect_position.y > $SeaLevelButton.rect_position.y+6):
				$SeaLevelTopButton.rect_position.y = $SeaLevelButton.rect_position.y+6;
			
			$SeaLevelSelected.rect_position.y = $SeaLevelTopButton.rect_position.y;
			if ($SeaLevelButton.rect_position.y-$SeaLevelTopButton.rect_position.y >= 12):
				$SeaLevelSelected.show();
			else:
				$SeaLevelSelected.hide();
		else:
			$SeaLevelSelected.hide();
			$SeaLevel.hide();
			$BlackScreen.hide();
			$SeaLevelButton.hide();
			$SeaLevelTopButton.hide();
		get_parent().seaLevelOffset = (720-$SeaLevelButton.rect_position.y-26)*-1;
		get_parent().seaTopLevelOffset = (720-$SeaLevelTopButton.rect_position.y-19)*-1;
		
		var cam_speed = camera_speed;
		
		if (Input.is_action_pressed("y") || Input.is_action_pressed("x") || Input.is_action_pressed("r")):
			cam_speed *= 2;
		
		if (Global.CurrentInput != "Gamepad"):
			if (Input.is_action_pressed("right")):
				get_parent().get_node("CharacterEditor").position.x += cam_speed*delta;
				moveCamToChar = true;
			if (Input.is_action_pressed("left")):
				get_parent().get_node("CharacterEditor").position.x -= cam_speed*delta;
				moveCamToChar = true;
			if (Input.is_action_pressed("up")):
				get_parent().get_node("CharacterEditor").position.y -= cam_speed*delta;
				moveCamToChar = true;
			if (Input.is_action_pressed("down")):
				get_parent().get_node("CharacterEditor").position.y += cam_speed*delta;
				moveCamToChar = true;
			
		if (Input.is_action_pressed("rright")):
			get_parent().get_node("CharacterEditor").position.x += cam_speed*delta;
			moveCamToChar = true;
		if (Input.is_action_pressed("rleft")):
			get_parent().get_node("CharacterEditor").position.x -= cam_speed*delta;
			moveCamToChar = true;
		if (Input.is_action_pressed("rup")):
			get_parent().get_node("CharacterEditor").position.y -= cam_speed*delta;
			moveCamToChar = true;
		if (Input.is_action_pressed("rdown")):
			get_parent().get_node("CharacterEditor").position.y += cam_speed*delta;
			moveCamToChar = true;
		
		var limitdown = 0; var limitright = 0; var limitleft = 0; var limitup = 0;
		limitdown = $SectionRight2.rect_position.y-50;
		limitright = $SectionRightContainer/SectionRight.rect_position.x+$SectionRightContainer.rect_position.x-75;
		limitleft = $SectionLeft.rect_position.x+$SectionLeft.rect_size.x+50;
		if ($AppeareancesMenu.visible || $StylesMenu.visible || $CameraMenu.visible || $TimeMenu.visible):
			limitleft += 396;
		if ($CoursebotMenuContainer/CoursebotMenu.visible):
			limitright -= 396;
		if ($CourseViewer.visible):
			limitdown -= 90;
		limitup = $SectionTop.rect_position.y+$SectionTop.rect_size.y+50;
		
		var charpos = get_node("../CharacterEditor").position-get_node("../Camera2D").position;
		
		var s = charpos.x > limitleft+25 && charpos.x < limitright-25 && charpos.y > limitup+25 && charpos.y < limitdown-25;
		
		#if (!get_node("../CharacterEditor").selected):
		#	moveCamToChar = true;
		
		if (get_node("../CharacterEditor").selected): moveCamToChar = false;
		
		if (moveCamToChar):
			var campos = Vector2($GamepadCursorDefaultPosition.rect_position.x, $GamepadCursorDefaultPosition.rect_position.y);
			get_parent().get_node("Camera2D").position = lerp(get_parent().get_node("Camera2D").position, get_parent().get_node("CharacterEditor").position-campos, 0.25);
			if (get_parent().get_node("Camera2D").position.x >= get_node("../CharacterEditor").position.x-campos.x-5):
				if (get_parent().get_node("Camera2D").position.x <= get_node("../CharacterEditor").position.x-campos.x+5):
					if (get_parent().get_node("Camera2D").position.y >= get_node("../CharacterEditor").position.y-campos.y-5):
						if (get_parent().get_node("Camera2D").position.y <= get_node("../CharacterEditor").position.y-campos.y+5):
							moveCamToChar = false;
		
		if (get_parent().get_node("Camera2D").position.y < 0): get_parent().get_node("Camera2D").position.y = 0;
		if (get_parent().get_node("Camera2D").position.x < 0): get_parent().get_node("Camera2D").position.x = 0;
		if (get_parent().get_node("Camera2D").position.y > 840): get_parent().get_node("Camera2D").position.y = 840;
		var px = get_node("../EndFloor").position.x+(52*9)-26-$SectionTop.rect_size.x;
		if (get_parent().get_node("Camera2D").position.x > px): get_parent().get_node("Camera2D").position.x = px;
		
		if (get_parent().get_node("CharacterEditor").position.y < 26): get_parent().get_node("CharacterEditor").position.y = 26;
		if (get_parent().get_node("CharacterEditor").position.x < 26): get_parent().get_node("CharacterEditor").position.x = 26;
		if (get_parent().get_node("CharacterEditor").position.y > 1533): get_parent().get_node("CharacterEditor").position.y = 1533;
		if (get_parent().get_node("CharacterEditor").position.x > get_node("../EndFloor").position.x+(52*9)-26): get_parent().get_node("CharacterEditor").position.x = get_node("../EndFloor").position.x+(52*9)-26;
		
		if (CurrentMenu == "Editor" && get_parent().editing):
			if (Global.CurrentInput == "Gamepad" && gamepadCursor):
				var cpos = $GamepadCursor.rect_position+get_parent().get_node("Camera2D").position;
				if (eraseMode && Input.is_action_pressed("a") && gamepadCursor && abs(get_node("../CharacterEditor").position.x-cpos.x) <= 90 && abs(get_node("../CharacterEditor").position.y-cpos.y) <= 90):
					if (!get_node("../CharacterEditor").sweats):
						get_node("../CharacterEditor").sweats_toggle();
				else:
					if (get_node("../CharacterEditor").sweats):
						get_node("../CharacterEditor").sweats_toggle();
			
			if (Input.is_action_pressed("a") && savedFocus == null && Global.CurrentInput == "Gamepad" && gamepadCursor):
				if (!externalButton):
					var pos = $GamepadCursor.rect_position+get_parent().get_node("Camera2D").position;
					var ipos = get_parent().get_node("LevelFloor").position;
					if (!get_parent().get_node("LevelFloor").selected && pos.x >= ipos.x-25.5 && pos.x <= ipos.x+25.5 && pos.y >= ipos.y-25.5 && pos.y <= ipos.y+25.5):
						get_parent().get_node("LevelFloor").select();
						$GamepadCursor.texture = load("res://sprites/ui/cursor_grab_editor.png");
						
					ipos = get_parent().get_node("EndFloor").position;
					if (!get_parent().get_node("EndFloor").selected && pos.x >= ipos.x-25.5 && pos.x <= ipos.x+25.5 && pos.y >= ipos.y-25.5 && pos.y <= ipos.y+25.5):
						get_parent().get_node("EndFloor").select();
						$GamepadCursor.texture = load("res://sprites/ui/cursor_grab_editor.png");
					
					if (!get_parent().grab):
						if (!eraseMode):
							var press = false;
							if (Input.is_action_just_pressed("a")):
								press = true;
							
							var vpos = get_node("../CharacterEditor").position;
							if (pos.x >= vpos.x-26 && pos.x <= vpos.x+26 && pos.y >= vpos.y-26 && pos.y <= vpos.y+26):
								if (press && !get_node("../CharacterEditor").selected && !get_node("../LevelFloor").selected && !get_node("../EndFloor").selected):
									get_node("../CharacterEditor").select();
									$GamepadCursor.texture = load("res://sprites/ui/cursor_grab_editor.png");
									$CharTypeMenuTimer.start();
									resetTypeMenu();
							else:
								get_parent().placeObject($GamepadCursor.rect_position+get_parent().get_node("Camera2D").position, press);
						else:
							$GamepadCursor.texture = load("res://sprites/ui/erasing_cursor.png");
							get_parent().eraseObject($GamepadCursor.rect_position+get_parent().get_node("Camera2D").position);
			if (Input.is_action_just_released("a") && savedFocus == null && Global.CurrentInput == "Gamepad" && gamepadCursor && eraseMode):
				$GamepadCursor.texture = load("res://sprites/ui/erase_cursor.png");
			elif (Input.is_action_just_released("a") && savedFocus == null && Global.CurrentInput == "Gamepad" && gamepadCursor && !eraseMode):
				if (get_parent().grab):
					gamepadReleaseGrab();
				else:
					if (get_parent().get_node("LevelFloor").selected):
						get_parent().get_node("LevelFloor").select();
						$GamepadCursor.texture = load("res://sprites/ui/cursor_editor.png");
					
					if (get_parent().get_node("EndFloor").selected):
						get_parent().get_node("EndFloor").select();
						$GamepadCursor.texture = load("res://sprites/ui/cursor_editor.png");
					
					if (get_parent().get_node("CharacterEditor").selected):
						get_node("../CharacterEditor").select();
						get_node("../CharacterEditor").mouse_selected = false;
						$GamepadCursor.texture = load("res://sprites/ui/cursor_editor.png");
			if (get_parent().grab && gamepadCursor):
				$GamepadCursor.texture = load("res://sprites/ui/cursor_grab_editor.png");
				var grid = get_parent().calculateGrid($GamepadCursor.rect_position.x+get_parent().get_node("Camera2D").position.x, $GamepadCursor.rect_position.y+get_parent().get_node("Camera2D").position.y);
				get_node("../Selection").position = get_parent().calculateGridPosition(grid);
				var eventpos = $GamepadCursor.rect_position;
				if (get_parent().grab_node.is_in_group("Extensible")):
					eventpos += get_parent().grab_offset;
				get_parent().grab_node.position = eventpos+get_parent().get_node("Camera2D").position;
				get_parent().grab_node.position -= get_parent().grab_offset;
				
				if (grid != get_parent().current_grab_grid):
					if (!$AudioGrabMove.playing):
						$AudioGrabMove.pitch_scale = rand_range(0.8, 1.2);
						$AudioGrabMove.play();
					get_parent().current_grab_grid = grid;
				
				
				var poscheck = true;
				if (grid.x <= 6): 
					if (grid.y >= get_node("../LevelFloor").current_grid.y):
						poscheck = false;
				if (grid.x >= get_node("../EndFloor").current_grid.x):
					if (grid.y >= get_node("../EndFloor").current_grid.y):
						poscheck = false;
				
				var mgcheck = false;
				if (get_parent().grab_node.is_in_group("Extensible")):
					for i in get_parent().grab_node.extension_grid_size:
						var g = get_parent().grab_node.default_extension_grid[i];
						if (get_parent().grid[grid.x+g.x][grid.y+g.y] != null && get_parent().grid_node[grid.x+g.x][grid.y+g.y] != get_parent().grab_node):
							check = true;
					if (get_parent().grid[grid.x][grid.y] != null && get_parent().grid_node[grid.x][grid.y] != get_parent().grab_node):
							check = true;
				else:
					check = get_parent().grid[grid.x][grid.y] != null && get_parent().grid_node[grid.x][grid.y] != get_parent().grab_node;
				
				if (check || !poscheck || mgcheck):
					if (get_node("../Selection/AnimationPlayer").current_animation != "error"):
						get_node("../Selection/AnimationPlayer").play("error");
				else:
					get_node("../Selection/AnimationPlayer").play("RESET");
					
				var gr = get_parent().grab_grid;
				var socheck = checkSO(grid, get_parent().grid[gr.x][gr.y]);
				if (socheck):
					if (get_node("../Selection/AnimationPlayer").current_animation != "so"):
						get_node("../Selection/AnimationPlayer").play("so");
			
			if (Input.is_action_just_pressed("start") && savedFocus == null && Global.CurrentInput == "Gamepad" && !gamepadCursor):
				_on_StartButton_pressed();
			if (Input.is_action_just_pressed("l") && savedFocus == null && Global.CurrentInput == "Gamepad"):
				_on_EraseButton_pressed();
			if (Input.is_action_just_pressed("b") && savedFocus == null && Global.CurrentInput == "Gamepad" && !gamepadCursor):
				closeMenus();
				#_on_UndoButton_pressed();
			if (Input.is_action_just_pressed("x") && savedFocus == null && Global.CurrentInput == "Gamepad"):
				toggle_gamepadCursor();
			if (Input.is_action_just_pressed("select") && Global.CurrentInput == "Gamepad"):
				_on_Play_pressed();
			if (Input.is_action_just_pressed("dup") || Input.is_action_just_pressed("dleft") || Input.is_action_just_pressed("dright") || Input.is_action_just_pressed("ddown")):
				if (gamepadCursor && !buttonsClosed):
					if (eraseMode): toggle_eraseMode();
					gamepadCursor = false;
					$GamepadCursor.hide();
					$SectionTop/GamepadCursorGuide.show();
					$SectionTop/GamepadCursorGuideQuit.hide();
					$SectionTop/GamepadButtonsQuitGuide.hide();
					$SectionTop/GamepadCursorSprintGuide.hide();
					if (Input.is_action_just_pressed("dleft")):
						$SectionLeft/AspectButton.grab_focus();
					if (Input.is_action_just_pressed("dup")):
						var a = 0;
						for i in range(12):
							if (selected_objects[i] == get_parent().objSelected):
								a = i;
								break;
						get_node("SectionTop/ObjectButton"+str(a+1)).grab_focus();
					if (Input.is_action_just_pressed("dright")):
						$SectionRightContainer/SectionRight/StartButton.grab_focus();
					if (Input.is_action_just_pressed("ddown")):
						$SectionRightContainer/SectionRight/CourseViewerButton.grab_focus();
					updateFocusSprite();
			if (gamepadCursor):
				var cursorSpeed = 7.5/0.016;
				var Movement = Vector2(0, 0);
				limitdown = $SectionRight2.rect_position.y-50;
				limitright = $SectionRightContainer/SectionRight.rect_position.x+$SectionRightContainer.rect_position.x-75;
				limitleft = $SectionLeft.rect_position.x+$SectionLeft.rect_size.x+50;
				if ($AppeareancesMenu.visible || $StylesMenu.visible || $CameraMenu.visible || $TimeMenu.visible):
					limitleft += 396;
				if ($CoursebotMenuContainer/CoursebotMenu.visible):
					limitright -= 396;
				if ($CourseViewer.visible):
					limitdown -= 90;
				limitup = $SectionTop.rect_position.y+$SectionTop.rect_size.y+50;
				if (Input.is_action_pressed("down") && $GamepadCursor.rect_position.y < limitdown): Movement.y = 1;
				if (Input.is_action_pressed("up") && $GamepadCursor.rect_position.y > limitup): Movement.y = -1;
				if (Input.is_action_pressed("right") && $GamepadCursor.rect_position.x < limitright): Movement.x = 1;
				if (Input.is_action_pressed("left") && $GamepadCursor.rect_position.x > limitleft): Movement.x = -1;
				
				if (Input.is_action_pressed("r")):
					cursorSpeed *= 2;
				$GamepadCursor.rect_position += (Movement.normalized())*(cursorSpeed*delta);
				
				if ($GamepadCursor.rect_position.y > limitdown): $GamepadCursor.rect_position.y = limitdown;
				if ($GamepadCursor.rect_position.y < limitup): $GamepadCursor.rect_position.y = limitup;
				if ($GamepadCursor.rect_position.x > limitright): $GamepadCursor.rect_position.x = limitright;
				if ($GamepadCursor.rect_position.x < limitleft): $GamepadCursor.rect_position.x = limitleft;
	else:
		if (Input.is_action_just_pressed("select") && Global.CurrentInput == "Gamepad"):
			_on_Edit_pressed();

func gamepadReleaseGrab():
	$GamepadCursor.texture = load("res://sprites/ui/cursor_editor.png");
	var togrid;
	var eventpos = $GamepadCursor.rect_position;
	if (get_parent().grab_node.is_in_group("Extensible")):
		eventpos -= get_parent().grab_offset;
	togrid = get_parent().calculateGrid(eventpos.x+get_parent().get_node("Camera2D").position.x, eventpos.y+get_parent().get_node("Camera2D").position.y);
	
	var poscheck = true;
	if (togrid.x <= 6): 
		if (togrid.y >= get_node("../LevelFloor").current_grid.y):
			poscheck = false;
	if (togrid.x >= get_node("../EndFloor").current_grid.x):
		if (togrid.y >= get_node("../EndFloor").current_grid.y):
			poscheck = false;
			
	#Object inside (or Special Object)
	var gr = get_parent().grab_grid;
	var socheck = checkSO(togrid, get_parent().grid[gr.x][gr.y]);
	if (socheck):
		var nodes =  get_tree().get_nodes_in_group("Insideable");
		for node in nodes:
			if (node.position == get_parent().calculateGridPosition(togrid)):
				insideNode(get_parent().grid[gr.x][gr.y], node);
				
		get_parent().grab_node.queue_free();
		get_parent().grid[gr.x][gr.y] = null;
		get_parent().grid_node[gr.x][gr.y] = null;
		
	var limitdown = $SectionRight2.rect_position.y-25;
	var limitright = $SectionRightContainer/SectionRight.rect_position.x+$SectionRightContainer.rect_position.x
	var limitleft = $SectionLeft.rect_position.x+$SectionLeft.rect_size.x+25;
	if ($AppeareancesMenu.visible || $StylesMenu.visible || $CameraMenu.visible || $TimeMenu.visible):
		limitleft += 396;
	if ($CoursebotMenuContainer/CoursebotMenu.visible):
		limitright -= 396;
	if ($CourseViewer.visible):
		limitdown -= 90;
	var limitup = $SectionTop.rect_position.y+$SectionTop.rect_size.y+25;
	
	var check = false;
	if (eventpos.x >= limitleft && eventpos.x <= limitright):
		if (eventpos.y >= limitup && eventpos.y <= limitdown):
			check = true;
	
	#Multiple Grids
	var mgcheck = true;
	if (get_parent().grab_node.is_in_group("Extensible")):
		for i in get_parent().grab_node.extension_grid_size:
			var g = get_parent().grab_node.default_extension_grid[i];
			if (get_parent().grid[togrid.x+g.x][togrid.y+g.y] != null && get_parent().grid_node[togrid.x+g.x][togrid.y+g.y] != get_parent().grab_node):
				mgcheck = false;
		if (get_parent().grid[togrid.x][togrid.y] != null && get_parent().grid_node[togrid.x][togrid.y] != get_parent().grab_node):
				mgcheck = false;
	else:
		mgcheck = !(get_parent().grid[togrid.x][togrid.y] != null && get_parent().grid_node[togrid.x][togrid.y] != get_parent().grab_node);
	
	if (!socheck):
		if (check && poscheck && mgcheck):
			if (get_parent().grab_node.is_in_group("Extensible")):
				for g in get_parent().grab_node.default_extension_grid:
					get_parent().grid[g.x+get_parent().grab_grid.x][g.y+get_parent().grab_grid.y] = null;
					get_parent().grid_node[g.x+get_parent().grab_grid.x][g.y+get_parent().grab_grid.y] = null;
				for g in get_parent().grab_node.default_extension_grid:
					get_parent().grid[g.x+togrid.x][g.y+togrid.y] = get_parent().grab_id;
					get_parent().grid_node[g.x+togrid.x][g.y+togrid.y] = get_parent().grab_node;
					
			get_parent().grid[get_parent().grab_grid.x][get_parent().grab_grid.y] = null;
			get_parent().grid_node[get_parent().grab_grid.x][get_parent().grab_grid.y] = null;
			get_parent().grid[togrid.x][togrid.y] = get_parent().grab_id;
			get_parent().grid_node[togrid.x][togrid.y] = get_parent().grab_node;
			get_parent().grab_node.position = get_parent().calculateGridPosition(togrid);
			
			if (get_parent().grab_node.is_in_group("Extensible")):
				get_parent().grab_node.setupExtensionGrids();
		else:
			get_parent().grab_node.position = get_parent().calculateGridPosition(get_parent().grab_grid);
		
		get_parent().grab_node.z_index = get_parent().grab_node_z_index;

	#Delete selection square
	get_node("../Selection").queue_free();
	
	#Deactivate grab mode
	get_parent().grab = false;

func sidemenu():
	if (CurrentMenu == "Editor"):
		$AnimationPlayer.play("sidemenu");
		CurrentMenu = "SideMenu";
		changeFocus();
		$SideMenu.changeFocus();
		editorMusic(true, true);
	elif (CurrentMenu == "SideMenu"):
		CurrentMenu = "Editor";
		$AnimationPlayer.play_backwards("sidemenu");
		$SideMenu.changeFocus();
		changeFocus();
		editorMusic(false, true);

#General
func button_mouse_entered():
	$AudioSelectButton.pitch_scale = rand_range(0.9, 1.1);
	$AudioSelectButton.play();
	get_node(mouseFocus+"/Selection/AnimationPlayer").play("idle");
	changeFocus();
	#Input.set_custom_mouse_cursor(load("res://sprites/ui/cursor.png"));

func button_mouse_exited():
	$FPS.grab_focus();
	if (mouseFocus != ""):
		get_node(mouseFocus+"/Selection/AnimationPlayer").play("RESET");
	changeFocus();
	#Input.set_custom_mouse_cursor(load("res://sprites/ui/cursor_editor.png"));

#Section Right
func _on_StartButton_pressed():
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!.", self);
	sidemenu();
	$AudioStart.play();
func _on_StartButton_mouse_entered():
	mouseFocus = "SectionRightContainer/SectionRight/StartButton"; button_mouse_entered(); changeFocus();
func _on_StartButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_SavebotButton_pressed():
	closeMenus();
	if (!$CoursebotMenuContainer/CoursebotMenu.visible):
		$AudioCoursebotOpen.play()
		$CoursebotMenuContainer/CoursebotMenu/AnimationPlayer.play("in");
		$CoursebotMenuContainer/CoursebotMenu.show();
		if (Global.CurrentInput == "Gamepad"):
			$CoursebotMenuContainer/CoursebotMenu/SaveNewCourse.grab_focus();
			updateFocusSprite();
	else:
		$AudioOpenMenu.play();
func _on_SavebotButton_mouse_entered():
	mouseFocus = "SectionRightContainer/SectionRight/SavebotButton"; button_mouse_entered(); changeFocus();
func _on_SavebotButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_EraseButton_pressed():
	if (Global.CurrentInput == "Gamepad" && !gamepadCursor):
		toggle_gamepadCursor();
	toggle_eraseMode();
	$AudioOpenMenu.play();
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!.", self);
	#$AudioButton.play();
func _on_EraseButton_mouse_entered():
	mouseFocus = "SectionRightContainer/SectionRight/EraseButton"; button_mouse_entered(); changeFocus();
func _on_EraseButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_UndoButton_pressed():
	savedFocus = getFocusNode();
	Global.showMessage("¡Aún estamos trabajando en esto!.", self);
	$AudioButton.play();
func _on_UndoButton_mouse_entered():
	mouseFocus = "SectionRightContainer/SectionRight/UndoButton"; button_mouse_entered(); changeFocus();
func _on_UndoButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_ResetButton_pressed():
	$Reset/AnimationPlayer.play("go");
	$Reset.show();
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!.", self);
	$AudioOpenMenu.play();
func _on_ResetButton_button_up():
	$Reset/AnimationPlayer.play("RESET");
	$Reset.hide();
func _on_ResetButton_mouse_entered():
	mouseFocus = "SectionRightContainer/SectionRight/ResetButton"; button_mouse_entered(); changeFocus();
func _on_ResetButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_CourseViewerButton_pressed():
#	savedFocus = getFocusNode();
#	Global.showMessage("¡Aún estamos trabajando en esto!.", self);
	closeMenus();
	$AudioOpenMenu.play();
	$CourseViewer.show();
	if (Global.CurrentInput == "Gamepad"):
		$CourseViewer/Back.grab_focus();
		updateFocusSprite();
	$SectionRightContainer/SectionRight/CourseViewerButton.hide();
func _on_CourseViewerButton_mouse_entered():
	mouseFocus = "SectionRightContainer/SectionRight/CourseViewerButton"; button_mouse_entered(); changeFocus();
func _on_CourseViewerButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

#Course Viewer
func _on_BackCourseViewerButton_pressed():
#	savedFocus = getFocusNode();
#	Global.showMessage("¡Aún estamos trabajando en esto!.", self);
	closeMenus();
	$AudioCloseMenu.play();
	$CourseViewer.hide();
	if (Global.CurrentInput == "Gamepad"):
		$SectionRightContainer/SectionRight/CourseViewerButton.grab_focus();
		updateFocusSprite();
	$SectionRightContainer/SectionRight/CourseViewerButton.show();
func _on_BackCourseViewerButton_mouse_entered():
	mouseFocus = "CourseViewer/Back"; button_mouse_entered(); changeFocus();
func _on_BackCourseViewerButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_StartCourseViewerButton_pressed():
	$AudioPress.play();
	get_node("../CharacterEditor").position.x = get_parent().calculateGridPosition(Vector2(4, 0)).x;
func _on_StartCourseViewerButton_mouse_entered():
	mouseFocus = "CourseViewer/Start"; button_mouse_entered(); changeFocus();
func _on_StartCourseViewerButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_EndCourseViewerButton_pressed():
	$AudioPress.play();
	get_node("../CharacterEditor").position.x = get_node("../EndFloor").position.x;
func _on_EndCourseViewerButton_mouse_entered():
	mouseFocus = "CourseViewer/End"; button_mouse_entered(); changeFocus();
func _on_EndCourseViewerButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

#Section Top
func _on_SearchButton_pressed():
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!.", self);
	if (CurrentMenu == "Editor"):
		$Selector.show();
		$Selector.start();
		$AnimationPlayer.play("out");
		if (eraseMode): toggle_eraseMode();
		CurrentMenu = "Selector";
		$AudioOpenMenu.play();
		$Play.hide();
		closeMenus();
func _on_SearchButton_mouse_entered():
	mouseFocus = "SectionTop/SearchButton"; button_mouse_entered(); changeFocus();
func _on_SearchButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

#Section Left
func _on_AspectButton_pressed():
	closeMenus();
	if (!$AppeareancesMenu.visible):
		$AudioOpenPanel.play();
		$AppeareancesMenu/AnimationPlayer.play("in");
		$AppeareancesMenu.show();
		yield(get_tree().create_timer(0.5), "timeout");
		if (Global.CurrentInput == "Gamepad" && $AppeareancesMenu/AnimationPlayer.current_animation != "out"):
			$AppeareancesMenu/SMBButton.grab_focus();
			updateFocusSprite();
	else:
		$AudioOpenMenu.play();
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!.", self);
func _on_AspectButton_mouse_entered():
	mouseFocus = "SectionLeft/AspectButton"; button_mouse_entered(); changeFocus();
func _on_AspectButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_StyleButton_pressed():
	closeMenus();
	if (!$StylesMenu.visible):
		$AudioOpenPanel.play();
		$StylesMenu/AnimationPlayer.play("in");
		$StylesMenu.show();
		yield(get_tree().create_timer(0.5), "timeout");
		if (Global.CurrentInput == "Gamepad" && $StylesMenu/AnimationPlayer.current_animation != "out"):
			$StylesMenu/Buttons/GroundButton.grab_focus();
			updateFocusSprite();
	else:
		$AudioOpenMenu.play();
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!.", self);
func _on_StyleButton_mouse_entered():
	mouseFocus = "SectionLeft/StyleButton"; button_mouse_entered(); changeFocus();
func _on_StyleButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_SeaLevelButton_pressed():
	savedFocus = getFocusNode();
	Global.showMessage("¡Aún estamos trabajando en esto!", self);
	$AudioOpenMenu.play();
#	if (!editingSeaLevel):
#		editingSeaLevel = true;
#	else:
#		closeMenus();
	return
func _on_SeaLevelButton_mouse_entered():
	mouseFocus = "SectionLeft/SeaLevelButton"; button_mouse_entered(); changeFocus();
func _on_SeaLevelButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_RecButton_pressed():
	closeMenus();
	if (!$CameraMenu.visible):
		$AudioOpenPanel.play();
		$CameraMenu/AnimationPlayer.play("in");
		$CameraMenu.show();
		yield(get_tree().create_timer(0.5), "timeout");
		if (Global.CurrentInput == "Gamepad" && $CameraMenu/AnimationPlayer.current_animation != "out"):
			$CameraMenu/Buttons/None.grab_focus();
			updateFocusSprite();
	else:
		$AudioOpenMenu.play();
func _on_RecButton_mouse_entered():
	mouseFocus = "SectionLeft/RecButton"; button_mouse_entered(); changeFocus();
func _on_RecButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_TimeButton_pressed():
	closeMenus();
	if (!$TimeMenu.visible):
		$AudioOpenPanel.play();
		$TimeMenu/AnimationPlayer.play("in");
		$TimeMenu.show();
		yield(get_tree().create_timer(0.5), "timeout");
		if (Global.CurrentInput == "Gamepad" && $TimeMenu/AnimationPlayer.current_animation != "out"):
			$TimeMenu/Buttons/Up000.grab_focus();
			updateFocusSprite();
	else:
		$AudioOpenMenu.play();
func _on_TimeButton_mouse_entered():
	mouseFocus = "SectionLeft/TimeButton"; button_mouse_entered(); changeFocus();
func _on_TimeButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_MusicButton_pressed():
	closeMenus();
	if (Global.CurrentMusic == "true"):
		Global.CurrentMusic = "false";
		$AudioOpenMenu.play();
	else:
		Global.CurrentMusic = "true";
		$AudioOpenMenu.play();
func _on_MusicButton_mouse_entered():
	mouseFocus = "SectionLeft/MusicButton"; button_mouse_entered(); changeFocus();
func _on_MusicButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

#Objects Section (Top)
func objectButtonPressed(var num):
	if (selected_objects[num-1] >= 0):
		if (get_parent().objSelected != selected_objects[num-1]):
			get_parent().objSelected = selected_objects[num-1];
			updateObjectButtons();
			if (Global.CurrentInput == "Gamepad"):
				toggle_gamepadCursor();
		else:
			get_parent().objSelected = -50;
			updateObjectButtons();
			if (Global.CurrentInput == "Gamepad"):
				toggle_gamepadCursor();
	if (eraseMode):
		toggle_eraseMode();
	$AudioPress.play();

func _on_ObjectButton1_pressed():
	objectButtonPressed(1);
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!.", self);
func _on_ObjectButton1_mouse_entered():
	mouseFocus = "SectionTop/ObjectButton1"; button_mouse_entered(); changeFocus();
func _on_ObjectButton1_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();
	
func _on_ObjectButton2_pressed():
	objectButtonPressed(2);
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!.", self);
func _on_ObjectButton2_mouse_entered():
	mouseFocus = "SectionTop/ObjectButton2"; button_mouse_entered(); changeFocus();
func _on_ObjectButton2_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();
	
func _on_ObjectButton3_pressed():
	objectButtonPressed(3);
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!.", self);
func _on_ObjectButton3_mouse_entered():
	mouseFocus = "SectionTop/ObjectButton3"; button_mouse_entered(); changeFocus();
func _on_ObjectButton3_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();
	
func _on_ObjectButton4_pressed():
	objectButtonPressed(4);
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!.", self);
func _on_ObjectButton4_mouse_entered():
	mouseFocus = "SectionTop/ObjectButton4"; button_mouse_entered(); changeFocus();
func _on_ObjectButton4_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();
	
func _on_ObjectButton5_pressed():
	objectButtonPressed(5);
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!.", self);
func _on_ObjectButton5_mouse_entered():
	mouseFocus = "SectionTop/ObjectButton5"; button_mouse_entered(); changeFocus();
func _on_ObjectButton5_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_ObjectButton6_pressed():
	objectButtonPressed(6);
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!.", self);
func _on_ObjectButton6_mouse_entered():
	mouseFocus = "SectionTop/ObjectButton6"; button_mouse_entered(); changeFocus();
func _on_ObjectButton6_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();
	
func _on_ObjectButton7_pressed():
	objectButtonPressed(7);
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!.", self);
func _on_ObjectButton7_mouse_entered():
	mouseFocus = "SectionTop/ObjectButton7"; button_mouse_entered(); changeFocus();
func _on_ObjectButton7_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();
	
func _on_ObjectButton8_pressed():
	objectButtonPressed(8);
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!.", self);
func _on_ObjectButton8_mouse_entered():
	mouseFocus = "SectionTop/ObjectButton8"; button_mouse_entered(); changeFocus();
func _on_ObjectButton8_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();
	
func _on_ObjectButton9_pressed():
	objectButtonPressed(9);
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!.", self);
func _on_ObjectButton9_mouse_entered():
	mouseFocus = "SectionTop/ObjectButton9"; button_mouse_entered(); changeFocus();
func _on_ObjectButton9_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();
	
func _on_ObjectButton10_pressed():
	objectButtonPressed(10);
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!.", self);
func _on_ObjectButton10_mouse_entered():
	mouseFocus = "SectionTop/ObjectButton10"; button_mouse_entered(); changeFocus();
func _on_ObjectButton10_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();
	
func _on_ObjectButton11_pressed():
	objectButtonPressed(11);
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!.", self);
func _on_ObjectButton11_mouse_entered():
	mouseFocus = "SectionTop/ObjectButton11"; button_mouse_entered(); changeFocus();
func _on_ObjectButton11_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();
	
func _on_ObjectButton12_pressed():
	objectButtonPressed(12);
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!.", self);
func _on_ObjectButton12_mouse_entered():
	mouseFocus = "SectionTop/ObjectButton12"; button_mouse_entered(); changeFocus();
func _on_ObjectButton12_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

#Appeareances Menu
func _on_AppeareancesMenuCloseButton_pressed():
	closeMenus();
	$AudioCloseMenu.play();
func _on_AppeareancesMenuCloseButton_mouse_entered():
	mouseFocus = "AppeareancesMenu/CloseButton"; button_mouse_entered(); changeFocus();
func _on_AppeareancesMenuCloseButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func appearanceChange(app, start = false):
	if (app == Global.CurrentAppeareance && !start):
		return
	
	if (!playing):
		editorMusic(false, false);
	
	Global.CurrentAppeareance = app;
	updateObjectButtons();
	
	if (!playing):
		editorMusic(true, false);
	
	if (!start):
		#var objects = 0;
		var nodes = get_tree().get_nodes_in_group("Obj");
		for node in nodes:
			#objects += 1;
			var pos = node.position;
			var grid = get_parent().calculateGrid(pos.x, pos.y);
			var obj = get_parent().grid[grid.x][grid.y];
			
			#print("Object "+str(objects)+": "+Global.object[Global.CurrentAppeareance][obj][Global.OP_NAME]);
			
			if (obj != null && node != null):
				var scene = Global.object[Global.CurrentAppeareance][obj][Global.OP_SCENE];
				var inst = scene.instance();
				get_parent().grid_node[grid.x][grid.y] = inst;
				get_parent().add_child(inst);
				inst.position = pos;
				
				if (node.is_in_group("Extensible")):
					for i in range(node.extension_grid_size):
						get_parent().grid_node[node.extension_grid[i].x][node.extension_grid[i].y] = inst;
					inst.setGrids(obj);
					
				if (node.is_in_group("Insideable")):
					inst.coinInside = node.coinInside;
					inst.oneup = node.oneup;
					inst.star = node.star;
					inst.mushroom = node.mushroom;
					inst.fireflower = node.fireflower;
					inst.goomba = node.goomba;
					inst.koopatroopa = node.koopatroopa;
					inst.koopatroopa_red = node.koopatroopa_red;
					inst.spiny = node.spiny;
					inst.piranhaplant = node.piranhaplant;
					inst.withp = node.withp;
					inst.piranhaplantfire = node.piranhaplantfire;
					inst.goombrat = node.goombrat;
					inst.drybones = node.drybones;

					inst.insided = node.insided;

					inst.a_mushroom = node.a_mushroom;
					inst.a_alreadydead = node.a_alreadydead;
					
				if (node.is_in_group("Fireflower")):
					inst.mushroom = node.mushroom;
						
				if (node.is_in_group("Spiny")):
					inst.alreadydead = node.alreadydead;
				
				if (node.is_in_group("Twomp") ||
				node.is_in_group("Burner") ||
				node.is_in_group("Checkpoint") ||
				node.is_in_group("Arrow") ||
				node.is_in_group("Pipe")):
					inst.seldirection = node.seldirection;
				
				node.queue_free();
		
		styleChange(Global.CurrentStyle);
	
	emit_signal("appearanceChanged", app);

	#thread.wait_to_finish();
	print("Appearance Changed Successfully");

func _on_SMBButton_pressed():
	$AudioBigButton.play();
	#appearanceChange(Global.APP_SMB);
	#thread.start(self, "appearanceChange", Global.APP_SMB);
	appearanceChange(Global.APP_SMB);
	closeMenus();
func _on_SMBButton_mouse_entered():
	mouseFocus = "AppeareancesMenu/SMBButton"; button_mouse_entered(); changeFocus();
func _on_SMBButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_SMB3Button_pressed():
	$AudioBigButton.play();
	var thread = Thread.new();
	#thread.start(self, "appearanceChange", Global.APP_SMB3);
	appearanceChange(Global.APP_SMB3);
	closeMenus();
func _on_SMB3Button_mouse_entered():
	mouseFocus = "AppeareancesMenu/SMB3Button"; button_mouse_entered(); changeFocus();
func _on_SMB3Button_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

#Styles Menu
func _on_StylesMenuCloseButton_pressed():
	if (Global.CurrentInput == "Gamepad"):
		$SectionLeft/StyleButton.grab_focus();
		updateFocusSprite();
	closeMenus();
	$AudioCloseMenu.play();
func _on_StylesMenuCloseButton_mouse_entered():
	mouseFocus = "StylesMenu/CloseButton"; button_mouse_entered(); changeFocus();
func _on_StylesMenuCloseButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

#Coursebot
func _on_CoursebotMenuCloseButton_pressed():
	closeMenus();
	if (Global.CurrentInput == "Gamepad"):
		$SectionRightContainer/SectionRight/SavebotButton.grab_focus();
		updateFocusSprite();
	$AudioCoursebotClose.play();
func _on_CoursebotMenuCloseButton_mouse_entered():
	mouseFocus = "CoursebotMenuContainer/CoursebotMenu/CloseButton"; button_mouse_entered(); changeFocus();
func _on_CoursebotMenuCloseButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func styleChange(style, start = false):
	if (!start):
		editorMusic(false)
	Global.CurrentStyle = style;
	get_parent().setStyleBackground();
	if (style == "Ghosthouse" || style == "Underground" || style == "Forest"):
		get_parent().get_node("TileMap").modulate.r = 255;
		get_parent().get_node("TileMap").modulate.g = 255;
		get_parent().get_node("TileMap").modulate.b = 255;
	else:
		get_parent().get_node("TileMap").modulate.r = 0;
		get_parent().get_node("TileMap").modulate.g = 0;
		get_parent().get_node("TileMap").modulate.b = 0;
	var nodes = get_tree().get_nodes_in_group("Obj");
	for node in nodes:
		node.styleChanged();
	nodes = get_tree().get_nodes_in_group("StartSign");
	for node in nodes:
		node.styleChanged();
	
	$SectionLeft/StyleButton/Icon.texture = load("res://sprites/ui/editor/styles/icon_"+Global.CurrentStyle+".png");
	
	if (!start):
		editorMusic(true);
		closeMenus();
		
	#updateObjectButtons();

func _on_GroundButton_pressed():
	styleChange("Ground");
	$AudioBigButton.play();
	if (Global.CurrentInput == "Gamepad"):
		$SectionLeft/StyleButton.grab_focus();
		updateFocusSprite();
func _on_GroundButton_mouse_entered():
	mouseFocus = "StylesMenu/Buttons/GroundButton"; button_mouse_entered(); changeFocus();
func _on_GroundButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_UndergroundButton_pressed():
	styleChange("Underground");
	$AudioBigButton.play();
	if (Global.CurrentInput == "Gamepad"):
		$SectionLeft/StyleButton.grab_focus();
		updateFocusSprite();
func _on_UndergroundButton_mouse_entered():
	mouseFocus = "StylesMenu/Buttons/UndergroundButton"; button_mouse_entered(); changeFocus();
func _on_UndergroundButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_UnderwaterButton_pressed():
	savedFocus = getFocusNode();
	Global.showMessage("¡Aún estamos trabajando en esto!.", self);
	$AudioBigButton.play();
	if (Global.CurrentInput == "Gamepad"):
		$SectionLeft/StyleButton.grab_focus();
		updateFocusSprite();
func _on_UnderwaterButton_mouse_entered():
	mouseFocus = "StylesMenu/Buttons/UnderwaterButton"; button_mouse_entered(); changeFocus();
func _on_UnderwaterButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_DesertButton_pressed():
	styleChange("Desert");
	$AudioBigButton.play();
	if (Global.CurrentInput == "Gamepad"):
		$SectionLeft/StyleButton.grab_focus();
		updateFocusSprite();
func _on_DesertButton_mouse_entered():
	mouseFocus = "StylesMenu/Buttons/DesertButton"; button_mouse_entered(); changeFocus();
func _on_DesertButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_SnowButton_pressed():
	styleChange("Snow");
	$AudioBigButton.play();
	if (Global.CurrentInput == "Gamepad"):
		$SectionLeft/StyleButton.grab_focus();
		updateFocusSprite();
func _on_SnowButton_mouse_entered():
	mouseFocus = "StylesMenu/Buttons/SnowButton"; button_mouse_entered(); changeFocus();
func _on_SnowButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_SkyButton_pressed():
	styleChange("Sky");
	$AudioBigButton.play();
	if (Global.CurrentInput == "Gamepad"):
		$SectionLeft/StyleButton.grab_focus();
		updateFocusSprite();
func _on_SkyButton_mouse_entered():
	mouseFocus = "StylesMenu/Buttons/SkyButton"; button_mouse_entered(); changeFocus();
func _on_SkyButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_ForestButton_pressed():
	styleChange("Forest");
	$AudioBigButton.play();
	if (Global.CurrentInput == "Gamepad"):
		$SectionLeft/StyleButton.grab_focus();
		updateFocusSprite();
func _on_ForestButton_mouse_entered():
	mouseFocus = "StylesMenu/Buttons/ForestButton"; button_mouse_entered(); changeFocus();
func _on_ForestButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_GhosthouseButton_pressed():
	savedFocus = getFocusNode();
	Global.showMessage("¡Aún estamos trabajando en esto!.", self);
	$AudioBigButton.play();
	if (Global.CurrentInput == "Gamepad"):
		$SectionLeft/StyleButton.grab_focus();
		updateFocusSprite();
func _on_GhosthouseButton_mouse_entered():
	mouseFocus = "StylesMenu/Buttons/GhosthouseButton"; button_mouse_entered(); changeFocus();
func _on_GhosthouseButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();
	
func _on_GhostforestButton_pressed():
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!.", self);
	styleChange("Ghostforest");
	$AudioBigButton.play();
	if (Global.CurrentInput == "Gamepad"):
		$SectionLeft/StyleButton.grab_focus();
		updateFocusSprite();
func _on_GhostforestButton_mouse_entered():
	mouseFocus = "StylesMenu/Buttons/GhostforestButton"; button_mouse_entered(); changeFocus();
func _on_GhostforestButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_AirshipButton_pressed():
	savedFocus = getFocusNode();
	Global.showMessage("¡Aún estamos trabajando en esto!.", self);
	$AudioBigButton.play();
	if (Global.CurrentInput == "Gamepad"):
		$SectionLeft/StyleButton.grab_focus();
		updateFocusSprite();
func _on_AirshipButton_mouse_entered():
	mouseFocus = "StylesMenu/Buttons/AirshipButton"; button_mouse_entered(); changeFocus();
func _on_AirshipButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_CastleButton_pressed():
	savedFocus = getFocusNode();
	Global.showMessage("¡Aún estamos trabajando en esto!.", self);
	$AudioBigButton.play();
	if (Global.CurrentInput == "Gamepad"):
		$SectionLeft/StyleButton.grab_focus();
		updateFocusSprite();
func _on_CastleButton_mouse_entered():
	mouseFocus = "StylesMenu/Buttons/CastleButton"; button_mouse_entered(); changeFocus();
func _on_CastleButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_ResetAnimationPlayer_animation_finished(anim_name):
	if (anim_name == "go"):
		get_parent().reset();
		Global.currentlevel = "";
		$Reset/AnimationPlayer.play("RESET");
		$Reset.hide();

func _on_AppeareancesMenuAnimationPlayer_animation_finished(anim_name):
	if (anim_name == "out"):
		$AppeareancesMenu.hide();
		$AppeareancesMenu/AnimationPlayer.play("RESET");

func _on_StylesMenuAnimationPlayer_animation_finished(anim_name):
	if (anim_name == "out"):
		$StylesMenu.hide();
		$StylesMenu/AnimationPlayer.play("RESET");

func _on_CoursebotMenuAnimationPlayer_animation_finished(anim_name):
	if (anim_name == "out"):
		$CoursebotMenuContainer/CoursebotMenu.hide();
		$CoursebotMenuContainer/CoursebotMenu/AnimationPlayer.play("RESET");

func _on_CameraMenuAnimationPlayer_animation_finished(anim_name):
	if (anim_name == "out"):
		$CameraMenu.hide();
		$CameraMenu/AnimationPlayer.play("RESET");

func _on_TypeMenuAnimationPlayer_animation_finished(anim_name):
	if (anim_name == "out"):
		$TypeMenu.hide();
		$TypeMenu/AnimationPlayer.play("RESET");

func _on_TimeMenuAnimationPlayer_animation_finished(anim_name):
	if (anim_name == "out"):
		$TimeMenu.hide();
		$TimeMenu/AnimationPlayer.play("RESET");

#Coursebot Menu
func enterTextFinished(text, type):
	if (type == "CourseName"):
		Global.currentlevel = Global.get_game_dir()+"/Courses/"+text+".wm";
		Global.currentCourseName = text;
		savedFocus = getFocusNode();
		var inst = Global.enterText("Ingresa la descripción del nivel:", "CourseDescription", self);
	if (type == "CourseDescription"):
		Global.currentCourseDescription = text;
		savedFocus = getFocusNode();
		var inst = Global.enterText("Ingresa tu nickname:", "CourseUser", self);
	if (type == "CourseUser"):
		Global.currentCourseUser = text;
		Global.saveCourseData();
		savedFocus = getFocusNode();
		Global.showMessage("Nivel guardado correctamente.", self);
		editingText = false;

func _on_SaveNewCourse_pressed():
	$AudioCoursebotSelect.play();
	savedFocus = getFocusNode();
	var inst = Global.enterText("Ingresa el nombre del nivel:", "CourseName", self);
	#Global.changeScene("res://scenes/Level.tscn");
func _on_SaveNewCourse_mouse_entered():
	mouseFocus = "CoursebotMenuContainer/CoursebotMenu/SaveNewCourse"; button_mouse_entered(); changeFocus();
func _on_SaveNewCourse_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_SaveChanges_pressed():
	$AudioCoursebotSelect.play();
	if (Global.currentlevel == ""):
		savedFocus = getFocusNode();
		Global.showMessage("No hay ningún nivel cargado.", self);
	else:
		Global.saveCourseData();
		savedFocus = getFocusNode();
		Global.showMessage("Nivel guardado correctamente.", self);
	#Global.changeScene("res://scenes/Level.tscn");
func _on_SaveChanges_mouse_entered():
	mouseFocus = "CoursebotMenuContainer/CoursebotMenu/SaveChanges"; button_mouse_entered(); changeFocus();
func _on_SaveChanges_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Load_pressed():
	$AudioCoursebotSelect.play();
	Global.loadingCourse = true;
	Global.changeScene("res://scenes/ui/coursebot.tscn");
	#Global.changeScene("res://scenes/Level.tscn");
func _on_Load_mouse_entered():
	mouseFocus = "CoursebotMenuContainer/CoursebotMenu/Load"; button_mouse_entered(); changeFocus();
func _on_Load_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

#Camera Speed Menu
func _on_None_pressed():
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!", self);
	Global.CurrentSpeed = "None";
	$AudioBigButton.play();
	closeMenus();
	if (Global.CurrentInput == "Gamepad"):
		$SectionLeft/RecButton.grab_focus();
		updateFocusSprite();
func _on_None_mouse_entered():
	mouseFocus = "CameraMenu/Buttons/None"; button_mouse_entered(); changeFocus();
func _on_None_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Slow_pressed():
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!", self);
	Global.CurrentSpeed = "Slow";
	$AudioBigButton.play();
	closeMenus();
	if (Global.CurrentInput == "Gamepad"):
		$SectionLeft/RecButton.grab_focus();
		updateFocusSprite();
func _on_Slow_mouse_entered():
	mouseFocus = "CameraMenu/Buttons/Slow"; button_mouse_entered(); changeFocus();
func _on_Slow_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Normal_pressed():
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!", self);
	Global.CurrentSpeed = "Normal";
	$AudioBigButton.play();
	closeMenus();
	if (Global.CurrentInput == "Gamepad"):
		$SectionLeft/RecButton.grab_focus();
		updateFocusSprite();
func _on_Normal_mouse_entered():
	mouseFocus = "CameraMenu/Buttons/Normal"; button_mouse_entered(); changeFocus();
func _on_Normal_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Fast_pressed():
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!", self);
	Global.CurrentSpeed = "Fast";
	$AudioBigButton.play();
	closeMenus();
	if (Global.CurrentInput == "Gamepad"):
		$SectionLeft/RecButton.grab_focus();
		updateFocusSprite();
func _on_Fast_mouse_entered():
	mouseFocus = "CameraMenu/Buttons/Fast"; button_mouse_entered(); changeFocus();
func _on_Fast_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_CameraMenuCloseButton_pressed():
	closeMenus();
	$AudioCloseMenu.play();
func _on_CameraMenuCloseButton_mouse_entered():
	mouseFocus = "CameraMenu/CloseButton"; button_mouse_entered(); changeFocus();
func _on_CameraMenuCloseButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

#Type Menu
func resetTypeMenu():
	var children = $TypeMenu/Buttons.get_children();
	for node in children:
		node.queue_free();
		
func addTypeMenuButton():
	var child_count = $TypeMenu/Buttons.get_child_count();
	var inst = load("res://scenes/ui/typebutton.tscn").instance();
	$TypeMenu/Buttons.add_child(inst);
	inst.rect_position.y = 13.5
	inst.rect_position.x = 14+(71*child_count)+(10*child_count);
	adjustTypeMenu();
	return inst;

func adjustTypeMenu():
	var child_count = $TypeMenu/Buttons.get_child_count()-1;
	$TypeMenu.rect_size.x = 100+(71*child_count)+(10*child_count);

#Time Menu
func _on_Up000_pressed():
	if (Global.CurrentTime < 500):
		$AudioOpenMenu.play();
		Global.CurrentTime += 100;
		if (Global.CurrentTime > 500):
			Global.CurrentTime = 500;
func _on_Up000_mouse_entered():
	mouseFocus = "TimeMenu/Buttons/Up000"; button_mouse_entered(); changeFocus();
func _on_Up000_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Up00_pressed():
	if (Global.CurrentTime < 500):
		$AudioOpenMenu.play();
		Global.CurrentTime += 10;
		if (Global.CurrentTime > 500):
			Global.CurrentTime = 500;
func _on_Up00_mouse_entered():
	mouseFocus = "TimeMenu/Buttons/Up00"; button_mouse_entered(); changeFocus();
func _on_Up00_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Up0_pressed():
	if (Global.CurrentTime < 500):
		$AudioOpenMenu.play();
		Global.CurrentTime += 1;
		if (Global.CurrentTime > 500):
			Global.CurrentTime = 500;
func _on_Up0_mouse_entered():
	mouseFocus = "TimeMenu/Buttons/Up0"; button_mouse_entered(); changeFocus();
func _on_Up0_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Down000_pressed():
	if (Global.CurrentTime > 10):
		$AudioOpenMenu.play();
		Global.CurrentTime -= 100;
		if (Global.CurrentTime < 10):
			Global.CurrentTime = 10;
func _on_Down000_mouse_entered():
	mouseFocus = "TimeMenu/Buttons/Down000"; button_mouse_entered(); changeFocus();
func _on_Down000_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Down00_pressed():
	if (Global.CurrentTime > 10):
		$AudioOpenMenu.play();
		Global.CurrentTime -= 10;
		if (Global.CurrentTime < 10):
			Global.CurrentTime = 10;
func _on_Down00_mouse_entered():
	mouseFocus = "TimeMenu/Buttons/Down00"; button_mouse_entered(); changeFocus();
func _on_Down00_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Down0_pressed():
	if (Global.CurrentTime > 10):
		$AudioOpenMenu.play();
		Global.CurrentTime -= 1;
		if (Global.CurrentTime < 10):
			Global.CurrentTime = 10;
func _on_Down0_mouse_entered():
	mouseFocus = "TimeMenu/Buttons/Down0"; button_mouse_entered(); changeFocus();
func _on_Down0_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_TimeMenuCloseButton_pressed():
	closeMenus();
	$AudioCloseMenu.play();
func _on_TimeMenuCloseButton_mouse_entered():
	mouseFocus = "TimeMenu/CloseButton"; button_mouse_entered(); changeFocus();
func _on_TimeMenuCloseButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

#Play/Edit Button
func _on_Play_pressed():
	if (!playing):
		if (Global.CurrentInput == "Gamepad"):
			if (gamepadCursor):
				gamepadCursor = false;
				$GamepadCursor.hide();
				$SectionTop/GamepadCursorGuideQuit.hide();
				$SectionTop/GamepadButtonsQuitGuide.hide();
				$SectionTop/GamepadCursorSprintGuide.hide();
			else:
				$SectionTop/GamepadCursorGuide.hide();
		#Global.renderAll();
		if (eraseMode): toggle_eraseMode();
		closeMenus();
		playing = true;
		get_parent().get_node("TileMap").hide();
		get_parent().get_node("LevelFloor").hide();
		get_parent().get_node("EndFloor").hide();
		$SectionRightContainer/SectionRight/CourseViewerButton.hide();
		$FPS.grab_focus();
		editorMusic(false, false);
		
		get_node("../CharacterEditor").hide();
		
		match Global.CurrentAppeareance:
			Global.APP_SMB:
				get_node("GameplayUI/SMB").visible = true;
				var inst = load("res://scenes/appearances/smb/character_smb.tscn").instance();
				get_parent().add_child(inst);
				inst.position = get_node("../CharacterEditor").position;
			Global.APP_SMB3:
				get_node("GameplayUI/SMB3").visible = true;
				var inst = load("res://scenes/appearances/smb3/character_smb3.tscn").instance();
				get_parent().add_child(inst);
				inst.position = get_node("../CharacterEditor").position;
		
		if (OS.get_name() == "Android" && Global.CurrentInput != "Gamepad"):
			$Controls.show();
		
		Score = 0;
		Coins = 0;
		time = Global.CurrentTime;
		
		if (!get_parent().startmenu && !Global.coursePlaying):
			$AudioMario.play();
			$AnimationPlayer.play("out");
			$Play/AnimationPlayer.play("out");
		
		yield(get_tree(), "idle_frame");
		
		if (!get_parent().startmenu && Global.CurrentMusic == "true"):
			get_parent().gameMusic(true);
		
		yield(get_tree().create_timer(0.5), "timeout");
		
		var nodes = get_tree().get_nodes_in_group("Obj");
		get_parent().freecam = false;
		for node in nodes:
			if (node.position.y <= 840):
				get_parent().freecam = true;
				print("freecam");
				break;
		
		$Edit/AnimationPlayer.play("in");
func _on_Play_mouse_entered():
	mouseFocus = "Play"; button_mouse_entered(); changeFocus();
func _on_Play_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Edit_pressed():
	$Controls.hide();
	match Global.CurrentAppeareance:
		Global.APP_SMB:
			get_node("GameplayUI/SMB").visible = false;
		Global.APP_SMB3:
			get_node("GameplayUI/SMB3").visible = false;
	if (get_parent().startmenu):
		Global.changeScene("res://scenes/ui/MainMenu.tscn");
		Global.toLoad = true;
	if (Global.coursePlaying):
		Global.changeScene("res://scenes/Level.tscn", get_parent());
		Global.toLoad = true;
	if (playing && !get_parent().startmenu && !Global.coursePlaying):
		playing = false;
		changeInput();
		get_parent().get_node("TileMap").show();
		get_parent().get_node("LevelFloor").show();
		get_parent().get_node("EndFloor").show();
		editorMusic(true, false);
		
		$SectionRightContainer/SectionRight/CourseViewerButton.show();
		
		moveCamToChar = true;
		
		var nodes = get_tree().get_nodes_in_group("FlagPole");
		for node in nodes:
			node.get_node("AnimationPlayer").play("RESET");
			node.get_node("SoundGoal").stop();
		
		#Delete Online Death Signals
		nodes = get_tree().get_nodes_in_group("OnlineDeath");
		for node in nodes:
			node.queue_free();
		
		$AnimationPlayer.play("in");
		
		Global.changingToEditMode = true;
		
		get_node("../CharacterEditor").show();
		get_node("../Character").queue_free();
		
		get_parent().gameMusic(false);
		
		$Play/AnimationPlayer.play("in");
		$Edit/AnimationPlayer.play("out");
		
		$AudioBigButton.play();
func _on_Edit_mouse_entered():
	mouseFocus = "Edit"; button_mouse_entered(); changeFocus();
func _on_Edit_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_CloseButtons_pressed():
	if (!playing && get_parent().objSelected != -50 && !get_node("../EndFloor").selected && !get_node("../LevelFloor").selected && !get_node("../CharacterEditor").selected):
		toggle_buttons();

func _on_SeaLevel_button_down():
	changingLevel = true;
	$SeaLevelButton/ArrowUp.show();
	$SeaLevelButton/BodyUp.show();
	$SeaLevelButton/ArrowDown.show();
	$SeaLevelButton/BodyDown.show();

func _on_SeaLevel_button_up():
	changingLevel = false;
	$SeaLevelButton/ArrowUp.hide();
	$SeaLevelButton/BodyUp.hide();
	$SeaLevelButton/ArrowDown.hide();
	$SeaLevelButton/BodyDown.hide();

func _on_SeaTopLevel_button_down():
	changingTopLevel = true;
	$SeaLevelTopButton/ArrowUp.show();
	$SeaLevelTopButton/BodyUp.show();
	$SeaLevelTopButton/ArrowDown.show();
	$SeaLevelTopButton/BodyDown.show();

func _on_SeaTopLevel_button_up():
	changingTopLevel = false;
	$SeaLevelTopButton/ArrowUp.hide();
	$SeaLevelTopButton/BodyUp.hide();
	$SeaLevelTopButton/ArrowDown.hide();
	$SeaLevelTopButton/BodyDown.hide();

func _on_TypeMenuTimer_timeout():
	if (get_parent().grab):
		if (get_parent().grab_node.position == get_parent().calculateGridPosition(Vector2(get_parent().grab_grid))):
			var cont = false;
			currentTypeMenuObject = get_parent().grab_node;
			match (get_parent().grab_id):
				Global.OBJ_FIREFLOWER:
					cont = true;
					if (!get_parent().grab_node.mushroom):
						var button = addTypeMenuButton();
						button.type = "mushroom";
						button.setup();
					else:
						var button = addTypeMenuButton();
						button.type = "quitmushroom";
						button.setup();
				Global.OBJ_PIRANHAPLANT:
					cont = true;
					var button = addTypeMenuButton();
					button.type = "piranhaplantfire";
					button.setup();
				Global.OBJ_PIRANHAPLANT_FIRE:
					cont = true;
					var button = addTypeMenuButton();
					button.type = "piranhaplant";
					button.setup();
				Global.OBJ_GOOMBA:
					cont = true;
					var button = addTypeMenuButton();
					button.type = "goombrat";
					button.setup();
				Global.OBJ_GOOMBRAT:
					cont = true;
					var button = addTypeMenuButton();
					button.type = "goomba";
					button.setup();
				Global.OBJ_SPINY:
					cont = true;
					var button = addTypeMenuButton();
					if (!get_parent().grab_node.alreadydead):
						button.type = "spinydead";
					else:
						button.type = "spinyalive";
					button.setup();
				Global.OBJ_KOOPATROOPA:
					cont = true;
					var button = addTypeMenuButton();
					button.type = "koopatroopared";
					button.setup();
				Global.OBJ_KOOPATROOPA_RED:
					cont = true;
					var button = addTypeMenuButton();
					button.type = "koopatroopa";
					button.setup();
			
			if (!cont): return;
		
			$TypeMenu.show();
			$TypeMenu/AnimationPlayer.play("in");
			if (Global.CurrentInput == "Gamepad" || OS.get_name() == "Android"):
				gamepadReleaseGrab();
				
				gamepadCursor = false;
				$GamepadCursor.hide();
				$SectionTop/GamepadCursorGuide.show();
				$SectionTop/GamepadCursorGuideQuit.hide();
				$SectionTop/GamepadButtonsQuitGuide.hide();
				$SectionTop/GamepadCursorSprintGuide.hide();
			$AudioOpenMenu.play();
			
			var pos = get_parent().grab_node.position-get_node("../Camera2D").position;
			$TypeMenu.rect_position.y = pos.y-26-100-10;
			$TypeMenu.rect_position.x = pos.x-($TypeMenu.rect_size.x/2)

func _on_CharTypeMenuTimer_timeout():
	if (get_node("../CharacterEditor").selected):
		if (get_node("../CharacterEditor").current_grid == get_parent().calculateGrid(get_node("../CharacterEditor").position.x, get_node("../CharacterEditor").position.y)):
			var cont = false;
			var pw = get_node("../CharacterEditor").currentDefaultPowerup;
			var star = get_node("../CharacterEditor").star;
			cont = true;
			
			if (pw == "small"):
				var button = addTypeMenuButton();
				button.type = "charmushroom";
				button.setup();
			elif (pw == "mush"):
				var button = addTypeMenuButton();
				button.type = "charquitmushroom";
				button.setup();
			if (pw != "fireflower"):
				var button = addTypeMenuButton();
				button.type = "charfireflower";
				button.setup();
			elif (pw == "fireflower"):
				var button = addTypeMenuButton();
				button.type = "charquitfireflower";
				button.setup();
			if (!star):
				var button = addTypeMenuButton();
				button.type = "charstar";
				button.setup();
			else:
				var button = addTypeMenuButton();
				button.type = "charquitstar";
				button.setup();
			
			if (!cont): return;
		
			$TypeMenu.show();
			$TypeMenu/AnimationPlayer.play("in");
			if (Global.CurrentInput == "Gamepad" || OS.get_name() == "Android"):
				gamepadReleaseGrab();
				
				gamepadCursor = false;
				$GamepadCursor.hide();
				$SectionTop/GamepadCursorGuide.show();
				$SectionTop/GamepadCursorGuideQuit.hide();
				$SectionTop/GamepadButtonsQuitGuide.hide();
				$SectionTop/GamepadCursorSprintGuide.hide();
			$AudioOpenMenu.play();
			
			var pos = get_node("../CharacterEditor").position-get_node("../Camera2D").position;
			$TypeMenu.rect_position.y = pos.y-26-100-10;
			$TypeMenu.rect_position.x = pos.x-($TypeMenu.rect_size.x/2)

func _exit_tree():
	pass
#	if (!thread.is_alive()):
#		thread.wait_to_finish();
#		print("thread disposed")
