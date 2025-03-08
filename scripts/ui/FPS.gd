extends CanvasLayer

var frame = 0.0;

func _process(delta):
	frame += delta;
	if (frame >= 0.5):
		frame = 0;
		$OGL/FPS.text = str(round(1/delta));
