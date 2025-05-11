extends CanvasLayer

var mouseFocus = "";
var savedFocus;

var branchmenu = false;

var editingText = false;

var currentLevelType = "mine";

var canHandleInput = false;

var button_pressed = {}
var mouse_entered = {}

var CurrentMenu = "Coursebot";

func _input(event):
	if (Global.CurrentInput == "Gamepad"):
		updateFocusSprite();
	
	if (canHandleInput):
		if (event is InputEventMouse || event is InputEventScreenDrag || event is InputEventScreenTouch):
			var new = false;
			var nodes = get_tree().get_nodes_in_group("CourseButton");
			for node in nodes:
				var size = node.rect_size;
				var pos = node.rect_global_position;
				var evpos = event.position;
				if (evpos.x >= pos.x && evpos.x <= pos.x+size.x
				&& evpos.y >= pos.y && evpos.y <= pos.y+size.y):
					if (!mouse_entered[node.name]):
						mouse_entered[node.name] = true;
						mouseFocus = str("Base/ScrollContainer/MarginContainer/GridContainer/"+node.name); button_mouse_entered(); changeFocus();
						new = true;
					if (node.pressed):
						if (!button_pressed[node.name]):
							button_pressed[node.name] = true;
							course(node);
							$AudioButton.play();
					else:
						button_pressed[node.name] = false;
				else:
					if (mouse_entered[node.name]):
						mouse_entered[node.name] = false;
						if (!new):
							button_mouse_exited(); mouseFocus = ""; changeFocus();
#					else:
#						node.get_node("Selection").hide();

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
		$Base.grab_focus();
		changeFocus();
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	if (Global.CurrentInput == "Gamepad"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);
	changeFocus();

func changeFocus():
	if (Global.CurrentInput == "Gamepad"):
		if (!$LevelInfoContainer/LevelInfo.visible):
			$YourLevels.grab_focus();
		else:
			$LevelInfoContainer/LevelInfo/EditButton.grab_focus();
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
	
	Global.toLoad = false;
	if (Global.DISCORD_PRESENCE):
		Global.setDiscordState("coursebot")
	
	#Restart Checkpoint
	Global.CheckpointGrid = Vector2(0, 0);

	changeInput();
	
	#Connect button focus signals
	var nodes = get_tree().get_nodes_in_group("Button");
	for node in nodes:
		node.connect("focus_entered", self, "focus_change");
	
	Global.transition();
	
	if (Global.loadingCourse):
		setText("Elige un nivel");
		$BackButton.hide();
		
	yield(get_tree().create_timer(0.125), "timeout");
	setCourseName();
	
	if (Global.toPublish):
		Global.toPublish = false
		var result = yield(Online.publish_level(Global.currentlevel), "completed")
		if (result == "success"):
			savedFocus = mouseFocus
			Global.showMessage("Se ha publicado tu nivel en el Online de Wonder Maker.", self)
		else:
			savedFocus = mouseFocus
			Global.showMessage("No se ha podido publicar tu nivel.", self)

func updateCurrentLevelSprite():
	if (currentLevelType == "mine"):
		$YourLevels.texture_normal = load("res://sprites/ui/coursebot/main_button_selected.png");
		$YourLevels/Label.modulate = Color("#ffffff");
		
		$DownloadedLevels.texture_normal = load("res://sprites/ui/coursebot/main_button.png");
		$DownloadedLevels/Label.modulate = Color("#3a3a3a");
		
	elif (currentLevelType == "downloaded"):
		$YourLevels.texture_normal = load("res://sprites/ui/coursebot/main_button.png");
		$YourLevels/Label.modulate = Color("#3a3a3a");
		
		$DownloadedLevels.texture_normal = load("res://sprites/ui/coursebot/main_button_selected.png");
		$DownloadedLevels/Label.modulate = Color("#ffffff");
	
	setCourseName();

func _process(delta):
	pass

func setCourseName():
	#Global.thread = Thread.new();
	#Global.thread.start(self, "courseName");
	courseName()
#	$AppeareanceChangeIcon/AnimationPlayer.play("in");
#	$Base/ScrollContainer.hide();
#	$UIBlocker.show();

