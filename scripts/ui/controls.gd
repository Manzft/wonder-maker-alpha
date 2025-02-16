extends CanvasLayer

func _on_SprintToggle_toggled(button_pressed):
	get_parent().automaticSprint = button_pressed;
