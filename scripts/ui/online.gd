extends CanvasLayer

var CurrentMenu: String = "Online";

var CurrentSubMenu: String = "Main"
# Availables Current Sub Menus:
# Main | Courses | Leaderboards

#Hi from VSCode

var savedFocus;
var mouseFocus = "";

var branchmenu = false;

var selected_level_panel: Node = null

var back_button_course_texture: Texture = load("res://sprites/ui/online/back_courseworld.png")
var back_button_texture: Texture = load("res://sprites/ui/startmenu/back.png")

var user_array = []

var levels_array = []

var selected_tab: Node = null

func update_selected_level_panel(node: Node = null):
	if (selected_level_panel != null):
		if (is_instance_valid(selected_level_panel)):
			selected_level_panel.get_node("AnimationPlayer").play("extract")
			selected_level_panel = null
	
	if (node != null):
		selected_level_panel = node
		selected_level_panel.get_node("AnimationPlayer").play("expand")

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
		$FPS.grab_focus();
		changeFocus();
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	if (Global.CurrentInput == "Gamepad"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);
	changeFocus();

func changeFocus():
	if (Global.CurrentInput == "Gamepad"):
		match (CurrentMenu):
			"StartMenu":
				#$StartButton.grab_focus();
				pass
			"StartMenuAction":
				$ActionButtons/MakeButton.grab_focus();
			"StartMenuPlay":
				$PlayButtons/Coursebot.grab_focus();
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
	
	#Transition
	Global.transition();
	
	#Connect button focus signals
	var nodes = get_tree().get_nodes_in_group("Button");
	for node in nodes:
		node.connect("focus_entered", self, "focus_change");
	
	if (Global.DISCORD_PRESENCE):
		Global.setDiscordState("courseworld")
	
	setMe(find_node("PopularCourses"))
	
	yield(get_tree().create_timer(0.5), "timeout")
	if (Online.persistency_menu != ""):
		if (Online.persistency_menu == "NewCourses" || Online.persistency_menu == "PopularCourses"):
			$CoursesMenu/AnimationPlayer.play("in")
			$CoursesMenu.show()
			$CoursesMenu/ScrollContainer.scroll_vertical = 0
			CurrentSubMenu = "Courses"
			setMe(find_node(Online.persistency_menu))
			yield(updateLevelsDictionary(), "completed")
		Online.persistency_menu = ""
	#else:
	#	yield(updateLevelsDictionary(), "completed")
	#yield(updateUserDictionary(), "completed")
	
	#test_publish()
	#print("TEST PUBLISH")

func _process(delta: float):
	if (selected_level_panel != null && $CoursesMenu/BackButton.texture_normal != back_button_texture):
		$CoursesMenu/BackButton.texture_normal = back_button_texture
	elif (selected_level_panel == null && $CoursesMenu/BackButton.texture_normal != back_button_course_texture):
		$CoursesMenu/BackButton.texture_normal = back_button_course_texture

func getSplashText():
	var i : String = "";
	var numberFloat : float = rand_range(0, 13);
	var number : int = round(numberFloat);
	i = str(number);
	var text = "";
	match (i):
		"0":
			text = "";
		"1":
			text = "Prueba también SMBWF!";
		"2":
			text = "Hecho en Wonder Cave";
		"3":
			text = "Hecho con Godot :)";
		"4":
			text = "Que zoid";
		"5":
			text = "";
		"6":
			text = '';
		"7":
			text = ""
		"8":
			text = "¡Haz niveles divertidos!"
		"9":
			text = "La primera versión de WM salió el 29/9/2024"
		"10":
			text = ""
		"11":
			text = ""
		"12":
			text = "El juego es de código cerrado."
		"13":
			text = ""
	return text;

func sidemenu():
	if (CurrentMenu == "Online"):
		$AnimationPlayer2.play("sidemenu");
		$MusicCourseWorld.stream_paused = true
		CurrentMenu = "SideMenu";
		changeFocus();
		$SideMenu.changeFocus();
	elif (CurrentMenu == "SideMenu"):
		$MusicCourseWorld.stream_paused = false
		CurrentMenu = "Online";
		$AnimationPlayer2.play_backwards("sidemenu");
		$SideMenu.changeFocus();
		changeFocus();

