extends CanvasLayer

var can_go: bool = false
var request_sent: bool = false

func _ready():
	$Titlebar/CourseName.text = Global.currentCourseName;
	var app = 0
	if (!Online.playing_online):
		$Titlebar/AuthorName.text = Global.courseGetUser(Global.currentlevel);
		app = Global.courseGetAppeareance(Global.currentlevel);
	else:
		$Titlebar/AuthorName.text = Global.courseGetUser(Online.local_loaded_level_data.data);
		app = Global.courseGetAppeareance(Online.local_loaded_level_data.data);
	
	Global.transition(self);
	match (app):
		Global.APP_SMB:
			$Control/SpriteContainer/SMB.show();
		Global.APP_SMB3:
			$Control/SpriteContainer/SMB3.show();
	
	yield(get_tree().create_timer(1.0), "timeout")
	
	match (app):
		Global.APP_SMB:
			$SoundJumpSMB.play();
		Global.APP_SMB3:
			$SoundJumpSMB3.play();
	$Control/AnimationPlayer.play("jump");
	
	if (Online.playing_online):
		$Loading.show()
		var result = yield(Online.set_played(), "completed")
		$Loading.hide()
		if (result == "success"):
			request_sent = true
		else:
			Global.changeScene("res://scenes/ui/online.tscn", self)
			print("Can't update info in Wonder Maker Online server, aborting...")

func _process(_delta):
	if (Online.playing_online):
		if (can_go && request_sent):
			get_out_here()
			$Loading.hide()
	else:
		if (can_go):
			get_out_here()

func get_out_here():
	can_go = false
	request_sent = false
	Global.coursePlaying = true;
	Global.changeScene("res://scenes/Level.tscn", self);
	Global.toLoad = true;

func _on_AnimationPlayer_animation_finished(anim_name):
	can_go = true
