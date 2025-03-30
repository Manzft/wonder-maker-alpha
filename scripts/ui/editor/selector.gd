extends Control

var current_tab = "";
var backwards = false;
var exiting = false;
var goingto = "";

var current_page = 0;
var max_page = [];

var selecting = false;

var savedFocus;
var mouseFocus = "";

var mpos = Vector2(0, 0);

func _input(event):
	if (Global.CurrentInput == "Gamepad"):
		updateFocusSprite();
	if (selecting && Global.CurrentInput != "Gamepad"):
		if (event is InputEventScreenTouch && !event.pressed):
			var nearest = get_nearest_object();
			if (int(nearest.get_name()) < Global.Objects && nearest.get_parent().visible && nearest.get_parent().get_name() == str(current_page)+current_tab):
				get_parent().get_parent().objSelected = int(nearest.get_name());
				get_parent().toggle_gamepadCursor();
				get_parent().selObj();
				end();
				$AudioPress.play();

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
		mouseFocus = "";
		$FPS.grab_focus();
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	if (Global.CurrentInput == "Gamepad"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);
	if (savedFocus == null):
		changeFocus();

func changeFocus():
	if (Global.CurrentInput == "Gamepad"):
		$SectionRightContainer/SectionRight/StartButton.grab_focus();
		$Bg.grab_focus();
		updateFocusSprite();
	else:
		updateFocusSprite();

func updateFocusSprite():
	var nodes = get_tree().get_nodes_in_group("Button");
	var a;
	if (mouseFocus != ""):
		a = get_node(mouseFocus);
	else:
		a = $Bg;
	for node in nodes:
		if (node.has_focus() || a == node):
			node.get_node("Selection").show();
			node.get_node("Selection/AnimationPlayer").play("idle");
			#node.texture_normal = node.texture_hover;
		else:
			#node.texture_normal = node.texture_disabled;
			node.get_node("Selection").hide();
			node.get_node("Selection/AnimationPlayer").play("RESET");

#General
func button_mouse_entered():
	$AudioSelectButton.play();
	get_node(mouseFocus+"/Selection/AnimationPlayer").play("idle");
	changeFocus();

func button_mouse_exited():
	$Bg.grab_focus();
	get_node(mouseFocus+"/Selection/AnimationPlayer").play("RESET");
	changeFocus();

#Start Menu
func _on_CloseButton_pressed():
	end();
	$AudioButton.play();
	changeFocus();
func _on_CloseButton_mouse_entered():
	mouseFocus = "CloseButton"; button_mouse_entered(); changeFocus();
func _on_CloseButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_SwitchRight_pressed():
	switch_right();
	#$AudioButton.play();
	#changeFocus();
func _on_SwitchRight_mouse_entered():
	mouseFocus = "SwitchRight"; button_mouse_entered(); changeFocus();
func _on_SwitchRight_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_SwitchLeft_pressed():
	switch_left();
	#$AudioButton.play();
	#changeFocus();
func _on_SwitchLeft_mouse_entered():
	mouseFocus = "SwitchLeft"; button_mouse_entered(); changeFocus();
func _on_SwitchLeft_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func start():
	if (current_tab == ""):
		current_tab = "terrain";
		set_max_page();
	hide_objects();
	$Tabs/AnimationPlayer.play(current_tab);
	$Select/AnimationPlayer.play("boop");
	$Bg.grab_focus();
	set_color();
	
func end():
	$Tabs/AnimationPlayer.play_backwards(current_tab);
	backwards = true;
	exiting = true;
	selecting = false;
	get_parent().changeInput();
	
func set_max_page():
	match (current_tab):
		"terrain": max_page = 0;
		"items": max_page = 0;
		"enemies": max_page = 0;
		"gizmos": max_page = 0;
		
func hide_objects():
	var nodes = get_tree().get_nodes_in_group("objects");
	for node in nodes:
		node.hide();
		
func set_color():
	match (current_tab):
		"terrain":
			$Select/Outline/Core.self_modulate = $Tabs/Terrain.self_modulate;
			$Select/Outline/OutlineSelect/Sprite.modulate = $Tabs/Terrain.self_modulate;
		"items":
			$Select/Outline/Core.self_modulate = $Tabs/Items.self_modulate;
			$Select/Outline/OutlineSelect/Sprite.modulate = $Tabs/Items.self_modulate;
		"enemies":
			$Select/Outline/Core.self_modulate = $Tabs/Enemies.self_modulate;
			$Select/Outline/OutlineSelect/Sprite.modulate = $Tabs/Enemies.self_modulate;
		"gizmos":
			$Select/Outline/Core.self_modulate = $Tabs/Gizmos.self_modulate;
			$Select/Outline/OutlineSelect/Sprite.modulate = $Tabs/Gizmos.self_modulate;

