extends Control

export var rotation_velocity : float

var backwards = false;
var exiting = false;
var goingto = "";

var current_page = 1;

var selecting = false;

var savedFocus;
var mouseFocus = "";

var mpos = Vector2(0, 0);

var max_page = {
	"terrain": 2,
	"items": 1,
	"enemies": 1,
	"gizmos": 1
}

var current_category = "terrain";

var category = {
	"terrain": {
		"1": {
			"Up": Global.OBJ_FLOOR,
			"Right": Global.OBJ_SPIKE,
			"Left": Global.OBJ_BLOCK,
			"Down": Global.OBJ_CLOUD,
			"UpLeft": Global.OBJ_BRICK,
			"UpRight": Global.OBJ_SEMISOLID,
			"DownLeft": Global.OBJ_PIPE,
			"DownRight": Global.OBJ_LUCKYBLOCK
		},
		"2": {
			"Up": Global.OBJ_INVISIBLE_LUCKYBLOCK,
			"Right": -1,
			"Left": -1,
			"Down": -1,
			"UpLeft": Global.OBJ_DONUT,
			"UpRight": Global.OBJ_PIPE_CONNECTOR,
			"DownLeft": -1,
			"DownRight": -1
		}
	},
	"items": {
		"1": {
			"Up": Global.OBJ_COIN,
			"Right": Global.OBJ_FIREFLOWER,
			"Left": Global.OBJ_MUSHROOM,
			"Down": -1,
			"UpLeft": Global.OBJ_1UP,
			"UpRight": Global.OBJ_10COIN,
			"DownLeft": Global.OBJ_STAR,
			"DownRight": -1
		}
	},
	"enemies": {
		"1": {
			"Up": Global.OBJ_GOOMBA,
			"Right": Global.OBJ_SPINY,
			"Left": Global.OBJ_TWOMP,
			"Down": -1,
			"UpLeft": Global.OBJ_DRYBONES,
			"UpRight": Global.OBJ_KOOPATROOPA,
			"DownLeft": Global.OBJ_MUNCHER,
			"DownRight": Global.OBJ_PIRANHAPLANT
		}
	},
	"gizmos": {
		"1": {
			"Up": Global.OBJ_P,
			"Right": Global.OBJ_ARROW,
			"Left": Global.OBJ_CHECKPOINT,
			"Down": Global.OBJ_ONOFFSWITCH,
			"UpLeft": Global.OBJ_PBLOCK,
			"UpRight": Global.OBJ_BURNER,
			"DownLeft": Global.OBJ_ONBLOCK,
			"DownRight": Global.OBJ_OFFBLOCK
		}
	}
}

var goingRight: bool = false
var goingDirectly: bool = false

func get_object(object_node: Node):
	var object_pos: String = "";
	if (object_node == null):
		object_pos = "-1";
	else:
		object_pos = object_node.name;
	
	if (object_pos != "-1"):
		var cat: Dictionary = category[current_category];
		var page: Dictionary = cat[str(current_page)];
		var obj: int = page[object_pos];
		return obj;
	else:
		return -1;

func _input(event):
	if (Global.CurrentInput == "Gamepad"):
		updateFocusSprite();
	if (selecting && Global.CurrentInput != "Gamepad"):
		if (event is InputEventScreenTouch && !event.pressed):
			var nearest = get_nearest_object();
			var object = get_object(nearest);
			if (object > -1 && nearest.get_parent().visible):
				get_parent().get_parent().objSelected = object;
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
	#$AudioSelectButton.pitch_scale = randf_range(0.9, 1.1)
	$AudioSelectButton.play()
	get_node(mouseFocus+"/Selection/AnimationPlayer").play("idle")
	changeFocus()
	#Input.set_custom_mouse_cursor(load("res://sprites/ui/cursor.png"))
	get_node(mouseFocus).rect_pivot_offset.x = get_node(mouseFocus).rect_size.x/2
	get_node(mouseFocus).rect_pivot_offset.y = get_node(mouseFocus).rect_size.y/2
	var scale: Vector2 = Vector2(0, 0)
	if (get_node(mouseFocus).editor_description == ""):
		scale = get_node(mouseFocus).rect_scale
	else:
		scale = str2var(get_node(mouseFocus).editor_description)
	get_node(mouseFocus).editor_description = var2str(scale)
	var tween = get_tree().create_tween()
	tween.tween_property(get_node(mouseFocus), "rect_scale", Vector2(scale.x*1.05, scale.y*1.05), 0.0625)

