extends StaticBody2D

onready var currentSprite = get_node("SpriteGround");

func _ready():
	styleChanged();
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");
	$VisibilityEnabler2D.emit_signal("screen_exited")

func _process(_delta):
	if (!get_node("../Editor").playing):
		if (get_parent().grab && get_parent().grab_node == self):
			currentSprite.play("on");
			currentSprite.speed_scale = 1;
		else:
			currentSprite.play("on");
			currentSprite.speed_scale = 0;
			currentSprite.frame = 0;
	else:
		currentSprite.speed_scale = 1;
		if (is_in_group("OnOffSwitch")):
			if (get_node("../Character").onoff):
				currentSprite.play("off");
			else:
				currentSprite.play("on");
		else:
			if (get_node("../Character").onoff2):
				currentSprite.play("off");
			else:
				currentSprite.play("on");
	Global.rendering(self);

func styleChanged():
	match (Global.CurrentStyle):
		_:
			currentSprite.hide();
			currentSprite = get_node("SpriteGround");
			currentSprite.show();

func hit(switch = true):
	if ($AnimationPlayer.current_animation != "hit"):
		$AnimationPlayer.play("hit");
			
		for node in get_tree().get_nodes_in_group("Powerup"):
			if (node.position.y >= position.y-52-5 && node.position.y <= position.y-26):
				if (node.position.x >= position.x-32 && node.position.x <= position.x+32):
					node.jump();
		for node in get_tree().get_nodes_in_group("Enemy"):
			if (node.position.y >= position.y-52-5 && node.position.y <= position.y-26):
				if (node.position.x >= position.x-32 && node.position.x <= position.x+32):
					if (!node.is_in_group("Solid")):
						get_node("../Character/SoundShellHit").play();
						if (node.is_in_group("HasShell")):
							node.hit("", true);
							node.jump(true);
						else:
							node.hitDead = true;
							if (node.position.x < position.x):
								node.hit("left");
							elif (node.position.x >= position.x):
								node.hit("right");
		
		if (!switch): return
		
		var ch = get_node("../Character");
		if (is_in_group("OnOffSwitch")):
			if (ch.onoff):
				ch.onoff = false;
			else:
				ch.onoff = true;
		else:
			if (ch.onoff2):
				ch.onoff2 = false;
			else:
				ch.onoff2 = true;

func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "hit"):
		pass
