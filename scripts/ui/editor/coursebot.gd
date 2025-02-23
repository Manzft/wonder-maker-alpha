extends CanvasLayer

var mouseFocus = "";
var savedFocus;

var branchmenu = false;

var editingText = false;

func _input(event):
	if (Global.CurrentInput == "Gamepad"):
		updateFocusSprite();

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
		if (!$LevelInfo.visible):
			$Base/Course0.grab_focus();
		else:
			$LevelInfo/EditButton.grab_focus();
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
	RichPresence.update_activity("Coursebot");
	
	#Restart Checkpoint
	Global.CheckpointGrid = Vector2(0, 0);
	
	$LevelInfo.hide();
	changeInput();
	
	#Connect button focus signals
	var nodes = get_tree().get_nodes_in_group("Button");
	for node in nodes:
		node.connect("focus_entered", self, "focus_change");
	
	Global.transition();
	
	setCourseName();
	if (Global.loadingCourse):
		setText("Elige un nivel");
		$BackButton.hide();

func _process(delta):
	pass

func setCourseName():
	for i in range(15):
		var node = get_node("Base/Course"+str(i));
		node.get_node("Label").text = "";
		if (node.get_node("Background") != null):
			node.get_node("Background").queue_free();
		#node.hide();
	
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
				if (filecount <= 14):
					if (file_name.get_extension() == "wm"):
						var ver = Global.courseGetVersion(todir+"/"+file_name);
						if (ver == Global.GAME_VERSION || ver == "1.1"):
							get_node("Base/Course"+str(filecount)+"/Label").text = file_name.trim_suffix(".wm");
							var node = get_node("Base/Course"+str(filecount));
							
							var inst = load("res://scenes/ui/course_content.tscn").instance();
							node.add_child(inst);
							inst.rect_position = Vector2(9, 8);
							var style = Global.courseGetStyle(Global.get_game_dir()+"/Courses/"+file_name);
							var appearance = Global.courseGetAppearance(Global.get_game_dir()+"/Courses/"+file_name);
							inst.setAppearance(appearance);
							inst.setStyle(style);
							#node.show();
							filecount += 1;
			file_name = dir.get_next()
	else:
		savedFocus = getFocusNode();
		Global.showMessage("No se pudo acceder al directorio.", self);
	
		#node.hide();

func setText(text):
	$Top/Label.text = text;

#General
func button_mouse_entered():
	$AudioSelectButton.play();
	get_node(mouseFocus+"/Selection/AnimationPlayer").play("idle");
	changeFocus();

func button_mouse_exited():
	$Base.grab_focus();
	if (mouseFocus != ""):
		get_node(mouseFocus+"/Selection/AnimationPlayer").play("RESET");
	changeFocus();

func course(id):
	if (!Global.loadingCourse):
		var node = get_node("Base/Course"+str(id));
		if (node.get_node("Label").text != ""):
			Global.currentlevel = Global.get_game_dir()+"/Courses/"+node.get_node("Label").text+".wm";
			
			$LevelInfo.show();
			var inst = load("res://scenes/ui/course_content.tscn").instance();
			$LevelInfo.add_child(inst);
			inst.rect_position = Vector2(35.5, 81);
			inst.rect_scale = Vector2(2.55, 2.55);
			var style = Global.courseGetStyle(Global.get_game_dir()+"/Courses/"+node.get_node("Label").text+".wm");
			var appearance = Global.courseGetAppearance(Global.get_game_dir()+"/Courses/"+node.get_node("Label").text+".wm");
			inst.setAppearance(appearance);
			inst.setStyle(style);
			
			$LevelInfo/CourseName.text = node.get_node("Label").text;
			var description = Global.courseGetDescription(Global.get_game_dir()+"/Courses/"+node.get_node("Label").text+".wm");
			$LevelInfo/CourseDescription.text = description;
			var user = Global.courseGetUser(Global.get_game_dir()+"/Courses/"+node.get_node("Label").text+".wm");
			$LevelInfo/CourseUser.text = user;
			
			if (Global.CurrentInput == "Gamepad"):
				$LevelInfo/EditButton.grab_focus();
				
			Global.currentCourseName = node.get_node("Label").text;
	else:
		var node = get_node("Base/Course"+str(id));
		if (node.get_node("Label").text != ""):
			Global.currentlevel = Global.get_game_dir()+"/Courses/"+node.get_node("Label").text+".wm";
			Global.currentCourseName = node.get_node("Label").text;
			Global.changeScene("res://scenes/Level.tscn");
			Global.toLoad = true;
			Global.loadingCourse = false;

