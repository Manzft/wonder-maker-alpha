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

var p = false;
var powner = false;

func _ready():
	styleChanged();
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");
	$VisibilityEnabler2D.emit_signal("screen_exited")

func _process(_delta):
	var delete = false;
	if (get_parent().calculateGrid(position.x, position.y).x <= 6):
		if (get_parent().calculateGrid(position.x, position.y).y >= get_node("../LevelFloor").current_grid.y):
			delete = true;
	if (get_parent().calculateGrid(position.x, position.y).x >= get_node("../EndFloor").current_grid.x):
		if (get_parent().calculateGrid(position.x, position.y).y >= get_node("../EndFloor").current_grid.y):
			delete = true;
	
	if (delete):
		get_parent().eraseObject(position);
	
	if (insided):
		if (get_node("../Editor").playing):
			$HasObjectInside.hide();
		else:
			$HasObjectInside.show();
			
	if (!get_node("../Editor").playing):
		if (!visible):
			show();
			$CollisionShape2D.disabled = false;
		myUpCoinDone = false;
		candeactivate = false;
		$CoinInsideTimer.stop();
		if (deactivated):
			myEmptyBlock.queue_free();
			styleChanged();
			deactivated = false;
		if (p):
			queue_free();
		if (powner):
			powner = false;
	else:
		if (powner):
			$CollisionShape2D.disabled = true;
		elif (visible):
			$CollisionShape2D.disabled = false;
	
	Global.rendering(self);

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
		"Snow":
			currentSprite.hide();
			currentSprite = get_node("SpriteSnow");
			currentSprite.show();
		_:
			currentSprite.hide();
			currentSprite = get_node("SpriteGround");
			currentSprite.show();

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
			if (p):
				var gr = get_parent().calculateGrid(position.x, position.y);
				get_parent().grid_node[gr.x][gr.y].powner = false;
			
			if (coinInside):
				var inst = get_parent().gotCoin[Global.CurrentAppeareance].instance();
				inst.position = position;
				get_parent().add_child(inst);
				
				if ($CoinInsideTimer.is_stopped()):
					$CoinInsideTimer.start();
			elif (oneup):
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
				if (a_alreadydead):
					inst.alreadydead = true;
				get_parent().add_child(inst);
				
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
				
				$PowerUpAppears.play();
			elif (get_node("../Character").currentPowerup != "small" || shell):
				
				var inst = get_parent().partBrickBreak[Global.CurrentAppeareance].instance();
				inst.direction.x *= 1;
				inst.position = position;
				get_parent().add_child(inst);
				inst = get_parent().partBrickBreak[Global.CurrentAppeareance].instance();
				inst.direction.x *= 1;
				inst.position = position;
				get_parent().add_child(inst);
				
				inst = get_parent().partBrickBreak[Global.CurrentAppeareance].instance();
				inst.direction.x *= -1;
				inst.position = position;
				get_parent().add_child(inst);
				inst = get_parent().partBrickBreak[Global.CurrentAppeareance].instance();
				inst.direction.x *= -1;
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