func courseName():
	canHandleInput = false;
	
	for node in $Base/ScrollContainer/MarginContainer/GridContainer.get_children():
		node.queue_free();
	
	var dir = Directory.new()
	var filecount = 0;

	var todir = Global.get_game_dir()+"/Courses";

	if dir.open(todir) == OK:
		savedFocus = getFocusNode();
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
				#print("Found directory: " + file_name)
			else:
				#print("Found file: " + file_name)
				if (file_name.get_extension() == "wom"):
					var check = false;
					if (currentLevelType == "mine"):
						if (Global.courseGetUser(Global.get_game_dir()+"/Courses/"+file_name) == Global.USER_NAME):
							check = true;
					elif (currentLevelType == "downloaded"):
						if (Global.courseGetUser(Global.get_game_dir()+"/Courses/"+file_name) != Global.USER_NAME):
							check = true;
					if (check):
						var node = load("res://scenes/ui/course_button.tscn").instance();
						node.get_node("Label").text = file_name.trim_suffix(".wom");
						var texture = Global.courseGetThumbnail(Global.get_game_dir()+"/Courses/"+file_name);
						if (texture != null):
							node.get_node("Thumbnail").texture = texture;
						node.name = "CourseButton"+str(filecount);
						$Base/ScrollContainer/MarginContainer/GridContainer.add_child(node);
						
						mouse_entered[node.name] = false;
						
#						var inst = load("res://scenes/ui/course_content.tscn").instance();
#						node.add_child(inst);
#						inst.rect_position = Vector2(9, 8);
#						var style = Global.courseGetStyle(Global.get_game_dir()+"/Courses/"+file_name);
#						var appearance = Global.courseGetAppeareance(Global.get_game_dir()+"/Courses/"+file_name);
#						inst.setAppearance(appearance);
#						inst.setStyle(style);
						filecount += 1;
			file_name = dir.get_next()
	else:
		savedFocus = getFocusNode();
		Global.showMessage("No se pudo acceder al directorio.", self);
	
		#node.hide();
	
#	$AppeareanceChangeIcon/AnimationPlayer.play("out");
#	yield(get_tree().create_timer(0.5), "timeout");
#	$Base/ScrollContainer.show();
#	$UIBlocker.hide();
	
	canHandleInput = true;

func setText(text):
	$TopContainer/Top/Label.text = text;

#General
func button_mouse_entered():
	#$AudioSelectButton.pitch_scale = randf_range(0.9, 1.1)
	$AudioSelectButton.play()
	get_node(mouseFocus+"/Selection/AnimationPlayer").play("idle")
	changeFocus()
	if (get_node(mouseFocus).is_in_group("LevelButton") ||
	get_node(mouseFocus).is_in_group("IgnoreSelection")):
		return
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
	tween.tween_property(get_node(mouseFocus), "rect_scale", Vector2(scale.x*1.1, scale.y*1.1), 0.0625)

func button_mouse_exited():
	$Base.grab_focus();
	if (mouseFocus != ""):
		if (!get_node(mouseFocus).is_in_group("LevelButton") && !get_node(mouseFocus).is_in_group("IgnoreSelection")):
			get_node(mouseFocus+"/Selection/AnimationPlayer").play("RESET");
			get_node(mouseFocus).rect_pivot_offset.x = get_node(mouseFocus).rect_size.x/2;
			get_node(mouseFocus).rect_pivot_offset.y = get_node(mouseFocus).rect_size.y/2;
			var tween = get_tree().create_tween();
			var scale: Vector2 = str2var(get_node(mouseFocus).editor_description);
			tween.tween_property(get_node(mouseFocus), "rect_scale", scale, 0.0625);
	changeFocus();
	#Input.set_custom_mouse_cursor(load("res://sprites/ui/cursor_editor.png"));

func course(node : Node):
	if (!Global.loadingCourse):
		Global.currentlevel = Global.get_game_dir()+"/Courses/"+node.get_node("Label").text+".wom";
		
		$LevelInfoContainer/AnimationPlayer.play("in");
		var texture = Global.courseGetThumbnail(Global.get_game_dir()+"/Courses/"+node.get_node("Label").text+".wom");
		if (texture != null):
			$LevelInfoContainer/LevelInfo.get_node("Thumbnail").texture = texture;
			$LevelInfoContainer/LevelInfo/Thumbnail.show();
		else:
			$LevelInfoContainer/LevelInfo/Thumbnail.hide();
		
