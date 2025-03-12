extends AnimatedSprite

var shadow : AnimatedSprite

func eraseShadow():
	shadow.queue_free();

func _ready():
	frame = 0;
	play("default");
	shadow = AnimatedSprite.new();
	shadow.frames = frames;
	shadow.scale = scale;
	get_node("../ShadowViewport").add_child(shadow);

func _process(_delta):
	shadow.frame = frame;
	shadow.position = position+Vector2(3*3.25, 3*3.25);

func _on_Timer_timeout():
	eraseShadow();
	queue_free();
