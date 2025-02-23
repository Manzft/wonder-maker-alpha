extends Sprite

func _ready():
	yield(get_tree(), "idle_frame");

func _process(_delta):
	if (is_in_group("SMB_P_HIT")):
		$Shadow.frame = frame

func _on_Timer_timeout():
	queue_free();

func _on_PartHit_animation_finished():
	_on_Timer_timeout();
