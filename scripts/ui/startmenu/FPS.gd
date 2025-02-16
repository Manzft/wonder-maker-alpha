extends Label

func _process(delta):
	text = "FPS: "+str(round(1/delta));
	
	if (Global.FPS && !visible):
		show();
	elif (!Global.FPS && visible):
		hide();