func button_mouse_exited():
	$Bg.grab_focus();
	if (mouseFocus != ""):
		get_node(mouseFocus+"/Selection/AnimationPlayer").play("RESET");
		get_node(mouseFocus).rect_pivot_offset.x = get_node(mouseFocus).rect_size.x/2;
		get_node(mouseFocus).rect_pivot_offset.y = get_node(mouseFocus).rect_size.y/2;
		var tween = get_tree().create_tween();
		var scale: Vector2 = str2var(get_node(mouseFocus).editor_description);
		tween.tween_property(get_node(mouseFocus), "rect_scale", scale, 0.0625);
	changeFocus();
	#Input.set_custom_mouse_cursor(load("res://sprites/ui/cursor_editor.png"));


#Start Menu
func _on_CloseButton_pressed():
	end();
	$AudioPress.play();
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
	hide_objects();
	$TabBar/AnimationPlayer.play(current_category);
	$Select/AnimationPlayer.play("boop");
	$Bg.grab_focus();
	set_color();
	updateSideCategories();

func end():
	$TabBar/AnimationPlayer.play_backwards(current_category);
	backwards = true;
	exiting = true;
	selecting = false;
	get_parent().changeInput();

func hide_objects():
	$Select/Outline/Objects.hide();
	$Select/RightCategory/Objects.hide();
	$Select/LeftCategory/Objects.hide();

func set_color():
	match (current_category):
		"terrain":
			$Select/Outline/Core.self_modulate = $TabBar/Terrain.self_modulate;
			$Select/Outline/OutlineSelect/Sprite2D.modulate = $TabBar/Terrain.self_modulate;
		"items":
			$Select/Outline/Core.self_modulate = $TabBar/Items.self_modulate;
			$Select/Outline/OutlineSelect/Sprite2D.modulate = $TabBar/Items.self_modulate;
		"enemies":
			$Select/Outline/Core.self_modulate = $TabBar/Enemies.self_modulate;
			$Select/Outline/OutlineSelect/Sprite2D.modulate = $TabBar/Enemies.self_modulate;
		"gizmos":
			$Select/Outline/Core.self_modulate = $TabBar/Gizmos.self_modulate;
			$Select/Outline/OutlineSelect/Sprite2D.modulate = $TabBar/Gizmos.self_modulate;

func load_objects_icons():
	for key in category.keys():
		if (key == current_category):
			for page in category[key].keys():
				if (page == str(current_page)):
					for obj in category[key][page].keys():
						var cat = category[key];
						var spage = cat[page];
						var object = int(spage[obj]);
						if (object != -1):
							var icon = Global.object[Global.CurrentAppeareance][object][Global.OP_ICON];
							get_node("Select/Outline/Objects/"+obj).show();
							get_node("Select/Outline/Objects/"+obj+"/icon").texture = icon;
							get_node("Select/Outline/Objects/"+obj+"/HasVariants").visible = Global.hasVariants(object);
						else:
							get_node("Select/Outline/Objects/"+obj).hide();
	#Right Category
	var pg = -1;
	var cate = "";
	if !(current_page == max_page[current_category] && current_category == "gizmos"):
		if (current_page == max_page[current_category]):
			match (current_category):
				"terrain":
					cate = "items";
				"items":
					cate = "enemies";
				"enemies":
					cate = "gizmos";
			pg = 1;
		else:
			cate = current_category;
			pg = current_page+1;
		
		for key in category.keys():
			if (key == cate):
				for page in category[key].keys():
					if (page == str(pg)):
						for obj in category[key][page].keys():
							var cat = category[key];
							var spage = cat[page];
							var object = int(spage[obj]);
							if (object != -1):
								var icon = Global.object[Global.CurrentAppeareance][object][Global.OP_ICON];
								get_node("Select/RightCategory/Objects/"+obj).show();
								get_node("Select/RightCategory/Objects/"+obj+"/icon").texture = icon;
								get_node("Select/RightCategory/Objects/"+obj+"/HasVariants").visible = false;
							else:
								get_node("Select/RightCategory/Objects/"+obj).hide();
	#Left Category
	pg = -1;
	cate = "";
	if !(current_page == 1 && current_category == "terrain"):
		if (current_page == 1):
			match (current_category):
				"items":
					cate = "terrain";
				"enemies":
					cate = "items";
				"gizmos":
					cate = "enemies";
			pg = max_page[cate];
		else:
			cate = current_category;
			pg = current_page-1;
		
		for key in category.keys():
			if (key == cate):
				for page in category[key].keys():
					if (page == str(pg)):
						for obj in category[key][page].keys():
							var cat = category[key];
							var spage = cat[page];
							var object = int(spage[obj]);
							if (object != -1):
								var icon = Global.object[Global.CurrentAppeareance][object][Global.OP_ICON];
								get_node("Select/LeftCategory/Objects/"+obj).show();
								get_node("Select/LeftCategory/Objects/"+obj+"/icon").texture = icon;
								get_node("Select/LeftCategory/Objects/"+obj+"/HasVariants").visible = false;
							else:
								get_node("Select/LeftCategory/Objects/"+obj).hide();
	
	$Select/Outline/Objects.show();
	$Select/RightCategory/Objects.show();
	$Select/LeftCategory/Objects.show();
	#updateSideCategories();