#			var inst = load("res://scenes/ui/course_content.tscn").instance();
#			$LevelInfoContainer/LevelInfo.add_child(inst);
#			inst.rect_position = Vector2(35.5, 81);
#			inst.rect_scale = Vector2(2.55, 2.55);
#			var style = Global.courseGetStyle(Global.get_game_dir()+"/Courses/"+node.get_node("Label").text+".wom");
#			var appearance = Global.courseGetAppeareance(Global.get_game_dir()+"/Courses/"+node.get_node("Label").text+".wom");
#
#			inst.setAppearance(appearance);
#			inst.setStyle(style);
		
		$LevelInfoContainer/LevelInfo/CourseName.text = node.get_node("Label").text;
		var description = Global.courseGetDescription(Global.get_game_dir()+"/Courses/"+node.get_node("Label").text+".wom");
		$LevelInfoContainer/LevelInfo/CourseDescription.text = description;
		var user = Global.courseGetUser(Global.get_game_dir()+"/Courses/"+node.get_node("Label").text+".wom");
		$LevelInfoContainer/LevelInfo/CourseUser.text = user;
		
		if (Global.courseGetUser(Global.get_game_dir()+"/Courses/"+node.get_node("Label").text+".wom") != Global.USER_NAME):
			$LevelInfoContainer/LevelInfo/EditButton.hide();
			$LevelInfoContainer/LevelInfo/EditCourseName.hide();
			$LevelInfoContainer/LevelInfo/EditCourseDescription.hide();
			$LevelInfoContainer/LevelInfo/PublishButton.hide()
			$LevelInfoContainer/LevelInfo/EraseCourse.rect_position = Vector2(476.5, 81);
		else:
			$LevelInfoContainer/LevelInfo/EditButton.show();
			$LevelInfoContainer/LevelInfo/EditCourseName.show();
			$LevelInfoContainer/LevelInfo/EditCourseDescription.show();
			$LevelInfoContainer/LevelInfo/PublishButton.show()
			$LevelInfoContainer/LevelInfo/EraseCourse.rect_position = Vector2(844, 237);
		
		if (Global.CurrentInput == "Gamepad"):
			$LevelInfoContainer/LevelInfo/EditButton.grab_focus();
			
		Global.currentCourseName = node.get_node("Label").text;
	else:
		Global.currentlevel = Global.get_game_dir()+"/Courses/"+node.get_node("Label").text+".wom";
		Global.currentCourseName = node.get_node("Label").text;
		Global.changeScene("res://scenes/Level.tscn");
		Global.toLoad = true;
		Global.loadingCourse = false;

func _on_BackButton_pressed():
	$AudioButton.play();
	Global.changeScene("res://scenes/ui/MainMenu.tscn");
func _on_BackButton_mouse_entered():
	mouseFocus = "BackButton"; button_mouse_entered(); changeFocus();
func _on_BackButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_YourLevels_pressed():
	currentLevelType = "mine";
	updateCurrentLevelSprite();
	$AudioButton.play();
	if ($LevelInfoContainer/LevelInfo.visible):
		$LevelInfoContainer/AnimationPlayer.play("out");
func _on_YourLevels_mouse_entered():
	mouseFocus = "YourLevels"; button_mouse_entered(); changeFocus();
func _on_YourLevels_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_DownloadedLevels_pressed():
	currentLevelType = "downloaded";
	updateCurrentLevelSprite();
	$AudioButton.play();
	if ($LevelInfoContainer/LevelInfo.visible):
		$LevelInfoContainer/AnimationPlayer.play("out");
func _on_DownloadedLevels_mouse_entered():
	mouseFocus = "DownloadedLevels"; button_mouse_entered(); changeFocus();
func _on_DownloadedLevels_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

#Level Info
func enterTextFinished(text, type):
	if (type == "CourseName"):
		var f = File.new();
		
		f.open_encrypted_with_pass(Global.currentlevel, File.READ, Global.SECURITY_KEY);
		var content = f.get_as_text();
		f.close();
		
		var newpath = Global.get_game_dir()+"/Courses/"+text+".wom";
		
		f.open_encrypted_with_pass(newpath, File.WRITE, Global.SECURITY_KEY);
		f.store_string(content);
		f.close();
		
		var dir = Directory.new()
		dir.remove(Global.currentlevel);
		
		Global.currentlevel = newpath;
		
		setCourseName();
		$LevelInfoContainer/AnimationPlayer.play("out");
		
		savedFocus = getFocusNode();
		Global.showMessage("Nombre cambiado correctamente.", self);
	if (type == "CourseDescription"):
		Global.loadCourseData(false);
		
		Global.currentCourseDescription = text;
		
		Global.saveCourseData(false);
		
		setCourseName();
		$LevelInfoContainer/AnimationPlayer.play("out");
		
		savedFocus = getFocusNode();
		Global.showMessage("Descripción cambiada correctamente.", self);
	editingText = false;