func load_objects_icons():
	var nodes = get_tree().get_nodes_in_group("object");
	for node in nodes:
		if (int(node.get_name()) < Global.Objects):
			node.get_node("icon").texture = Global.object[Global.CurrentAppeareance][int(node.get_name())][Global.OP_ICON];
			node.get_node("HasVariants").visible = Global.hasVariants(int(node.get_name()))
			node.get_node("HasVariants").scale = Vector2(1.443, 1.443);
			node.get_node("HasVariants").position = Vector2(75, 75);
		else:
			node.hide();

func _on_ShowObjectsTimer_timeout():
	get_node("Select/Outline/"+str(current_page)+current_tab).show();

func _ready():
	setupArray(max_page, 4, false);
	
	max_page[0] = 1; #Terrain
	max_page[1] = 0; #Items
	max_page[2] = 0; #Enemies
	max_page[3] = 1; #Gizmos
	
	load_objects_icons();

func get_angle(vec2: Vector2):
	var degrees = 0;
	vec2.x = round(vec2.x);
	vec2.y = round(vec2.y);
	
	match vec2:
		Vector2(0, -1): degrees = 0; #Up
		Vector2(1, -1): degrees = 45; #Up Right
		Vector2(-1, -1): degrees = -45; #Up Left
		Vector2(1, 0): degrees = 90; #Right
		Vector2(-1, 0): degrees = -90; #Left
		Vector2(0, 1): degrees = 180; #Down
		Vector2(1, 1): degrees = 135; #Down Right
		Vector2(-1, 1): degrees = -135; #Down Left
	
	return degrees;

func get_gamepad_direction_position():
	if (Input.is_action_pressed("up")): mpos = $PositionUp.global_position;
	if (Input.is_action_pressed("down")): mpos = $PositionDown.global_position;
	if (Input.is_action_pressed("left")): mpos = $PositionLeft.global_position;
	if (Input.is_action_pressed("right")): mpos = $PositionRight.global_position;
	
	if (Input.is_action_pressed("up") && Input.is_action_pressed("right")): mpos = $PositionUpRight.global_position;
	if (Input.is_action_pressed("up") && Input.is_action_pressed("left")): mpos = $PositionUpLeft.global_position;
	
	if (Input.is_action_pressed("down") && Input.is_action_pressed("right")): mpos = $PositionDownRight.global_position;
	if (Input.is_action_pressed("down") && Input.is_action_pressed("left")): mpos = $PositionDownLeft.global_position;

func get_nearest_object():
	var mps;
	if (Global.CurrentInput != "Gamepad"):
		mps = get_viewport().get_mouse_position();
	else:
		mps = mpos;
		
	#print(mps)
		
	var nodes = get_tree().get_nodes_in_group("object");
	var dist = 9999999;
	var nearest = null;
	for node in nodes:
		var ds = node.rect_global_position.distance_to(mps);
		if (ds < dist && visible && node.get_parent().visible):
			dist = ds;
			nearest = node;
			
	
	return nearest;
		
func switch_right():
	$AudioSwitch.play();
	var maxpage = 0;
	match (current_tab):
		"terrain":
			maxpage = 1;
		"items":
			maxpage = 0;
		"enemies":
			maxpage = 0;
		"gizmos":
			maxpage = 0;
	if (current_page < maxpage):
		current_page += 1;
		hide_objects();
		$Select/Outline/Selected.hide();
		_on_ShowObjectsTimer_timeout();
	else:
		match (current_tab):
			"terrain": goingto = "items";
			"items": goingto = "enemies";
			"enemies": goingto = "gizmos";
		if (current_tab != goingto && goingto != ""):
			$Tabs/AnimationPlayer.play_backwards(current_tab);
			backwards = true;
			hide_objects();
			$Select/Outline/Selected.hide();
			$Select/AnimationPlayer.play("boop");

func switch_left():
	$AudioSwitch.play();
	if (current_page > 0):
		current_page -= 1;
		hide_objects();
		$Select/Outline/Selected.hide();
		_on_ShowObjectsTimer_timeout();
	else:
		match (current_tab):
			"gizmos": goingto = "enemies";
			"enemies": goingto = "items";
			"items": goingto = "terrain";
		if (current_tab != goingto && goingto != ""):
			$Tabs/AnimationPlayer.play_backwards(current_tab);
			backwards = true;
			hide_objects();
			$Select/Outline/Selected.hide();
			$Select/AnimationPlayer.play("boop");