func _on_ShowObjectsTimer_timeout():
	$Select/Outline/Objects.show();
	$Select/RightCategory/Objects.show();
	$Select/LeftCategory/Objects.show();
	
	load_objects_icons();
	updateSideCategories();

func _ready():
	#Fix Selection Corners
	for node in get_tree().get_nodes_in_group("Selection"):
		node.get_node("UpRight").rect_rotation = 90.0
		node.get_node("DownRight").rect_rotation = 180.0
		node.get_node("DownLeft").rect_rotation = 270.0
		
		node.get_node("UpLeft").rect_scale = Vector2(0.5, 0.5)
		node.get_node("UpRight").rect_scale = Vector2(0.5, 0.5)
		node.get_node("DownRight").rect_scale = Vector2(0.5, 0.5)
		node.get_node("DownLeft").rect_scale = Vector2(0.5, 0.5)
		
		node.get_node("UpLeft").stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		node.get_node("UpRight").stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		node.get_node("DownRight").stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		node.get_node("DownLeft").stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		node.get_node("AnimationPlayer").playback_speed = 1.0
	
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
	if (Input.is_action_pressed("up")): mpos = $Select/Outline/Objects/Up.global_position;
	if (Input.is_action_pressed("down")): mpos = $Select/Outline/Objects/Down.global_position;
	if (Input.is_action_pressed("left")): mpos = $Select/Outline/Objects/Left.global_position;
	if (Input.is_action_pressed("right")): mpos = $Select/Outline/Objects/Right.global_position;
	
	if (Input.is_action_pressed("up") && Input.is_action_pressed("right")): mpos = $Select/Outline/Objects/UpRight.global_position;
	if (Input.is_action_pressed("up") && Input.is_action_pressed("left")): mpos = $Select/Outline/Objects/UpLeft.global_position;
	
	if (Input.is_action_pressed("down") && Input.is_action_pressed("right")): mpos = $Select/Outline/Objects/DownRight.global_position;
	if (Input.is_action_pressed("down") && Input.is_action_pressed("left")): mpos = $Select/Outline/Objects/DownLeft.global_position;

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
		var nodepos = node.rect_global_position+Vector2(30, 30);
		var ds = nodepos.distance_to(mps);
		if (ds < dist && visible && node.get_parent().visible && node.name != "Selected"):
			dist = ds;
			nearest = node;
	#var degrees : float = $Select/Outline/OutlineSelect/Sprite2D.rotation_degrees;
	#if (degrees >= -20):
		#return $Select/Outline/Objects/Up;
	#elif (degrees >= 20):
		#return $Select/Outline/Objects/UpRight;
	
	return nearest;

func switch_right():
	$AudioSwitch.play();
	if (current_page < max_page[current_category]):
		current_page += 1;
		hide_objects();
		$Select/Outline/Selected.hide();
		$Select/AnimationPlayer.play("boop");
		_on_ShowObjectsTimer_timeout();
	else:
		match (current_category):
			"terrain": goingto = "items";
			"items": goingto = "enemies";
			"enemies": goingto = "gizmos";
		if (current_category != goingto && goingto != ""):
			$TabBar/AnimationPlayer.play_backwards(current_category);
			backwards = true;
			hide_objects();
			$Select/Outline/Selected.hide();
			$Select/AnimationPlayer.play("boop");
			goingRight = true;

