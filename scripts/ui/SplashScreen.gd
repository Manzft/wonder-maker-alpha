extends CanvasLayer

var branchmenu = false;
var ready = false;

func changeInput():
	if (Global.CurrentInput == "Mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	if (Global.CurrentInput == "Gamepad"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);

func _ready():
	randomize();
	var ir = round(rand_range(0, 4));
	if (ir == 0):
		$Sprite/MarioWalkNSMBU.show();
	elif (ir == 1):
		$Sprite/MarioIdleNSMBU.show();
	elif (ir == 2):
		$Sprite/MarioRunNSMBU.show();
	else:
		$Sprite/MarioIdleWONDER.show();
	
	yield(get_tree().create_timer(1), "timeout");
	$AnimationPlayer.play("start");
	$SoundStart.play();
	yield(get_tree().create_timer(0.5), "timeout");
	ready = true;
	
func _on_Timer_timeout():
	#Global.changeScene("res://scenes/ui/MainMenu.tscn");
	Global.changeScene("res://scenes/ui/intro.tscn");

func _input(event):
	if (event is InputEventKey || event is InputEventScreenTouch):
		if (ready):
			_on_Timer_timeout();
