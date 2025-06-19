extends CanvasLayer

var can_go: bool = false
var request_sent: bool = false

var connecting: bool = false

func _ready():
	var app = 0
	if (!Online.playing_online):
		$Titlebar/AuthorName.text = Global.courseGetUser(Global.currentlevel);
		app = Global.courseGetAppeareance(Global.currentlevel);
		$Titlebar/CourseName.text = Global.currentCourseName;
	else:
		$Titlebar/AuthorName.text = Online.local_loaded_level.author;
		app = Global.courseGetAppeareance(Online.local_loaded_level_data);
		$Titlebar/CourseName.text = Online.local_loaded_level.name
	
	Online.connect("request_set_played_answer", self, "_request_set_played_answer")
	
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
	
	yield(get_tree().create_timer(1.0), "timeout")
	
	if (Online.playing_online):
		$Loading.show()
		$ConnectionOutTimer.start()
		connecting = true
		Online.rpc("_request_set_played", Online.local_loaded_level.id, Online.account_id)

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


func _request_set_played_answer(code: String) -> void:
	$ConnectionOutTimer.stop()
	$Loading.hide()
	connecting = false
	if (code == "success"):
		request_sent = true
	else:
		Global.changeScene("res://scenes/ui/online.tscn", self)
		print("Error from Wonder Maker Online server, aborting...")


func _on_ConnectionOutTimer_timeout():
	if (connecting):
		$Loading.hide()
		connecting = false
		Global.changeScene("res://scenes/ui/online.tscn", self)
		print("Can't communicate to Wonder Maker Online server, aborting...")
