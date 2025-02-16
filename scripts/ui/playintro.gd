extends CanvasLayer

func _ready():
	$Titlebar/CourseName.text = Global.currentCourseName;
	$Titlebar/AuthorName.text = Global.courseGetUser(Global.currentlevel);
	Global.transition(self);
	yield(get_tree().create_timer(1.0), "timeout");
	$Control/AnimationPlayer.play("jump");

func _on_AnimationPlayer_animation_finished(anim_name):
	Global.coursePlaying = true;
	Global.changeScene("res://scenes/Level.tscn", self);
	Global.toLoad = true;
