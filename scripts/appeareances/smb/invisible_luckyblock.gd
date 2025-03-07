extends StaticBody2D

onready var currentSprite = get_node("SpriteGround");

var coinInside = false;
var oneup = false;
var star = false;
var mushroom = false;
var fireflower = false;
var goomba = false;
var koopatroopa = false;
var koopatroopa_red = false;
var spiny = false;
var piranhaplant = false;
var withp = false;
var piranhaplantfire = false;
var goombrat = false;
var drybones = false;

var insided = false;

var a_mushroom = false;
var a_alreadydead = false;

var deactivated =  false;

var candeactivate = false;

var myEmptyBlock = null;

var myUpCoinDone = false;


func render(group):
	if (group != ""):
		if (!is_in_group(group)):
			return
	var scrwidth = OS.get_window_size().x;
	var scrheight = OS.get_window_size().y;
	var multiplier = 720/scrheight;
	var finalscrwidth = scrwidth * multiplier;
	var distance = abs(position.x-Global.campos.x);
	if (distance-(finalscrwidth/2) > finalscrwidth*0.5):
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
	var nodegrid = get_parent().calculateGrid(position.x, position.y);
	get_parent().grid[nodegrid.x][nodegrid.y] = null;
	get_parent().grid_node[nodegrid.x][nodegrid.y] = null;
	queue_free();

func changeStyle():
	var pos = position;
	var grid = get_parent().calculateGrid(pos.x, pos.y);
	var obj = get_parent().grid[grid.x][grid.y];
	var scene = Global.object[Global.CurrentAppeareance][obj][Global.OP_SCENE];
	var inst = scene.instance();
	get_parent().grid_node[grid.x][grid.y] = inst;
	get_parent().add_child(inst);
	inst.position = pos;
	
	inst.coinInside = coinInside;
	inst.oneup = oneup;
	inst.star = star;
	inst.mushroom = mushroom;
	inst.fireflower = fireflower;
	inst.goomba = goomba;
	inst.koopatroopa = koopatroopa;
	inst.koopatroopa_red = koopatroopa_red;
	inst.spiny = spiny;
	inst.piranhaplant = piranhaplant;
	inst.withp = withp;
	inst.piranhaplantfire = piranhaplantfire;
	inst.goombrat = goombrat;
	inst.drybones = drybones;

	inst.insided = insided;

	inst.a_mushroom = a_mushroom;
	inst.a_alreadydead = a_alreadydead;

	queue_free();

func _ready():
	Global.connect("render", self, "render");
	Global.connect("floorErase", self, "floorErase");
	Global.connect("changeStyle", self, "changeStyle");
	Global.connect("erase", self, "erase");
	styleChanged();
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");

func _process(_delta):
	if (get_node("../Editor").playing):
		if (currentSprite.visible):
			currentSprite.hide();
			$CollisionShape2D.disabled = true;
	else:
		if (!currentSprite.visible):
			currentSprite.show();
			$CollisionShape2D.disabled = false;
		if (!visible):
			show();
	
	if (insided):
		if (get_node("../Editor").playing):
			$HasObjectInside.hide();
		else:
			$HasObjectInside.show();
			
	if (!get_node("../Editor").playing):
		myUpCoinDone = false;
		candeactivate = false;
		$CoinInsideTimer.stop();
		if (deactivated):
			styleChanged();
			deactivated = false;

func styleChanged():
	match (Global.CurrentStyle):
		_:
			currentSprite.hide();
			currentSprite = get_node("SpriteGround");
			currentSprite.show();

