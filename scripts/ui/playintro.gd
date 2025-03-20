extends CanvasLayer

func _ready():
	$Titlebar/CourseName.text = Global.currentCourseName;
	$Titlebar/AuthorName.text = Global.courseGetUser(Global.currentlevel);
	var app = Global.courseGetAppeareance(Global.currentlevel);
	Global.transition(self);
	match (app):
		Global.APP_SMB:
			$Control/SpriteContainer/SMB.show();
		Global.APP_SMB3:
			$Control/SpriteContainer/SMB3.show();
	yield(get_tree().create_timer(1.0), "timeout");
	match (app):
		Global.APP_SMB:
			$SoundJumpSMB.play();
		Global.APP_SMB3:
			$SoundJumpSMB3.play();
	$Control/AnimationPlayer.play("jump");

func _on_AnimationPlayer_animation_finished(anim_name):
	Global.coursePlaying = true;
	Global.changeScene("res://scenes/Level.tscn", self);
	Global.toLoad = true;
