extends CanvasLayer

var branchmenu = false;
var ready = false;

func changeInput():
	if (Global.CurrentInput == "Mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	if (Global.CurrentInput == "Gamepad"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);

func _ready():
	Global.transition();
	
	yield(get_tree().create_timer(1), "timeout");
	$AnimationPlayer.play("start");
	yield(get_tree().create_timer(0.5), "timeout");
	ready = true;
	
func _on_Timer_timeout():
	Global.changeScene("res://scenes/ui/MainMenu.tscn");

func _process(_delta):
	if (Input.is_action_just_pressed("a") || Input.is_action_just_pressed("b") || Input.is_action_just_pressed("start")):
		if (ready):
			_on_Timer_timeout();
 
func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "start"):
		_on_Timer_timeout();