func switch_left():
	$AudioSwitch.play();
	if (current_page > 1):
		current_page -= 1;
		hide_objects();
		$Select/Outline/Selected.hide();
		_on_ShowObjectsTimer_timeout();
		$Select/AnimationPlayer.play("boop");
	else:
		match (current_category):
			"gizmos": goingto = "enemies";
			"enemies": goingto = "items";
			"items": goingto = "terrain";
		if (current_category != goingto && goingto != ""):
			$TabBar/AnimationPlayer.play_backwards(current_category);
			backwards = true;
			hide_objects();
			$Select/Outline/Selected.hide();
			$Select/AnimationPlayer.play("boop");
			goingRight = false;

func updateSideCategories():
	$Select/LeftCategory.visible = !(current_category == "terrain" && current_page == 1);
	$Select/RightCategory.visible = !(current_category == "gizmos" && current_page == max_page["gizmos"]);

func _process(_delta):
	if (visible && goingto == "" && $Select/Outline/ShowObjectsTimer.is_stopped()):
		if (!get_parent().gamepadCursor):
			get_parent().hide_guides();
		
		if (selecting && Global.CurrentInput != "Gamepad"):
			var nearest = get_nearest_object();
			var object = get_object(nearest);
			
			if (object > -1 && nearest.get_parent().visible):
				$Select/Outline/Selected.show();
				$Select/Outline/Selected/icon.texture = Global.object[Global.CurrentAppeareance][object][Global.OP_ICON];
				$Select/Outline/Selected/Label.text = Global.object[Global.CurrentAppeareance][object][Global.OP_NAME];
				if (Input.is_action_just_pressed("leftclick")):
					get_parent().get_parent().objSelected = object;
					get_parent().toggle_gamepadCursor();
					get_parent().selObj();
					end();
					$AudioPress.play();
			else:
				$Select/Outline/Selected.hide();
			var pos = $Select/Outline/OutlineSelect/Sprite2D.global_position;
			var direction = pos.direction_to(get_viewport().get_mouse_position());
			var degrees = get_angle(direction);
			$Select/Outline/OutlineSelect/Sprite2D.rotation = lerp_angle($Select/Outline/OutlineSelect/Sprite2D.rotation, deg2rad(degrees), rotation_velocity);
		elif (Global.CurrentInput == "Gamepad"):
			get_gamepad_direction_position();
			
			var nearest = get_nearest_object();
			var object = get_object(nearest);
			if (object > -1 && nearest.get_parent().visible):
				$Select/Outline/Selected.show();
				$Select/Outline/Selected/icon.texture = Global.object[Global.CurrentAppeareance][object][Global.OP_ICON];
				$Select/Outline/Selected/Label.text = Global.object[Global.CurrentAppeareance][object][Global.OP_NAME];
				if (Input.is_action_just_pressed("a")):
					get_parent().toggle_gamepadCursor();
					get_parent().get_parent().objSelected = object;
					get_parent().selObj();
					end();
					$AudioPress.play();
			else:
				$Select/Outline/Selected.hide();
			$Select/Outline/OutlineSelect.show();
			var pos = $Select/Outline/OutlineSelect/Sprite2D.global_position;
			var direction = pos.direction_to(mpos);
			var degrees = get_angle(direction);
			$Select/Outline/OutlineSelect/Sprite2D.rotation = lerp_angle($Select/Outline/OutlineSelect/Sprite2D.rotation, deg2rad(degrees), rotation_velocity);
		else:
			$Select/Outline/Selected.hide();
		
		if (Input.is_action_just_pressed("back") || Input.is_action_just_pressed("b")):
			end();
		
		if (Input.is_action_just_pressed("dright") || Input.is_action_just_pressed("r")):
			switch_right();
		
		if (Input.is_action_just_pressed("dleft") || Input.is_action_just_pressed("l")):
			switch_left();

func _on_TabsAnimationPlayer_animation_finished(anim_name):
	if (!backwards && goingto == ""):
		get_node("Select/Outline/Objects").show();
	
	if (backwards && exiting):
		exiting = false;
		hide();
		get_parent().CurrentMenu = "Editor";
		if (!get_parent().gamepadCursor):
			get_parent().changeFocus();
		get_parent().get_node("AnimationPlayer").play("in");
		get_parent().get_node("Play").show();
		backwards = false;
	
	if (backwards && goingto != ""):
		$TabBar/AnimationPlayer.play(goingto);
		backwards = false;
	if (!backwards && goingto != ""):
		current_category = goingto;
		if (!goingRight && !goingDirectly):
			current_page = max_page[current_category];
		else:
			current_page = 1;
		goingto = "";
	set_color();
	load_objects_icons();
	updateSideCategories();

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