#-------------
func clear_list():
	for node in $CoursesMenu/ScrollContainer/MarginContainer/VBoxContainer.get_children():
		node.queue_free()

class MyCustomSorter:
	static func sort_ascending(a, b):
		if a["likes"] > b["likes"]:
			return true
		return false
	static func sort_leaderboard(a, b):
		if a["finished_levels"] > b["finished_levels"]:
			return true
		return false
	static func sort_recent(a, b):
		if a["created_at"] > b["created_at"]:
			return true
		return false

func list_levels():
	get_node(CurrentSubMenu+"Menu/FailedRequestLabel").hide()
	clear_list()
	
	var organized_levels_array = levels_array.duplicate()
	
	if (selected_tab.name == "NewCourses"):
		organized_levels_array.sort_custom(MyCustomSorter, "sort_recent")
	elif (selected_tab.name == "PopularCourses"):
		organized_levels_array.sort_custom(MyCustomSorter, "sort_ascending")
	
	var count: int = 1
	for level in organized_levels_array:
		if (count <= 30):
			var node = load("res://scenes/online/level_panel.tscn").instance();
			#Name
			var level_name_node = node.get_node("MarginContainer/VBoxContainer/HBoxContainer/LevelName")
			level_name_node.text = level.name
			
			#Likes
			var likes_node = node.find_node("LikeLabel")
			likes_node.text = str(int(level.likes))
			
			#Dislikes
			var dislikes_node = node.find_node("DislikeLabel")
			dislikes_node.text = str(int(level.dislikes))
			
			#Played
			var played_node = node.find_node("PlayedLabel")
			played_node.text = str(int(level.played))
			
			#Clear
			var clear_node = node.find_node("ClearLabel")
			clear_node.text = str(int(level.clear))
			
			#Deaths
			var deaths_node = node.find_node("DeathsLabel")
			deaths_node.text = str(int(level.deaths))
			
			#Porcentage
			var porcentage_node = node.find_node("PorcentageLabel")
			if (int(level.played) != 0 && int(level.clear) != 0):
				var porcentage: float = (level.clear/level.played)*100
				porcentage_node.text = str("%0.2f" % porcentage, "%")
			else:
				porcentage_node.text = "0.00%"
				
			#Level Code
			var level_id_node = node.find_node("IDLabel")
			level_id_node.text = str(int(level.id))
			
			var file = level.data
			#Level Data
			node.level_data = level
			
			#Appeareance Icon
			var app = Global.courseGetAppeareance(file)
			var icon_node = node.get_node("MarginContainer/VBoxContainer/HBoxContainer/LevelAppeareance")
			match (app):
				Global.APP_SMB: icon_node.texture = load("res://sprites/ui/editor/appeareances/card_smb.png")
				Global.APP_SMB3: icon_node.texture = load("res://sprites/ui/editor/appeareances/card_smb3.png")
			
			#Thumbnail
			var thumbnail = Global.courseGetThumbnail(file)
			var thumbnail_node = node.get_node("MarginContainer/VBoxContainer/HBoxContainer2/LevelThumbnail")
			thumbnail_node.texture = thumbnail
			
			#Description
			var description_node = node.get_node("MarginContainer/VBoxContainer/VBoxContainer/DescriptionPanel/DescriptionLabel")
			var description = Global.courseGetDescription(file);
			description_node.text = description
			
			#Creator Name
			var creator_name_node = node.get_node("MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer/MakerName")
			var creator_name = Global.courseGetUser(file);
			creator_name_node.text = creator_name
			
			$CoursesMenu/ScrollContainer/MarginContainer/VBoxContainer.add_child(node);
		else:
			break

func clear_leaderboard_list():
	for node in $LeaderboardsMenu/ScrollContainer/MarginContainer/VBoxContainer.get_children():
		node.queue_free()