func hit():
	if ($AnimationPlayer.current_animation != "hit"):
		if (!deactivated):
			$AnimationPlayer.play("hit");
			
			$CollisionShape2D.disabled = false;
			
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
								

			if (oneup):
				candeactivate = true;
				yield(get_tree().create_timer(0.2), "timeout");
				
				var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_1UP][Global.OP_SCENE].instance();
				inst.position = position;
				inst.exiting = true;
				inst.insided = true;
				get_parent().add_child(inst);
				
				$PowerUpAppears.play();
			elif (star):
				candeactivate = true;
				yield(get_tree().create_timer(0.2), "timeout");
				
				var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_STAR][Global.OP_SCENE].instance();
				inst.position = position;
				inst.exiting = true;
				inst.insided = true;
				get_parent().add_child(inst);
				
				$PowerUpAppears.play();
			elif (mushroom):
				candeactivate = true;
				yield(get_tree().create_timer(0.2), "timeout");
				
				var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_MUSHROOM][Global.OP_SCENE].instance();
				inst.position = position;
				inst.exiting = true;
				inst.insided = true;
				get_parent().add_child(inst);
				
				$PowerUpAppears.play();
			elif (fireflower):
				candeactivate = true;
				yield(get_tree().create_timer(0.2), "timeout");
				
				var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_FIREFLOWER][Global.OP_SCENE].instance();
				inst.position = position;
				inst.exiting = true;
				inst.insided = true;
				if (a_mushroom):
					inst.mushroom = true;
				get_parent().add_child(inst);
				
				$PowerUpAppears.play();
			elif (goomba):
				candeactivate = true;
				yield(get_tree().create_timer(0.2), "timeout");
				
				var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_GOOMBA][Global.OP_SCENE].instance();
				inst.position = position;
				inst.position.y -= 52;
				inst.exiting = true;
				inst.insided = true;
				get_parent().add_child(inst);
				
				$PowerUpAppears.play();
			elif (koopatroopa):
				candeactivate = true;
				yield(get_tree().create_timer(0.2), "timeout");
				
				var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_KOOPATROOPA][Global.OP_SCENE].instance();
				inst.position = position;
				inst.position.y -= 52;
				inst.exiting = true;
				inst.insided = true;
				get_parent().add_child(inst);
				
				$PowerUpAppears.play();
			elif (koopatroopa_red):
				candeactivate = true;
				yield(get_tree().create_timer(0.2), "timeout");
				
				var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_KOOPATROOPA_RED][Global.OP_SCENE].instance();
				inst.position = position;
				inst.position.y -= 52;
				inst.exiting = true;
				inst.insided = true;
				get_parent().add_child(inst);
				
				$PowerUpAppears.play();
			elif (spiny):
				candeactivate = true;
				yield(get_tree().create_timer(0.2), "timeout");
				
				var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_SPINY][Global.OP_SCENE].instance();
				inst.position = position;
				inst.position.y -= 52;
				inst.exiting = true;
				inst.insided = true;
				get_parent().add_child(inst);
				if (a_alreadydead):
					inst.alreadydead = true;
				$PowerUpAppears.play();
			elif (piranhaplant):
				candeactivate = true;
				yield(get_tree().create_timer(0.2), "timeout");
				
				var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_PIRANHAPLANT][Global.OP_SCENE].instance();
				inst.position = position;
				inst.position.y -= 52;
				inst.exiting = true;
				inst.insided = true;
				get_parent().add_child(inst);
				
				$PowerUpAppears.play();
			elif (withp):
				candeactivate = true;
				yield(get_tree().create_timer(0.2), "timeout");
				
				var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_P][Global.OP_SCENE].instance();
				inst.position = position;
				inst.exiting = true;
				inst.insided = true;
				get_parent().add_child(inst);
				
				$PowerUpAppears.play();
			elif (piranhaplantfire):
				candeactivate = true;
				yield(get_tree().create_timer(0.2), "timeout");
				
				var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_PIRANHAPLANT_FIRE][Global.OP_SCENE].instance();
				inst.position = position;
				inst.position.y -= 52;
				inst.exiting = true;
				inst.insided = true;
				get_parent().add_child(inst);
				
				$PowerUpAppears.play();
			elif (goombrat):
				candeactivate = true;
				yield(get_tree().create_timer(0.2), "timeout");
				
				var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_GOOMBRAT][Global.OP_SCENE].instance();
				inst.position = position;
				inst.position.y -= 52;
				inst.exiting = true;
				inst.insided = true;
				get_parent().add_child(inst);
				
				$PowerUpAppears.play();
			elif (drybones):
				candeactivate = true;
				yield(get_tree().create_timer(0.2), "timeout");
				
				var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_DRYBONES][Global.OP_SCENE].instance();
				inst.position = position;
				inst.position.y -= 52;
				inst.exiting = true;
				inst.insided = true;
				get_parent().add_child(inst);
				
				if (a_alreadydead):
					inst.alreadydead = true;
				
				$PowerUpAppears.play();
			else:
				var inst = get_parent().gotCoin[Global.CurrentAppeareance].instance();
				inst.position = position;
				get_parent().add_child(inst);
				candeactivate = true;

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