#Select Animation Player
func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "boop"):
		pass
		#updateSideCategories();

func _on_Terrain_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton || event is InputEventScreenTouch):
		if (event.is_pressed()):
			if (current_category != "terrain"):
				goingto = "terrain";
				if (current_category != goingto && goingto != ""):
					$TabBar/AnimationPlayer.play_backwards(current_category);
					backwards = true;
					hide_objects();
					$Select/Outline/Selected.hide();
					$Select/AnimationPlayer.play("boop");
					goingRight = false
					goingDirectly = true
			$AudioSwitch.play();
			mouseFocus = ""; changeFocus();
func _on_Terrain_mouse_entered() -> void:
	if ($TabBar/AnimationPlayer.current_animation != "terrain" && current_category != "terrain"):
		mouseFocus = "TabBar/Terrain"; button_mouse_entered(); changeFocus();
func _on_Terrain_mouse_exited() -> void:
	if ($TabBar/AnimationPlayer.current_animation != "terrain" && current_category != "terrain"):
		button_mouse_exited(); mouseFocus = ""; changeFocus();
		
func _on_Items_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton || event is InputEventScreenTouch):
		if (event.is_pressed()):
			if (current_category != "items"):
				goingto = "items";
				if (current_category != goingto && goingto != ""):
					$TabBar/AnimationPlayer.play_backwards(current_category);
					backwards = true;
					hide_objects();
					$Select/Outline/Selected.hide();
					$Select/AnimationPlayer.play("boop");
					goingRight = false
					goingDirectly = true
			$AudioSwitch.play();
			mouseFocus = ""; changeFocus();
func _on_Items_mouse_entered() -> void:
	if ($TabBar/AnimationPlayer.current_animation != "items" && current_category != "items"):
		mouseFocus = "TabBar/Items"; button_mouse_entered(); changeFocus();
func _on_Items_mouse_exited() -> void:
	if ($TabBar/AnimationPlayer.current_animation != "items" && current_category != "items"):
		button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Enemies_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton || event is InputEventScreenTouch):
		if (event.is_pressed()):
			if (current_category != "enemies"):
				goingto = "enemies";
				if (current_category != goingto && goingto != ""):
					$TabBar/AnimationPlayer.play_backwards(current_category);
					backwards = true;
					hide_objects();
					$Select/Outline/Selected.hide();
					$Select/AnimationPlayer.play("boop");
					goingRight = false
					goingDirectly = true
			$AudioSwitch.play();
			mouseFocus = ""; changeFocus();
func _on_Enemies_mouse_entered() -> void:
	if ($TabBar/AnimationPlayer.current_animation != "enemies" && current_category != "enemies"):
		mouseFocus = "TabBar/Enemies"; button_mouse_entered(); changeFocus();
func _on_Enemies_mouse_exited() -> void:
	if ($TabBar/AnimationPlayer.current_animation != "enemies" && current_category != "enemies"):
		button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Gizmos_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton || event is InputEventScreenTouch):
		if (event.is_pressed()):
			if (current_category != "gizmos"):
				goingto = "gizmos";
				if (current_category != goingto && goingto != ""):
					$TabBar/AnimationPlayer.play_backwards(current_category);
					backwards = true;
					hide_objects();
					$Select/Outline/Selected.hide();
					$Select/AnimationPlayer.play("boop");
					goingRight = false
					goingDirectly = true
			$AudioSwitch.play();
			mouseFocus = ""; changeFocus();
func _on_Gizmos_mouse_entered() -> void:
	if ($TabBar/AnimationPlayer.current_animation != "gizmos" && current_category != "gizmos"):
		mouseFocus = "TabBar/Gizmos"; button_mouse_entered(); changeFocus();
func _on_Gizmos_mouse_exited() -> void:
	if ($TabBar/AnimationPlayer.current_animation != "gizmos" && current_category != "gizmos"):
		button_mouse_exited(); mouseFocus = ""; changeFocus();