func list_leaderboard_levels():
	get_node(CurrentSubMenu+"Menu/FailedRequestLabel").hide()
	clear_leaderboard_list()
	
	var organized_user_array = user_array.duplicate()
	organized_user_array.sort_custom(MyCustomSorter, "sort_leaderboard")
	
	var count: int = 1
	for user in organized_user_array:
		if (count <= 30):
			var node = load("res://scenes/online/user_panel.tscn").instance()
			
			#User Name
			node.find_node("UserName").text = user.nick
			
			#Score
			node.find_node("ScoreCounter").text = str(int(user.finished_levels))
			
			#Top
			node.find_node("TopCounter").text = str(count)
			
			$LeaderboardsMenu/ScrollContainer/MarginContainer/VBoxContainer.add_child(node)
			
			count += 1
		else:
			break

func test_publish():
	var todir = Global.get_game_dir()+"/Courses";
	var dir = Directory.new()
	var dir_open = dir.open(todir)
	var filecount = 0;
	
	if (dir_open == OK):
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
				#print("Found directory: " + file_name)
			else:
				#print("Found file: " + file_name)
				if (file_name.get_extension() == "wom"):
					var file = Global.get_game_dir()+"/Courses/"+file_name
					if (Global.courseGetVersion(file) != "1.3" && filecount == 0):
						Online.publish_level(Global.courseGetData(file), file_name.trim_suffix(".wom"))
						filecount += 1;
					else:
						break
			file_name = dir.get_next()

