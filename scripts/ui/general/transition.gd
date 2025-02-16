extends CanvasLayer

var scene;

func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "in"):
		get_tree().change_scene(scene);
	else:
		queue_free();
