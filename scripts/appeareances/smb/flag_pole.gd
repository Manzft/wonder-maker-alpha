extends Sprite

var shadow : Sprite
var flagshadow : Sprite
var castleflagshadow : Sprite
var castleleftshadow : Sprite
var castlerightshadow : Sprite
var castledoorshadow : Sprite

func _ready():
	shadow = Sprite.new();
	flagshadow = Sprite.new();
	castleflagshadow = Sprite.new();
	castleleftshadow = Sprite.new();
	castlerightshadow = Sprite.new();
	castledoorshadow = Sprite.new();
	
	shadow.texture = texture;
	flagshadow.texture = $Flag.texture;
	castleflagshadow.texture = $CastleFlag.texture;
	castleleftshadow.texture = $CastleLeft.texture;
	castlerightshadow.texture = $CastleRight.texture;
	castledoorshadow.texture = $CastleDoor.texture;
	
	shadow.scale = scale;
	flagshadow.scale = scale;
	castleflagshadow.scale = scale;
	castleleftshadow.scale = scale;
	castlerightshadow.scale = scale;
	castledoorshadow.scale = scale;
	
	shadow.offset = offset;
	
	get_node("../ShadowViewport").add_child(shadow);
	get_node("../ShadowViewport").add_child(flagshadow);
	get_node("../ShadowViewport").add_child(castleflagshadow);
	get_node("../ShadowViewport").add_child(castleleftshadow);
	get_node("../ShadowViewport").add_child(castlerightshadow);
	get_node("../ShadowViewport").add_child(castledoorshadow);

func _process(_delta):
	shadow.position = global_position+Vector2(3*3.25, 3*3.25);
	flagshadow.position = $Flag.global_position+Vector2(3*3.25, 3*3.25);
	castleflagshadow.position = $CastleFlag.global_position+Vector2(3*3.25, 3*3.25);
	castleleftshadow.position = $CastleLeft.global_position+Vector2(3*3.25, 3*3.25);
	castlerightshadow.position = $CastleRight.global_position+Vector2(3*3.25, 3*3.25);
	castledoorshadow.position = $CastleDoor.global_position+Vector2(3*3.25, 3*3.25);

func _on_Area2D_body_entered(body):
	if (body.is_in_group("Character")):
		if (!body.course_clear):
			body.course_clear = true;
			body.in_flag_pole = true;
			body.current_sprite.flip_h = false;
			if (body.sneaking):
				body.releaseSneak();
			body.get_node("SoundPButton").stop();
			$AnimationPlayer.play("goal");
			body.get_node("SoundStar").stop();
			$SoundGoal.play();
			get_parent().gameMusic(false);
			
			body.position.x = position.x-16;
			body.motion = Vector2(0, 0);
			
			$BaseArea.monitoring = true;

func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "goal"):
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
			body.current_sprite.speed_scale = 0;
			yield(get_tree().create_timer(0.4), "timeout");
			if (body == null):
				return
			body.current_sprite.flip_h = true;
			body.position.x = position.x+16;
			yield(get_tree().create_timer(0.25), "timeout");
			if (body == null):
				return
			body.current_sprite.speed_scale = 1;
			body.in_flag_pole = false;
			body.current_sprite.flip_h = false;

func _on_DoorArea_body_entered(body):
	if (body.is_in_group("Character")):
		if (body.course_clear):
			body.deactivateSubPixelSprite();
