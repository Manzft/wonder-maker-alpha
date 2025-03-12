extends Sprite

var shadow : Sprite;

func eraseShadow():
	shadow.queue_free();

func _ready():
	yield(get_tree(), "idle_frame");
	shadow = Sprite.new();
	shadow.frame = frame;
	shadow.hframes = hframes;
	shadow.texture = texture;
	get_parent().get_node("ShadowViewport").add_child(shadow);

func _process(_delta):
	if (!Global.playing):
		eraseShadow();
		queue_free();
	if (is_in_group("SMB_P_HIT")):
		shadow.position = global_position+Vector2(3*3.25, 3*3.25);
		shadow.frame = frame;
		shadow.scale = scale;

func _on_AnimationPlayer_animation_finished(anim_name):
	eraseShadow();
	queue_free();
