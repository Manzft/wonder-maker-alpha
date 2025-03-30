extends CanvasLayer

func _ready():
	setButtonsTransparency()
	
func _process(_delta):
	setButtonsTransparency()

func setButtonsTransparency():
	var a = Global.CONTROLS_TRANSPARENCY/100.0;
	$RightDown.modulate.a = a;
	$LeftDown.modulate.a = a;

func _on_SprintToggle_toggled(button_pressed):
	get_parent().automaticSprint = button_pressed;
