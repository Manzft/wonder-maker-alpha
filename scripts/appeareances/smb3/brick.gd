extends StaticBody2D

onready var currentSprite = get_node("SpriteGround");

var shadow : AnimatedSprite = null

var objectInside = "";
var objectAttribute = "";

var deactivated =  false;

var candeactivate = false;

var myEmptyBlock = null;

var myUpCoinDone = false;

var p = false;
var powner = false;

func render(group, forcerender = false, render_range = 60):
	if (forcerender):
		set_process(true);
		set_physics_process(true);
		return
	if (group != ""):
		if (!is_in_group(group)):
			return
	var scrwidth = get_node("../Editor/BlackScreen").rect_size.x
	var distance = abs(position.x-Global.campos.x)
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

	if (delete):
		get_parent().eraseObject(position, false);

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
	inst.objectInside = objectInside;
	inst.objectAttribute = objectAttribute;
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
	if (currentSprite != get_node("SpriteGround")):
		currentSprite.scale = $SpriteGround.scale
		currentSprite.position = $SpriteGround.position
		
	currentSprite.frame = floor(get_parent().syncanim.smb3.brick)
	
	shadow.position = currentSprite.global_position+Vector2(3*3.25, 3*3.25);
	shadow.scale = currentSprite.scale;
	if (!currentSprite.visible || !visible):
		shadow.visible = false;
	else:
		shadow.visible = true;
	
	var delete = false;
	if (get_parent().calculateGrid(position.x, position.y).x <= 6):
		if (get_parent().calculateGrid(position.x, position.y).y >= get_node("../LevelFloor").current_grid.y):
			delete = true;
	if (get_parent().calculateGrid(position.x, position.y).x >= get_node("../EndFloor").current_grid.x):
		if (get_parent().calculateGrid(position.x, position.y).y >= get_node("../EndFloor").current_grid.y):
			delete = true;
	
	if (delete):
		get_parent().eraseObject(position);
	
	if (objectInside != ""):
		if (get_node("../Editor").playing):
			$HasObjectInside.hide();
		else:
			$HasObjectInside.show();
			
	if (!get_node("../Editor").playing):
		currentSprite.speed_scale = 0;
		currentSprite.frame = 0;
		if (!visible):
			show();
			$CollisionShape2D.disabled = false;
		myUpCoinDone = false;
		candeactivate = false;
		$CoinInsideTimer.stop();
		if (deactivated):
			styleChanged();
			deactivated = false;
		if (p):
			eraseShadow();
			queue_free();
		if (powner):
			powner = false;
	else:
		if (powner):
			$CollisionShape2D.disabled = true;
		elif (visible):
			$CollisionShape2D.disabled = false;

func styleChanged():
	match (Global.CurrentStyle):
		"Underground":
			currentSprite.hide();
			currentSprite = get_node("SpriteUnderground");
			currentSprite.show();
		"Ghosthouse":
			currentSprite.hide();
			currentSprite = get_node("SpriteUnderground");
			currentSprite.show();
		"Ghostforest":
			currentSprite.hide();
			currentSprite = get_node("SpriteGhostforest");
			currentSprite.show();
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
	shadow.animation = currentSprite.animation
	shadow.scale = currentSprite.scale
	shadow.position = currentSprite.global_position+Vector2(3*3.25, 3*3.25)
	get_node("../ViewportShadow/Shadows").add_child(shadow)