func _on_Course0_pressed():
	$AudioButton.play();
	course(0);
func _on_Course0_mouse_entered():
	mouseFocus = "Base/Course0"; button_mouse_entered(); changeFocus();
func _on_Course0_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Course1_pressed():
	$AudioButton.play();
	course(1);
func _on_Course1_mouse_entered():
	mouseFocus = "Base/Course1"; button_mouse_entered(); changeFocus();
func _on_Course1_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Course2_pressed():
	$AudioButton.play();
	course(2);
func _on_Course2_mouse_entered():
	mouseFocus = "Base/Course2"; button_mouse_entered(); changeFocus();
func _on_Course2_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Course3_pressed():
	$AudioButton.play();
	course(3);
func _on_Course3_mouse_entered():
	mouseFocus = "Base/Course3"; button_mouse_entered(); changeFocus();
func _on_Course3_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Course4_pressed():
	course(4);
	$AudioButton.play();
func _on_Course4_mouse_entered():
	mouseFocus = "Base/Course4"; button_mouse_entered(); changeFocus();
func _on_Course4_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Course5_pressed():
	$AudioButton.play();
	course(5);
func _on_Course5_mouse_entered():
	mouseFocus = "Base/Course5"; button_mouse_entered(); changeFocus();
func _on_Course5_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Course6_pressed():
	$AudioButton.play();
	course(6);
func _on_Course6_mouse_entered():
	mouseFocus = "Base/Course6"; button_mouse_entered(); changeFocus();
func _on_Course6_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Course7_pressed():
	$AudioButton.play();
	course(7);
func _on_Course7_mouse_entered():
	mouseFocus = "Base/Course7"; button_mouse_entered(); changeFocus();
func _on_Course7_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Course8_pressed():
	$AudioButton.play();
	course(8);
func _on_Course8_mouse_entered():
	mouseFocus = "Base/Course8"; button_mouse_entered(); changeFocus();
func _on_Course8_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Course9_pressed():
	$AudioButton.play();
	course(9);
func _on_Course9_mouse_entered():
	mouseFocus = "Base/Course9"; button_mouse_entered(); changeFocus();
func _on_Course9_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Course10_pressed():
	$AudioButton.play();
	course(10);
func _on_Course10_mouse_entered():
	mouseFocus = "Base/Course10"; button_mouse_entered(); changeFocus();
func _on_Course10_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Course11_pressed():
	$AudioButton.play();
	course(11);
func _on_Course11_mouse_entered():
	mouseFocus = "Base/Course11"; button_mouse_entered(); changeFocus();
func _on_Course11_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Course12_pressed():
	$AudioButton.play();
	course(12);
func _on_Course12_mouse_entered():
	mouseFocus = "Base/Course12"; button_mouse_entered(); changeFocus();
func _on_Course12_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Course13_pressed():
	$AudioButton.play();
	course(13);
func _on_Course13_mouse_entered():
	mouseFocus = "Base/Course13"; button_mouse_entered(); changeFocus();
func _on_Course13_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_Course14_pressed():
	$AudioButton.play();
	course(14);
func _on_Course14_mouse_entered():
	mouseFocus = "Base/Course14"; button_mouse_entered(); changeFocus();
func _on_Course14_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_BackButton_pressed():
	$AudioButton.play();
	Global.changeScene("res://scenes/ui/MainMenu.tscn");
