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

var canSyncAnim = false;

func _ready():
	styleChanged();
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");
		canSyncAnim = true;
	$VisibilityEnabler2D.emit_signal("screen_exited")

func _process(_delta):
	$SpriteUnderground.scale = $SpriteGround.scale;
	$SpriteUnderground.position = $SpriteGround.position;
	$SpriteGhostforest.scale = $SpriteGround.scale;
	$SpriteGhostforest.position = $SpriteGround.position;
	if (get_node("../Editor").playing):
		currentSprite.speed_scale = 1;
	else:
		if (!visible):
			show();
		currentSprite.speed_scale = 0;
		currentSprite.frame = 0;
	
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

func hit():
	if ($AnimationPlayer.current_animation != "hit"):
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