func hit(var shell = false):
	if ($AnimationPlayer.current_animation != "hit" && visible):
		if (!deactivated):
			$AnimationPlayer.play("hit");
			
			var grid = get_parent().calculateGrid(position.x, position.y);
			if (get_parent().grid[grid.x][grid.y-1] == Global.OBJ_COIN && !myUpCoinDone):
				if (get_parent().grid_node[grid.x][grid.y-1].visible):
					myUpCoinDone = true;
					var inst = get_parent().gotCoin[Global.CurrentAppeareance].instance();
					inst.position = Vector2(position.x, position.y-52);
					get_parent().add_child(inst);
					get_parent().eraseObject(inst.position, false, true);
				
			for node in get_tree().get_nodes_in_group("Powerup"):
				if (node.position.y >= position.y-52-5 && node.position.y <= position.y-26):
					if (node.position.x >= position.x-32 && node.position.x <= position.x+32):
						node.jump();
			for node in get_tree().get_nodes_in_group("Enemy"):
				if (node.position.y >= position.y-52-5 && node.position.y <= position.y-26):
					if (node.position.x >= position.x-32 && node.position.x <= position.x+32):
						if (!node.is_in_group("Solid") && !node.dead):
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
			if (p):
				var gr = get_parent().calculateGrid(position.x, position.y);
				get_parent().grid_node[gr.x][gr.y].powner = false;
				
			
			match (objectInside):
				"coinInside":
					var inst = get_parent().gotCoin[Global.CurrentAppeareance].instance();
					inst.position = position; get_parent().add_child(inst);
					if ($CoinInsideTimer.is_stopped()):
						$CoinInsideTimer.start();
				"oneup":
					candeactivate = true;
					yield(get_tree().create_timer(0.2), "timeout");
					var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_1UP][Global.OP_SCENE].instance();
					inst.position = position;
					inst.exiting = true;
					inst.insided = true;
					get_parent().add_child(inst);
					$PowerUpAppears.play();
				"star":
					candeactivate = true;
					yield(get_tree().create_timer(0.2), "timeout");
					var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_STAR][Global.OP_SCENE].instance();
					inst.position = position;
					inst.exiting = true;
					inst.insided = true;
					get_parent().add_child(inst);
					$PowerUpAppears.play();
				"mushroom":
					candeactivate = true;
					yield(get_tree().create_timer(0.2), "timeout");
					var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_MUSHROOM][Global.OP_SCENE].instance();
					inst.position = position;
					inst.exiting = true;
					inst.insided = true;
					get_parent().add_child(inst);
					$PowerUpAppears.play();
				"fireflower":
					candeactivate = true;
					yield(get_tree().create_timer(0.2), "timeout");
					var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_FIREFLOWER][Global.OP_SCENE].instance();
					inst.position = position;
					inst.exiting = true;
					inst.insided = true;
					if (objectAttribute == "mushroom"):
						inst.mushroom = true;
					get_parent().add_child(inst);
					$PowerUpAppears.play()
				"goomba":
					candeactivate = true;
					yield(get_tree().create_timer(0.2), "timeout");
					var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_GOOMBA][Global.OP_SCENE].instance();
					inst.position = position;
					inst.position.y -= 52;
					inst.exiting = true;
					inst.insided = true;
					get_parent().add_child(inst);
					$PowerUpAppears.play();
				"koopatroopa":
					candeactivate = true;
					yield(get_tree().create_timer(0.2), "timeout");
					var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_KOOPATROOPA][Global.OP_SCENE].instance();
					inst.position = position;
					inst.position.y -= 52;
					inst.exiting = true;
					inst.insided = true;
					get_parent().add_child(inst);
					$PowerUpAppears.play();
				"spiny":
					candeactivate = true;
					yield(get_tree().create_timer(0.2), "timeout");
					var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_SPINY][Global.OP_SCENE].instance();
					inst.position = position;
					inst.position.y -= 52;
					inst.exiting = true;
					inst.insided = true;
					if (objectAttribute == "alreadydead"):
						inst.alreadydead = true;
					get_parent().add_child(inst);
					$PowerUpAppears.play();
				"piranhaplant":
					candeactivate = true;
					yield(get_tree().create_timer(0.2), "timeout");
					var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_PIRANHAPLANT][Global.OP_SCENE].instance();
					inst.position = position;
					inst.position.y -= 52;
					inst.exiting = true;
					inst.insided = true;
					get_parent().add_child(inst);
					$PowerUpAppears.play();
				"withp":
					candeactivate = true;
					yield(get_tree().create_timer(0.2), "timeout");
					var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_P][Global.OP_SCENE].instance();
					inst.position = position;
					inst.exiting = true;
					inst.insided = true;
					get_parent().add_child(inst);
					$PowerUpAppears.play();
				"piranhaplantfire":
					candeactivate = true;
					yield(get_tree().create_timer(0.2), "timeout");
					var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_PIRANHAPLANT_FIRE][Global.OP_SCENE].instance();
					inst.position = position;
					inst.position.y -= 52;
					inst.exiting = true;
					inst.insided = true;
					get_parent().add_child(inst);
					$PowerUpAppears.play();
				"goombrat":
					candeactivate = true;
					yield(get_tree().create_timer(0.2), "timeout");
					var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_GOOMBRAT][Global.OP_SCENE].instance();
					inst.position = position;
					inst.position.y -= 52;
					inst.exiting = true;
					inst.insided = true;
					get_parent().add_child(inst);
					$PowerUpAppears.play();
				"drybones":
					candeactivate = true;
					yield(get_tree().create_timer(0.2), "timeout");
					var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_DRYBONES][Global.OP_SCENE].instance();
					inst.position = position;
					inst.position.y -= 52;
					inst.exiting = true;
					inst.insided = true;
					get_parent().add_child(inst);
					if (objectAttribute == "alreadydead"):
						inst.alreadydead = true;
					$PowerUpAppears.play();
				_:
					if (get_node("../Character").currentPowerup != "small" || shell):
						var inst = get_parent().partBrickBreak[Global.CurrentAppeareance].instance();
						inst.flip = false;
						inst.position = position;
						get_parent().add_child(inst);
						inst = get_parent().partBrickBreak[Global.CurrentAppeareance].instance();
						inst.flip = false;
						inst.position = position;
						get_parent().add_child(inst);
						inst = get_parent().partBrickBreak[Global.CurrentAppeareance].instance();
						inst.flip = true;
						inst.position = position;
						get_parent().add_child(inst);
						inst = get_parent().partBrickBreak[Global.CurrentAppeareance].instance();
						inst.flip = true;
						inst.position = position;
						get_parent().add_child(inst);
						hide();
						$CollisionShape2D.disabled = true;
						$BrickBreak.play();

func _on_CoinInsideTimer_timeout():
	candeactivate = true;

func _on_AnimationPlayer_animation_finished(anim_name):
	if (candeactivate && anim_name == "hit"):
		deactivated = true;
		currentSprite.hide();
		var inst = get_parent().emptyBlock[Global.CurrentAppeareance].instance();
		inst.position = position;
		get_parent().add_child(inst);
		myEmptyBlock = inst;
