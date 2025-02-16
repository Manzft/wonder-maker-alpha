extends Node2D

var activity = Discord.Activity.new()

func _ready():
	pass

func update_activity(type = "") -> void:
	activity.set_type(Discord.ActivityType.Playing)
	activity.set_state("")

	var assets = activity.get_assets()
	assets.set_large_image("deficon")
	assets.set_large_text("WM")
	assets.set_small_image("")
	assets.set_small_text("")
	
	match (type):
		"MainMenu":
			activity.set_details("En el Menú Principal")
		"Editing":
			activity.set_details("Creando un Nivel");
			if (Global.currentCourseName != ""):
				activity.set_state("Nivel: "+Global.currentCourseName);
			assets.set_small_image("cursor_editor")
			assets.set_small_text("Cursor")
		"PlayingCoursebot":
			activity.set_details("Jugando nivel del Guardabot");
			activity.set_state("Nivel: "+Global.currentCourseName);
			assets.set_small_image("playing")
			assets.set_small_text("Joycon")
		"Coursebot":
			activity.set_details("En el Guardabot");
			assets.set_small_image("coursebot")
			assets.set_small_text("Coursebot")

	if (!Global.ready):
		var timestamps = activity.get_timestamps()
		timestamps.set_start(OS.get_unix_time());
		Global.ready = true;
	#timestamps.set_end(1507665886)

	var result = yield(Discord.activity_manager.update_activity(activity), "result").result
	if result != Discord.Result.Ok:
		push_error(str(result))