#General
func button_mouse_entered():
	#$AudioSelectButton.pitch_scale = randf_range(0.9, 1.1)
	$AudioSelectButton.play()
	get_node(mouseFocus+"/Selection/AnimationPlayer").play("idle")
	changeFocus()
	if (get_node(mouseFocus).is_in_group("LevelPanel") ||
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
	$FPS.grab_focus();
	if (mouseFocus != ""):
		if (!get_node(mouseFocus).is_in_group("LevelPanel") && !get_node(mouseFocus).is_in_group("IgnoreSelection")):
			get_node(mouseFocus+"/Selection/AnimationPlayer").play("RESET");
			get_node(mouseFocus).rect_pivot_offset.x = get_node(mouseFocus).rect_size.x/2;
			get_node(mouseFocus).rect_pivot_offset.y = get_node(mouseFocus).rect_size.y/2;
			var tween = get_tree().create_tween();
			var scale: Vector2 = str2var(get_node(mouseFocus).editor_description);
			tween.tween_property(get_node(mouseFocus), "rect_scale", scale, 0.0625);
	changeFocus();
	#Input.set_custom_mouse_cursor(load("res://sprites/ui/cursor_editor.png"));

#Main
func _on_start_button_pressed():
	if (CurrentMenu != "Online"):
		return
	sidemenu();
	$AudioStart.play();
func _on_start_button_mouse_entered():
	mouseFocus = "StartButton"; button_mouse_entered(); changeFocus();
func _on_start_button_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_courses_button_pressed():
	$CoursesMenu.show()
	$CoursesMenu/AnimationPlayer.play("in")
	CurrentSubMenu = "Courses"
	$AudioBigButton.play();
	$CoursesMenu/ScrollContainer.scroll_vertical = 0
	setMe(find_node("NewCourses"))
	updateLevelsDictionary()
	#list_levels()
func _on_courses_button_mouse_entered():
	mouseFocus = "CoursesButton"; button_mouse_entered(); changeFocus();
func _on_courses_button_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

func _on_leaderboards_button_pressed():
	$LeaderboardsMenu.show()
	$LeaderboardsMenu/AnimationPlayer.play("in")
	CurrentSubMenu = "Leaderboards"
	$AudioBigButton.play();
	updateUserDictionary()
	#list_leaderboard_levels()
	$LeaderboardsMenu/ScrollContainer.scroll_vertical = 0
func _on_leaderboards_button_mouse_entered():
	mouseFocus = "LeaderboardsButton"; button_mouse_entered(); changeFocus();
func _on_leaderboards_button_mouse_exited():
	button_mouse_exited(); mouseFocus = ""; changeFocus();

#Sub Menus
func _on_back_button_pressed() -> void:
	$AudioCloseMenu.play()
	match (CurrentSubMenu):
		"Courses":
			if (selected_level_panel == null):
				$CoursesMenu/AnimationPlayer.play("out")
				yield($CoursesMenu/AnimationPlayer, "animation_finished")
				$CoursesMenu.hide()
				CurrentSubMenu = "Main"
			else:
				update_selected_level_panel()
		"Leaderboards":
			$LeaderboardsMenu/AnimationPlayer.play("out")
			yield($LeaderboardsMenu/AnimationPlayer, "animation_finished")
			$LeaderboardsMenu.hide()
			CurrentSubMenu = "Main"
	changeFocus();
func _on_back_button_mouse_entered() -> void:
	mouseFocus = CurrentSubMenu+"Menu/BackButton"; button_mouse_entered(); changeFocus();
func _on_back_button_mouse_exited() -> void:
	button_mouse_exited(); mouseFocus = ""; changeFocus();

#Courses
func checkClick(event: InputEvent):
	var check: bool = false
	if (event is InputEventMouseButton):
		if (event.button_index == BUTTON_LEFT):
			if (!event.pressed):
				check = true
	if (event is InputEventScreenTouch):
		if (!event.pressed):
			check = true
	return check

func setMe(select_node: Node):
	for node in select_node.get_parent().get_children():
		node.self_modulate = Color("#c7b6f6")
		node.get_node("Label").self_modulate = Color("#61528c")
	
	select_node.self_modulate = Color("#9b75e7")
	select_node.get_node("Label").self_modulate = Color("#ffffff")
	
	selected_tab = select_node

func _on_popular_courses_gui_input(event: InputEvent) -> void:
	if (checkClick(event)):
		if (levels_array.empty()):
			return
		setMe(find_node("PopularCourses"))
		$AudioButton.play()
		clear_list()
		#updateLevelsDictionary()
		list_levels()

func _on_new_courses_gui_input(event: InputEvent) -> void:
	if (checkClick(event)):
		if (levels_array.empty()):
			return
		setMe(find_node("NewCourses"))
		$AudioButton.play()
		clear_list()
		#updateLevelsDictionary()
		list_levels()

#Leaderboards
func _on_completed_levels_gui_input(event: InputEvent) -> void:
	if (checkClick(event)):
		if (user_array.empty()):
			return
		setMe(find_node("CompletedLevels"))
		$AudioButton.play()

#----------------
func updateUserDictionary():
	clear_leaderboard_list()
	print("Fetching users info...")
	if (CurrentSubMenu != "Main"):
		get_node(CurrentSubMenu+"Menu/FailedRequestLabel").hide()
		get_node(CurrentSubMenu+"Menu/Loading").show()
	$UIBlocker.show()
	var data = yield(Online.receive_data("accounts"), "completed")
	if (CurrentSubMenu != "Main"): get_node(CurrentSubMenu+"Menu/Loading").hide()
	if (data != null):
		print("Fetch completed, listing users")
		user_array = data
		list_leaderboard_levels()
	else:
		print("Fetch error, can't get users")
		if (CurrentSubMenu != "Main"):
			get_node(CurrentSubMenu+"Menu/FailedRequestLabel").show()
	
	$UIBlocker.hide()

func updateLevelsDictionary():
	clear_list()
	print("Fetching levels...")
	if (CurrentSubMenu != "Main"):
		get_node(CurrentSubMenu+"Menu/FailedRequestLabel").hide()
		get_node(CurrentSubMenu+"Menu/Loading").show()
	$UIBlocker.show()
	var data = yield(Online.receive_data("levels"), "completed")
	if (CurrentSubMenu != "Main"): get_node(CurrentSubMenu+"Menu/Loading").hide()
	if (data != null):
		print("Fetch completed, listing levels")
		levels_array = data
		list_levels()
	else:
		print("Fetch error, can't get levels")
		if (CurrentSubMenu != "Main"):
			get_node(CurrentSubMenu+"Menu/FailedRequestLabel").show()
	
	$UIBlocker.hide()