func _process(_delta):
	if (visible && goingto == ""):
		if (!get_parent().gamepadCursor):
			get_parent().hide_guides();
		
		if (selecting && Global.CurrentInput != "Gamepad"):
			var nearest = get_nearest_object();
			
			if (int(nearest.get_name()) < Global.Objects && nearest.get_parent().visible && nearest.get_parent().get_name() == str(current_page)+current_tab):
				$Select/Outline/Selected.show();
				$Select/Outline/Selected/icon.texture = Global.object[Global.CurrentAppeareance][int(nearest.get_name())][Global.OP_ICON];
				$Select/Outline/Selected/Label.text = Global.object[Global.CurrentAppeareance][int(nearest.get_name())][Global.OP_NAME];
				if (Input.is_action_just_pressed("leftclick")):
					get_parent().get_parent().objSelected = int(nearest.get_name());
					get_parent().toggle_gamepadCursor();
					get_parent().selObj();
					end();
					$AudioPress.play();
			var pos = $Select/Outline/OutlineSelect/Sprite.global_position;
			var direction = pos.direction_to(get_viewport().get_mouse_position());
			var degrees = get_angle(direction);
			$Select/Outline/OutlineSelect/Sprite.rotation_degrees = degrees;
		elif (Global.CurrentInput == "Gamepad"):
			get_gamepad_direction_position();
			
			var nearest = get_nearest_object();
			if (int(nearest.get_name()) < Global.Objects && nearest.get_parent().visible && nearest.get_parent().get_name() == str(current_page)+current_tab):
				$Select/Outline/Selected.show();
				$Select/Outline/Selected/icon.texture = Global.object[Global.CurrentAppeareance][int(nearest.get_name())][Global.OP_ICON];
				$Select/Outline/Selected/Label.text = Global.object[Global.CurrentAppeareance][int(nearest.get_name())][Global.OP_NAME];
				if (Input.is_action_just_pressed("a")):
					get_parent().toggle_gamepadCursor();
					get_parent().get_parent().objSelected = int(nearest.get_name());
					get_parent().selObj();
					end();
					$AudioPress.play();
			$Select/Outline/OutlineSelect.show();
			var pos = $Select/Outline/OutlineSelect/Sprite.global_position;
			var direction = pos.direction_to(mpos);
			var degrees = get_angle(direction);
			$Select/Outline/OutlineSelect/Sprite.rotation_degrees = degrees;
		
		if (Input.is_action_just_pressed("back") || Input.is_action_just_pressed("b")):
			end();
		
		if (Input.is_action_just_pressed("dright") || Input.is_action_just_pressed("r")):
			switch_right();
		
		if (Input.is_action_just_pressed("dleft") || Input.is_action_just_pressed("l")):
			switch_left();

func _on_TabsAnimationPlayer_animation_finished(anim_name):
	load_objects_icons();
	if (!backwards && goingto == ""):
		get_node("Select/Outline/"+str(current_page)+current_tab).show();
	
	if (backwards && exiting):
		#current_tab = "";
		#goingto = "";
		exiting = false;
		hide();
		get_parent().CurrentMenu = "Editor";
		if (!get_parent().gamepadCursor):
			get_parent().changeFocus();
		get_parent().get_node("AnimationPlayer").play("in");
		get_parent().get_node("Play").show();
		backwards = false;
	
	if (backwards && goingto != ""):
		$Tabs/AnimationPlayer.play(goingto);
		backwards = false;
	if (!backwards && goingto != ""):
		current_tab = goingto;
		match (current_tab):
			"gizmos": current_page = 0
			"enemies": current_page = 0
			"items": current_page = 0
			"terrain": current_page = 1
		goingto = "";
		set_max_page();
		get_node("Select/Outline/"+str(current_page)+current_tab).show();
	set_color();

func _on_Outline_mouse_entered():
	selecting = true;
	$Select/Outline/OutlineSelect.show();
	#print("In");

func _on_Outline_mouse_exited():
	selecting = false;
	$Select/Outline/OutlineSelect.hide();
	#print("Out")

func setupArray(array, x, INT = false):
	for i in range(x): 
		array.append([]);
		if (INT):
			array[i] = 0;