func _on_BackButton_mouse_entered():
	mouseFocus = "BackButton"; button_mouse_entered(); changeFocus();
func _on_BackButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_YourLevels_pressed():
	$AudioButton.play();
func _on_YourLevels_mouse_entered():
	mouseFocus = "YourLevels"; button_mouse_entered(); changeFocus();
func _on_YourLevels_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_DownloadedLevels_pressed():
	pass
	#$AudioButton.play();
func _on_DownloadedLevels_mouse_entered():
	mouseFocus = "DownloadedLevels"; button_mouse_entered(); changeFocus();
func _on_DownloadedLevels_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

#Level Info
func enterTextFinished(text, type):
	if (type == "CourseName"):
		var f = File.new();
		
		f.open(Global.currentlevel, File.READ);
		var content = f.get_as_text();
		f.close();
		
		var newpath = Global.get_game_dir()+"/Courses/"+text+".wm";
		
		f.open(newpath, File.WRITE);
		f.store_string(content);
		f.close();
		
		var dir = Directory.new()
		dir.remove(Global.currentlevel);
		
		Global.currentlevel = newpath;
		
		setCourseName();
		$LevelInfo.hide();
		
		savedFocus = getFocusNode();
		Global.showMessage("Nombre cambiado correctamente.", self);
	if (type == "CourseDescription"):
		Global.loadCourseData(false);
		
		Global.currentCourseDescription = text;
		
		Global.saveCourseData(false);
		
		setCourseName();
		$LevelInfo.hide();
		
		savedFocus = getFocusNode();
		Global.showMessage("Descripción cambiada correctamente.", self);
	editingText = false;

func _on_CloseButton_pressed():
	$AudioButton.play();
	$LevelInfo.hide();
	if (Global.CurrentInput == "Gamepad"):
		$Base/Course0.grab_focus();
func _on_CloseButton_mouse_entered():
	mouseFocus = "LevelInfo/CloseButton"; button_mouse_entered(); changeFocus();
func _on_CloseButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_EditButton_pressed():
	$AudioButton.play();
	Global.changeScene("res://scenes/Level.tscn");
	Global.toLoad = true;
func _on_EditButton_mouse_entered():
	mouseFocus = "LevelInfo/EditButton"; button_mouse_entered(); changeFocus();
func _on_EditButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_EditCourseName_pressed():
	$AudioButton.play();
	savedFocus = getFocusNode();
	Global.enterText("Escribe el nuevo nombre del nivel:", "CourseName", self);
func _on_EditCourseName_mouse_entered():
	mouseFocus = "LevelInfo/EditCourseName"; button_mouse_entered(); changeFocus();
func _on_EditCourseName_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_EditCourseDescription_pressed():
	$AudioButton.play();
	savedFocus = getFocusNode();
	Global.enterText("Escribe la nueva descripción del nivel:", "CourseDescription", self);
func _on_EditCourseDescription_mouse_entered():
	mouseFocus = "LevelInfo/EditCourseDescription"; button_mouse_entered(); changeFocus();
func _on_EditCourseDescription_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_EraseCourse_pressed():
	_on_CloseButton_pressed();
	
	var dir = Directory.new()
	dir.remove(Global.currentlevel);
	Global.currentlevel = "";
	setCourseName();
	
	savedFocus = getFocusNode();
	Global.showMessage("Nivel borrado correctamente.", self);
func _on_EraseCourse_mouse_entered():
	mouseFocus = "LevelInfo/EraseCourse"; button_mouse_entered(); changeFocus();
func _on_EraseCourse_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_PlayButton_pressed():
	$AudioButton.play();
	Global.coursePlaying = true;
	Global.changeScene("res://scenes/ui/playintro.tscn");
	Global.toLoad = true;
func _on_PlayButton_mouse_entered():
	mouseFocus = "LevelInfo/PlayButton"; button_mouse_entered(); changeFocus();
func _on_PlayButton_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();
