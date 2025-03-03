extends CanvasLayer

func _ready():
	var a = Global.CONTROLS_TRANSPARENCY/100.0;
	print(a);
	$RightDown.modulate.a = a;
	$LeftDown.modulate.a = a;

func _on_SprintToggle_toggled(button_pressed):
	get_parent().automaticSprint = button_pressed;
