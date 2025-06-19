extends CanvasLayer

var branchmenu = false;

func _on_Manzft27_AnimationPlayer_animation_finished(anim_name):
	yield(get_tree().create_timer(2.0), "timeout")
	$WonderCaveCommunity/AnimationPlayer.play("start");

func _on_WonderCaveCommunity_AnimationPlayer_animation_finished(anim_name):
	yield(get_tree().create_timer(2.0), "timeout")
	$WonderMaker/AnimationPlayer.play("start");

func _on_StartTimer_timeout():
	if (Global.SPLASH_SCREEN_FINISHED):
		$WonderMaker/AnimationPlayer.play("start");
	else:
		$Manzft27/AnimationPlayer.play("start");

func _on_WonderMaker_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "start"):
		$Loading/AnimationPlayer.play("in");
		yield(get_tree().create_timer(2.0), "timeout");
		$Loading/AnimationPlayer.play("out");
		yield(get_tree().create_timer(1.0), "timeout");
		$WonderMaker/AnimationPlayer.play("out");
	if (anim_name == "out"):
		yield(get_tree().create_timer(1.0), "timeout");
		Global.SPLASH_SCREEN_FINISHED = true;
		Global.saveSettings();
		Global.changeScene("res://scenes/ui/OldSplashScreen.tscn", self);
