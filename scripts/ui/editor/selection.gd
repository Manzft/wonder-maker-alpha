extends Sprite

func generateAdditional(grid):
	var inst = load("res://scenes/ui/additionalselection.tscn").instance();
	add_child(inst);
	inst.position = 52*grid;
