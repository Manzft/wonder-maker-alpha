extends Sprite

func _process(_delta):
	if (Global.playing && $AnimationPlayer.current_animation != "idle"):
		if (!get_node("../Character").course_clear):
			$AnimationPlayer.play("idle");

func _on_Area2D_body_entered(body):
	if (body.is_in_group("Character")):
		if (!body.course_clear):
			body.course_clear = true;
			body.in_flag_pole = true;
			body.current_sprite.flip_h = false;
			body.motion.y = 0;
			body.motion.x = 0;
			if (body.sneaking):
				body.releaseSneak();
			body.get_node("SoundPButton").stop();
			$AnimationPlayer.play("got");
			body.get_node("SoundStar").stop();
			$SoundGoal.play();
			get_parent().gameMusic(false);
			
			match ($ItemFrame/Item.frame):
				0: $ItemFrame/ItemGot.play("mushroom");
				1: $ItemFrame/ItemGot.play("fireflower");
				2: $ItemFrame/ItemGot.play("star");
				3: $ItemFrame/ItemGot.play("1up");
			
			body.motion = Vector2(0, 0);
			
			$BaseArea.monitoring = true;

func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "got"):
		yield(get_tree().create_timer(1.0), "timeout");
		$BaseArea.monitoring = false;
		if (!Global.coursePlaying):
			get_node("../Editor")._on_Edit_pressed();
		else:
			Global.changeScene("res://scenes/ui/coursebot.tscn", get_parent())
			Global.coursePlaying = false;

func _on_BaseArea_body_entered(body):
	if (body.is_in_group("Character")):
		if (body.in_flag_pole):
			body.in_flag_pole = false;
