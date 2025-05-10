extends StaticBody2D

onready var currentSprite = get_node("SpriteGround");

var shadow : AnimatedSprite;

func render(group, forcerender = false, render_range = 60):
	if (forcerender):
		set_process(true);
		set_physics_process(true);
		return
	if (group != ""):
		if (!is_in_group(group)):
			return
	var scrwidth = get_node("../Editor/BlackScreen").rect_size.x;
	var distance = abs(position.x-Global.campos.x);
	if (distance-(scrwidth/2) > scrwidth*(render_range*0.01)):
		set_process(false);
		set_physics_process(false);
	else:
		set_process(true);
		set_physics_process(true);

func floorErase():
	var delete = false;
	if (get_parent().calculateGrid(position.x, position.y).x <= 6):
		if (get_parent().calculateGrid(position.x, position.y).y >= get_node("../LevelFloor").current_grid.y):
			delete = true;
	if (get_parent().calculateGrid(position.x, position.y).x >= get_node("../EndFloor").current_grid.x-1):
		if (get_parent().calculateGrid(position.x, position.y).y >= get_node("../EndFloor").current_grid.y):
			delete = true;
	if (delete): get_parent().eraseObject(position, false);

func erase():
	get_parent().eraseObject(position, false);

func changeStyle():
	var pos = position;
	var grid = get_parent().calculateGrid(pos.x, pos.y);
	var obj = get_parent().grid[grid.x][grid.y];
	var scene = Global.object[Global.CurrentAppeareance][obj][Global.OP_SCENE];
	var inst = scene.instance();
	get_parent().grid_node[grid.x][grid.y] = inst;
	get_parent().add_child(inst);
	inst.position = pos;
	queue_free();

func eraseShadow():
	shadow.queue_free();

func _ready():
	Global.connect("render", self, "render");
	Global.connect("floorErase", self, "floorErase");
	Global.connect("changeStyle", self, "changeStyle");
	Global.connect("erase", self, "erase");
	styleChanged();

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
	
	shadow.position = currentSprite.global_position+Vector2(3*3.25, 3*3.25);
	shadow.frame = currentSprite.frame;
	shadow.animation = currentSprite.animation;
	shadow.scale = currentSprite.scale;

func styleChanged():
	match (Global.CurrentStyle):
		_:
			currentSprite.hide();
			currentSprite = get_node("SpriteGround");
			currentSprite.show();
	
	if (shadow == null):
		pass
	else:
		shadow.queue_free();
	
	shadow = AnimatedSprite.new();
	shadow.frames = currentSprite.frames;
	shadow.scale = currentSprite.scale;
	get_node("../ViewportShadow/Shadows").add_child(shadow);

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
