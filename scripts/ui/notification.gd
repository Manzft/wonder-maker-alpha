extends CanvasLayer

func _show(text: String):
	$Anchor/Body/Label.text = text
	$Anchor/Body/AnimationPlayer.play("in")
