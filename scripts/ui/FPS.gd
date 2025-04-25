extends CanvasLayer

var frame: float = 0.0

func _ready():
	var current_api = ""
	var api = OS.get_current_video_driver()
	
	match (api):
		OS.VIDEO_DRIVER_GLES2:
			current_api = "GLES2"
			$API.self_modulate = Color("#bcbcbc")
			Color("#bcbcbc")
		OS.VIDEO_DRIVER_GLES3:
			current_api = "GLES3"
			$API.self_modulate = Color("#4b84ff")
	
	if (current_api != ""):
		$API.text = current_api

func _process(delta):
	frame += delta
	if (frame >= 0.5):
		frame = 0
		var framerate = round(1/delta)
		if (Global.VSYNC):
			var screen_refresh_rate = round(OS.get_screen_refresh_rate())
			if (framerate > screen_refresh_rate):
				framerate = screen_refresh_rate
		
		$API/FPS.text = str(round(framerate))