func _on_CloseButton_pressed():
	$AudioCoursebotClose.play();
	$LevelInfoContainer/AnimationPlayer.play("out");
	if (Global.CurrentInput == "Gamepad"):
		$Base/Course0.grab_focus();
func _on_CloseButton_mouse_entered():
	mouseFocus = "LevelInfoContainer/LevelInfo/CloseButton"; button_mouse_entered(); changeFocus();
func _on_CloseButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_EditButton_pressed():
	$AudioButton.play();
	Global.changeScene("res://scenes/Level.tscn");
	Global.toLoad = true;
func _on_EditButton_mouse_entered():
	mouseFocus = "LevelInfoContainer/LevelInfo/EditButton"; button_mouse_entered(); changeFocus();
func _on_EditButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_PublishButton_pressed():
	$AudioButton.play();
	if (Online.logged):
		savedFocus = mouseFocus
		Global.showMessage("Para publicar un nivel debes demostrar que puedes superarlo.", self, null, "publish")
	else:
		Global.auth_interface(self, true)
	Global.toLoad = true;
func _on_PublishButton_mouse_entered():
	mouseFocus = "LevelInfoContainer/LevelInfo/PublishButton"; button_mouse_entered(); changeFocus();
func _on_PublishButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_EditCourseName_pressed():
	$AudioButton.play();
	savedFocus = getFocusNode();
	Global.enterText("Escribe el nuevo nombre del nivel:", "CourseName", self);
func _on_EditCourseName_mouse_entered():
	mouseFocus = "LevelInfoContainer/LevelInfo/EditCourseName"; button_mouse_entered(); changeFocus();
func _on_EditCourseName_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_EditCourseDescription_pressed():
	$AudioButton.play();
	savedFocus = getFocusNode();
	Global.enterText("Escribe la nueva descripción del nivel:", "CourseDescription", self);
func _on_EditCourseDescription_mouse_entered():
	mouseFocus = "LevelInfoContainer/LevelInfo/EditCourseDescription"; button_mouse_entered(); changeFocus();
func _on_EditCourseDescription_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_EraseCourse_pressed():
	_on_CloseButton_pressed();
	
	var dir = Directory.new()
	dir.remove(Global.currentlevel);
	Global.currentlevel = "";
	yield(get_tree(), "idle_frame");
	setCourseName();
	
	savedFocus = getFocusNode();
	Global.showMessage("Nivel borrado correctamente.", self);
func _on_EraseCourse_mouse_entered():
	mouseFocus = "LevelInfoContainer/LevelInfo/EraseCourse"; button_mouse_entered(); changeFocus();
func _on_EraseCourse_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_PlayButton_pressed():
	$AudioButton.play();
	Global.coursePlaying = true;
	Global.changeScene("res://scenes/ui/playintro.tscn");
	Global.toLoad = true;
func _on_PlayButton_mouse_entered():
	mouseFocus = "LevelInfoContainer/LevelInfo/PlayButton"; button_mouse_entered(); changeFocus();
func _on_PlayButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_StartButton_pressed():
	#savedFocus = getFocusNode();
	#Global.showMessage("¡Aún estamos trabajando en esto!.", self);
	sidemenu();
	$AudioStart.play();
func _on_StartButton_mouse_entered():
	mouseFocus = "StartButton"; button_mouse_entered(); changeFocus();
func _on_StartButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func sidemenu():
	if (CurrentMenu == "Coursebot"):
		$AnimationPlayer.play("sidemenu");
		CurrentMenu = "SideMenu";
		changeFocus();
		$SideMenu.changeFocus();
		$MusicCoursebot.stream_paused = true;
	elif (CurrentMenu == "SideMenu"):
		CurrentMenu = "Coursebot";
		$AnimationPlayer.play_backwards("sidemenu");
		$SideMenu.changeFocus();
		changeFocus();
		$MusicCoursebot.stream_paused = false;

func messageBoxFinished(type: String):
	if (type == "publish"):
		Global.toPublish = true;
		Global.coursePlaying = true
		Global.changeScene("res://scenes/ui/playintro.tscn");
		Global.toLoad = true;
