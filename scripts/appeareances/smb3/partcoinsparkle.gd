extends AnimatedSprite

func _ready():
	frame = 0;
	play("default");

func _process(_delta):
	$Shadow.frame = frame;

func _on_Timer_timeout():
	queue_free();
