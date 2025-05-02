extends KinematicBody2D

const acceleration = 10;
const max_walk_speed = 300;
const max_run_speed = 550;
#const jump_h  = -1000;
const jump_h = -600;
const gravity = 50;
const max_fall = 1000;

var running = false;
var jumping = false;
var koyoteTime = false;
var sneaking = false;
var falling = true;

var died = false;
var deadwait = false;

var course_clear = false;
var in_flag_pole = false;

var obligatorysneak = false;

var invincible = true;

var changingPowerup = false;

var saveCurrentAnimation = "";

var donuts = 0;
var clouds = 0;

var p = false;
var onoff = false;
var onoff2 = false;

onready var rcd1 = get_node("UpArea/RayCast2D");
onready var rcd2 = get_node("UpArea/RayCast2D2");
onready var rcd3 = get_node("UpArea/RayCast2D3");
onready var rcd4 = get_node("UpArea/RayCast2D4");
onready var rcd5 = get_node("UpArea/RayCast2D5");

var singlegridcheck = false;

var motion = Vector2();

var canAttack = true;
var attacking = false;
var attacks = 0;

var star = false;

onready var current_sprite = get_node("Mario");

var currentPowerup = "small";
var lastCurrentPowerup = currentPowerup;
var currentChangingPowerup = "";
var CPTTSwitch = false;
var savedMotion = Vector2(0, 0);

var canMove = false;

var changingPowerupHit = false

var drifting = false;

var lastScore = 0;

var currentRTFLevel = 0;
var RTFIncrease = 0.0;
var RTFDecrease = 0.0;
var RTFCanDecrease = false;

var carrying = false;
var kicking = false;

var shadow : AnimatedSprite;

var jump_timer: float = 0.0;
var max_jump_timer_def: float = 0.3;
var max_jump_timer: float = max_jump_timer_def;

var koyoteFalling = false;
var startedJumping = false;

var enteringPipe : bool = false
var exitingPipe : bool = false
var enteringPipeDirection : String = ""
var exitingPipeDirection : String = ""
var exitPipePosition : Vector2 = Vector2(0, 0)
var enterPipePosition : Vector2 = Vector2(0, 0)
var canEnterPipe: bool = true
var recentlyPipeExited: bool = false
var lastPipeNode: Node

func eraseShadow():
	shadow.queue_free();

func _ready():
	shadow = AnimatedSprite.new();
	shadow.frames = current_sprite.frames;
	shadow.animation = current_sprite.animation;
	shadow.scale = current_sprite.scale;
	get_node("../ViewportShadow/Shadows").add_child(shadow);
	
	yield(get_tree(), "idle_frame");
	
	if (get_parent().editing):
		$AnimationPlayer.play("invincible");
		invincible = true;
		$InvincibleTimer.start();
	else:
		invincible = false;
	
	if (get_parent().startmenu || Global.coursePlaying):
		if (Global.coursePlaying && Global.CheckpointGrid != Vector2(0, 0)):
			position = get_parent().calculateGridPosition(Global.CheckpointGrid);
		else:
			defaultPowerup();
		
		yield(get_tree().create_timer(0.5), "timeout");
		canMove = true;
	else:
		canMove = true;
		defaultPowerup();

func defaultPowerup():
	if (Global.CurrentDefaultPowerup != "small"):
		currentChangingPowerup = Global.CurrentDefaultPowerup;
		changingPowerup = true;
		_on_ChangingPowerup_timeout();
	if (Global.CurrentStar == "true"):
		powerup("Star");

func _physics_process(delta):
	if (!canMove):
		return;
	#Head Hit Raycasts
	if (rcd1.is_colliding()): upAreaCollide(rcd1);
	elif (rcd2.is_colliding()): upAreaCollide(rcd2);
	elif (rcd3.is_colliding()): upAreaCollide(rcd3);
	elif (rcd4.is_colliding()): upAreaCollide(rcd4);
	elif (rcd5.is_colliding()): upAreaCollide(rcd5);
	
	#Move Raycast Positions
	if (!$SmallCollision.disabled): $UpArea.position.y = 7;
	if (!$SneakCollision.disabled): $UpArea.position.y = 17;
	if (!$MushCollision.disabled): $UpArea.position.y = -42;
	
	#Gravity
	if (!deadwait && !changingPowerup && !enteringPipe && !exitingPipe && enteringPipeDirection == ""):
		motion.y += gravity
	var friction = false;
	
	if (motion.y > max_fall):
		motion.y = max_fall;
	
	#Walk Animation Speed Controller
	var max_speed = 0;
	
	#In Flag Pole
	if (in_flag_pole):
		pass
	
	#Out Flag Pole
	if (course_clear && !in_flag_pole):
		motion.x = max_walk_speed;
	
	#Start Menu Check
	var startmenucheck = true;
	if (get_parent().startmenu):
		if (!get_node("../../StartMenu/StartButton").visible):
			startmenucheck = false;
	
	if (!died && !in_flag_pole && !changingPowerup && !enteringPipe && !exitingPipe && enteringPipeDirection == ""):
		#Fireflower attack
		if (Input.is_action_just_pressed("y") || Input.is_action_just_pressed("x")):
			if (currentPowerup == "fireflower" && !attacking && canAttack && !sneaking):
				if (attacks <= 3):
					attacks += 1;
					attacking = true;
					drifting = false;
					$AttackingTimer.start();
					current_sprite.play(currentPowerup+"_attack");
					
					$Fireball.play();
					
					#Generate Fireball
					var inst = get_parent().fireball[Global.CurrentAppeareance].instance();
					inst.position = position;
					inst.position.y -= 32;
					get_parent().add_child(inst);
					if (current_sprite.flip_h):
						inst.direction = "left";
						inst.position.x -= 26;
					else:
						inst.direction = "right";
						inst.position.x += 26;
					
					if (attacks == 1):
						$BigAttackingTimer.start();
					if (attacks == 3):
						attacks = 0;
						canAttack = false;
		
		#Max Speed and Run Animation
		if (star && running):
			max_speed = max_run_speed*1.25;
			var checkanim = (current_sprite.animation == currentPowerup+"_walk" ||
			current_sprite.animation == currentPowerup+"_run" ||
			current_sprite.animation == currentPowerup+"_carry_item_walk");
			if (checkanim && abs(motion.x) > max_walk_speed):
				current_sprite.speed_scale = abs(motion.x)/(max_walk_speed*1.25);
			else:
				current_sprite.speed_scale = 1;
		elif (star && !running):
			current_sprite.speed_scale = 1.25;
			max_speed = max_walk_speed*1.25;
		elif (running):
			max_speed = max_run_speed;
			var checkanim = (current_sprite.animation == currentPowerup+"_walk" ||
			current_sprite.animation == currentPowerup+"_run" ||
			current_sprite.animation == currentPowerup+"_carry_item_walk");
			if (checkanim && abs(motion.x) > max_walk_speed):
				current_sprite.speed_scale = abs(motion.x)/max_walk_speed;
			else:
				current_sprite.speed_scale = 1;
		else:
			current_sprite.speed_scale = 1;
			max_speed = max_walk_speed;
		
		#Sprint Controller
		if (Input.is_action_pressed("y") || Input.is_action_pressed("x") || get_node("../Editor").automaticSprint):
			running = true;
		else:
			running = false;
		
		#Jump Animation Controller
		if (!is_on_floor() && !attacking):
			if (carrying):
				if (current_sprite.animation != currentPowerup+"_carry_item_jump"):
					if (!sneaking):
						current_sprite.play(currentPowerup+"_carry_item_jump");
			elif (currentRTFLevel == 7):
				if (current_sprite.animation != currentPowerup+"_run_jump"):
					if (!sneaking):
						current_sprite.play(currentPowerup+"_run_jump");
			elif (star):
				if (currentPowerup == "small"):
					if (falling || jumping):
						if (!sneaking):
							current_sprite.play(currentPowerup+"_jump");
						else:
							pass
				else:
					if (jumping):
						if (!sneaking):
							current_sprite.play(currentPowerup+"_star_jump");
						else:
							pass
					if (falling):
						if (!sneaking):
							current_sprite.play(currentPowerup+"_fall");
						else:
							pass
			else:
				if (currentPowerup == "small" || motion.y <= 0):
					if (current_sprite.animation != currentPowerup+"_jump"):
						if (falling || jumping):
							if (!sneaking):
								current_sprite.play(currentPowerup+"_jump");
							else:
								pass
				else:
					if (current_sprite.animation != currentPowerup+"_fall"):
						if (!sneaking):
							current_sprite.play(currentPowerup+"_fall");
						else:
							pass
				
			if (!koyoteFalling && motion.y >= 0 && !startedJumping):
				koyoteTime = true;
				$KoyoteTimer.start();
				koyoteFalling = true;
			if (!falling && motion.y >= 0 && !startedJumping):
				falling = true;
		elif (is_on_floor()):
			jumping = false;
			koyoteTime = false;
			koyoteFalling = false;
			falling = false;
			singlegridcheck = false;
			lastScore = 0;
			startedJumping = false;
		
		#Movement Controller
		if (drifting && is_on_floor()):
			current_sprite.play(currentPowerup+"_drift");
			if (!$SoundDrift.playing):
				$SoundDrift.play();
		else:
			if ($SoundDrift.playing):
				$SoundDrift.stop();
		
		var inpchckr = Input.is_action_pressed("right") || Input.is_action_pressed("dright");
		var inpchckl = Input.is_action_pressed("left") || Input.is_action_pressed("dleft");
		var sneakchck = !sneaking || !is_on_floor();
		if (inpchckr && sneakchck && !course_clear && startmenucheck):
			var acc = acceleration * 2.5;
			if (is_on_floor() && !attacking):
				if (current_sprite.flip_h):
					current_sprite.flip_h = false;
					drifting = false;
			
				if (motion.x < 0 && abs(motion.x) > max_run_speed*0.9 && !carrying):
					drifting = true;
				
				if (motion.x > 0 && drifting):
					drifting = false;
				
				if (carrying):
					current_sprite.play(currentPowerup+"_carry_item_walk");
				elif (!drifting):
					if (currentRTFLevel == 7):
						current_sprite.play(currentPowerup+"_run");
					else:
						current_sprite.play(currentPowerup+"_walk");
				
				var chck1 = motion.x > 0 && !current_sprite.flip_h
				var chck2 = motion.x < 0 && current_sprite.flip_h;
				var chckfinal = (chck1 || chck2);
				if (chckfinal):
					acc = acceleration;
				else:
					acc = acceleration * 2;
			else:
				if (current_sprite.flip_h):
					current_sprite.flip_h = false;
			if (motion.x < max_speed):
				if (is_on_floor()):
					motion.x += acc;
				else:
					motion.x += acc/2;
			else:
				motion.x -= acc/2;
		elif (inpchckl && sneakchck && !course_clear && startmenucheck):
			var acc = acceleration * 2.5;
			if (is_on_floor() && !attacking):
				if (!current_sprite.flip_h):
					current_sprite.flip_h = true;
					drifting = false;
				
				if (motion.x > 0 && abs(motion.x) > max_run_speed*0.9 && !carrying):
					drifting = true;
					
				if (motion.x < 0 && drifting):
					drifting = false;
					
				var chck1 = motion.x > 0 && !current_sprite.flip_h
				var chck2 = motion.x < 0 && current_sprite.flip_h;
				var chckfinal = (chck1 || chck2);
				if (chckfinal):
					acc = acceleration;
				else:
					acc = acceleration * 2;
				
				if (carrying):
					current_sprite.play(currentPowerup+"_carry_item_walk");
				elif (!drifting):
					if (currentRTFLevel == 7):
						current_sprite.play(currentPowerup+"_run");
					else:
						current_sprite.play(currentPowerup+"_walk");
			else:
				if (!current_sprite.flip_h):
					current_sprite.flip_h = true;
			if (motion.x > -max_speed):
				if (is_on_floor()):
					motion.x -= acc;
				else:
					motion.x -= acc/2;
			else:
				motion.x += acc/2;
		else:
			friction = true;
			if (is_on_floor() && !attacking):
				if (!sneaking && !drifting):
					if (round(abs(motion.x)) > 0):
						if (carrying):
							current_sprite.play(currentPowerup+"_carry_item_walk");
						else:
							current_sprite.play(currentPowerup+"_walk");
					else:
						if (carrying):
							current_sprite.play(currentPowerup+"_carry_item_idle");
						else:
							current_sprite.play(currentPowerup+"_idle");
				if (abs(motion.x) <= max_walk_speed*0.1):
					motion.x = 0;
				if (abs(motion.x) <= max_walk_speed*0.4):
					drifting = false;
			if (inpchckr && !course_clear):
				if (current_sprite.flip_h):
					current_sprite.flip_h = false;
			if (inpchckl && !course_clear):
				if (!current_sprite.flip_h):
					current_sprite.flip_h = true;
					
		
		#Ready To Fly System
		if (is_on_floor() && abs(motion.x) >= max_run_speed*0.8):
			if ($RTFDecreaseTimer.is_stopped()):
				$RTFDecreaseTimer.stop();
			RTFCanDecrease = false;
			
			RTFDecrease = 0.0;
			RTFIncrease += delta;
			if (RTFIncrease >= 0.125):
				RTFIncrease = 0.0;
				if (currentRTFLevel < 7):
					currentRTFLevel += 1;
		elif (RTFCanDecrease && abs(motion.x) < max_run_speed*0.8):
			RTFIncrease = 0.0;
			RTFDecrease += delta;
			if (RTFDecrease >= 0.2):
				RTFDecrease = 0.0;
				if (currentRTFLevel > 0):
					currentRTFLevel -= 1;
		
		if (abs(motion.x) < max_run_speed*0.8):
			if ($RTFDecreaseTimer.is_stopped() && !RTFCanDecrease):
				$RTFDecreaseTimer.start();
		
		if (currentRTFLevel == 7):
			if (!$SoundReadytofly.playing):
				$SoundReadytofly.play();
		else:
			if ($SoundReadytofly.playing):
				$SoundReadytofly.stop();
		
		#Jump and friction controller
		if (is_on_floor() || koyoteTime):
			if (!course_clear && startmenucheck && !falling):
				if (Input.is_action_just_pressed("a") || Input.is_action_just_pressed("b")):
					if (!sneaking && !attacking):
						current_sprite.play(currentPowerup+"_jump");
					jumping = true;
					if (!$SoundJump.playing):
						$SoundJump.play();
					koyoteTime = false;
					drifting = false;
					jumping = true;
					jump_timer = 0.0;
					if (abs(motion.x) >= max_run_speed*0.9):
						max_jump_timer = max_jump_timer_def*1.25;
					else:
						max_jump_timer = max_jump_timer_def;
					motion.y = jump_h;
					detectSingleGrid();
					startedJumping = true;
			if (friction):
				motion.x = lerp(motion.x, 0.0, 0.0625);
		else:
			if (friction):
				motion.x = lerp(motion.x, 0.0, 0.02);
		var a = Input.is_action_pressed("a") || Input.is_action_pressed("b");
		if (jumping && jump_timer < max_jump_timer && a && motion.y < 0):
			motion.y = jump_h;
			jump_timer += delta;
		else:
			jumping = false;
		
#		if (Input.is_action_just_released("a") || Input.is_action_just_released("b")):
#			if (jumping && motion.y < jump_h*0.35 && !is_on_floor() && !course_clear && startmenucheck):
#				motion.y = jump_h*0.35
#				if (!sneaking):
#					current_sprite.play(currentPowerup+"_jump");
				
		#Sneak Controller
		if (Input.is_action_pressed("down") || Input.is_action_pressed("ddown")):
			if (is_on_floor() && !course_clear && startmenucheck && !sneaking):
				sneak();
		
		if (Input.is_action_just_released("down") || Input.is_action_just_released("ddown")):
			if (sneaking && !course_clear && startmenucheck && !obligatorysneak):
				releaseSneak();
		
		#Obligatory Sneak Controller
		if ($ObligatorySneakRaycast.is_colliding()):
			if (currentPowerup != "small"):
				var body = $ObligatorySneakRaycast.get_collider();
				if (body.is_in_group("Solid") && !body.is_in_group("Hurt")):
					obligatorysneak = true;
					if (!sneaking):
						sneak();
				else:
					obligatorysneak = false;
					if (sneaking) && !(Input.is_action_pressed("down") || Input.is_action_pressed("ddown")):
						releaseSneak();
			else:
				obligatorysneak = false;
				if (sneaking) && !(Input.is_action_pressed("down") || Input.is_action_pressed("ddown")):
					releaseSneak();
		else:
			if (sneaking && obligatorysneak) && !(Input.is_action_pressed("down") || Input.is_action_pressed("ddown")):
				releaseSneak();
				obligatorysneak = false;
				
		#Kicking Animation
		if (kicking):
			current_sprite.play(currentPowerup+"_kick");
		
		#Debug
		#if (Input.is_action_just_pressed("r")):
		#	if (!died): die();
		
	#Global Movement Controller
	if (!enteringPipe && !exitingPipe && enteringPipeDirection == ""):
		motion = move_and_slide(motion, Vector2(0, -1));

func sneak():
	if (!carrying):
		kicking = false;
		sneaking = true;
		drifting = false;
		current_sprite.play(currentPowerup+"_crouch");
		if (currentPowerup == "small"):
			$SmallCollision.disabled = true;
			$SneakCollision.disabled = false;
		else:
			$MushCollision.disabled = true;
			$SmallCollision.disabled = false;

func releaseSneak():
	sneaking = false;
	if (currentPowerup == "small"):
		$SmallCollision.disabled = false;
		$SneakCollision.disabled = true;
	else:
		$MushCollision.disabled = false;
		$SmallCollision.disabled = true;
	if (is_on_floor()):
		current_sprite.play(currentPowerup+"_idle");

func die():
	if (died): return
	
	pause_mode = PAUSE_MODE_PROCESS; get_tree().paused = true;
	$SoundPButton.stop();
	carrying = false;
	motion.x = 0;
	motion.y = 0;
	current_sprite.offset.y = 0;
	deadwait = true;
	get_parent().gameMusic(false);
	died = true;
	current_sprite.play("small_dead");
	
	currentRTFLevel = 0;
	if ($SoundReadytofly.playing):
		$SoundReadytofly.stop();
	if ($SoundDrift.playing):
		$SoundDrift.stop();
	
	$SoundDead.play();
	
	star = false;
	$AnimationPlayer.play("RESET");
	$Light2D.enabled = false;
	$SoundStar.stop();
	
	#Online Dead Signal
	if (Global.coursePlaying):
		var inst = load("res://scenes/appearances/OnlineDeath.tscn").instance();
		get_parent().add_child(inst);
		inst.position = position;
	
	yield(get_tree().create_timer(0.8), "timeout");
	
	current_sprite.play("small_dead");
	$DeadTimer.start();
	deadwait = false;
	$SmallCollision.disabled = true;
	$SneakCollision.disabled = true;
	$MushCollision.disabled = true;
	motion.y = -1000;

func _process(delta):
	#Shadow Animation Sync Controller
	shadow.position = current_sprite.global_position+Vector2(3*3.25, 3*3.25);
	shadow.animation = current_sprite.animation;
	shadow.frame = current_sprite.frame;
	shadow.scale = current_sprite.scale;
	shadow.offset = current_sprite.offset;
	shadow.flip_h = current_sprite.flip_h;
	shadow.flip_v = current_sprite.flip_v;
	shadow.visible = visible
	
	if (Global.playing):
		Global.charpos = position;
	#Shadow Animation Sync Controller
	
	#Fall Dead
	if (position.y >= 1600 && !course_clear):
		position.y = 1600;
		
		if (donuts > 0):
			donuts = 0;
			var nodes = get_tree().get_nodes_in_group("Donut");
			for node in nodes:
				if (node.moveCharacter):
					node.moveCharacter = false;
		
		if (!died):
			die();
			
	var moveSpeed = 50*delta
	if (enteringPipe):
		match (enteringPipeDirection):
			"up":
				current_sprite.offset.y += moveSpeed
				position.x = lerp(position.x, enterPipePosition.x+26, 12*delta)
			"down":
				current_sprite.offset.y -= moveSpeed
				position.x = lerp(position.x, enterPipePosition.x+26, 12*delta)
			"left":
				current_sprite.offset.x += moveSpeed
				position.y = lerp(position.y, enterPipePosition.y+26+18, 12*delta)
			"right":
				current_sprite.offset.x -= moveSpeed
				position.y = lerp(position.y, enterPipePosition.y+26+18, 12*delta)
	
	if (exitingPipe):
		var yoffset = 0
		var xoffset = 0
		if (currentPowerup != "small"):
			yoffset = -8
		
		match (exitingPipeDirection):
			"up":
				current_sprite.offset.y -= moveSpeed
				if (current_sprite.offset.y < yoffset):
					current_sprite.offset.y = yoffset
			"down":
				current_sprite.offset.y += moveSpeed*0.8
				if (current_sprite.offset.y > yoffset):
					current_sprite.offset.y = yoffset
			"left":
				current_sprite.offset.x -= moveSpeed*0.7
				if (current_sprite.offset.x < xoffset):
					current_sprite.offset.x = xoffset
			"right":
				current_sprite.offset.x += moveSpeed*0.7
				if (current_sprite.offset.x > xoffset):
					current_sprite.offset.x = xoffset
	
	#Wall Dead
	if (!died && position.y < get_parent().calculateGridPosition(Vector2(0, get_parent().grid_size.y-1)).y):
		var mygrid = get_parent().calculateGrid(position.x, position.y)
		var node = get_parent().grid_node[mygrid.x][mygrid.y]
		checkWallDead(node, mygrid)
		if (currentPowerup != "small"):
			mygrid = get_parent().calculateGrid(position.x, position.y-52)
			checkWallDead(node, mygrid)

func checkWallDead(node: Node, mygrid: Vector2):
	if (node != null):
		if (!node.is_in_group("OffBlock2") &&
		!node.is_in_group("OnBlock2") &&
		!node.is_in_group("OffBlock") &&
		!node.is_in_group("OnBlock") &&
		node.is_in_group("Solid") &&
		!node.get_node("CollisionShape2D").disabled &&
		node.position == get_parent().calculateGridPosition(mygrid)):
			if (exitingPipe):
				hide()
			if (canEnterPipe):
				if (!recentlyPipeExited):
					die();
				else:
					enterPipe(lastPipeNode.seldirection, lastPipeNode, lastPipeNode.pipe_code)

func _on_KoyoteTimer_timeout():
	koyoteTime = false;

func _on_DeadTimer_timeout():
	if (!get_parent().startmenu):
		get_node("../Editor")._on_Edit_pressed();

func upAreaCollide(var rc):
	var body = rc.get_collider();
	var canhit = false;
	#print(motion.y);
	if (body.is_in_group("Brick") || body.is_in_group("Luckyblock") || body.is_in_group("OnOffSwitch") || body.is_in_group("OnOffSwitch2")):
		if (singlegridcheck && currentPowerup == "small"):
			if (!is_on_floor()):
				canhit = true;
				motion.y = max_fall/4;
		else:
			if (motion.y <= 0 && !is_on_floor()):
				canhit = true;
	
	if (canhit && !died):
		if (body.get_name() == "SubCollider"):
			body.get_parent().hit();
			if (!$SoundBrick.playing):
				$SoundBrick.play();
				#$SoundJump.stop();
		else:
			body.hit();
			
			if (body.is_in_group("OnOffSwitch") || body.is_in_group("OnOffSwitch2")):
				$SoundOnOffSwitch.play();
			else:
				$SoundBrick.play();
			$SoundJump.stop();
		motion.y = 0;

func detectSingleGrid():
	var mygrid = get_parent().calculateGrid(position.x, position.y);
	if (currentPowerup != "small"):
		mygrid = get_parent().calculateGrid(position.x, position.y+26);
	var upgrid = get_parent().grid[mygrid.x][mygrid.y-1];
	if (upgrid == Global.OBJ_BRICK || upgrid == Global.OBJ_LUCKYBLOCK || upgrid == Global.OBJ_INVISIBLE_LUCKYBLOCK):
		singlegridcheck = true;

func hit():
	if (!died && !course_clear && !in_flag_pole):
		if (currentPowerup == "fireflower"):
			lastCurrentPowerup = currentPowerup;
			currentChangingPowerup = "mush";
			$PowerupOut.play();
			changingPowerup = true;
			$ChangingPowerupTimer.start();
			$ChangingPowerupTransitionTimer.start();
			savedMotion = motion;
			motion = Vector2(0.0, 0.0);
			changingPowerupHit = true;
			
			pause_mode = PAUSE_MODE_PROCESS; get_tree().paused = true;
		elif (currentPowerup != "small"):
			lastCurrentPowerup = currentPowerup;
			currentChangingPowerup = "small";
			$PowerupOut.play();
			changingPowerup = true;
			$ChangingPowerupTimer.start();
			$ChangingPowerupTransitionTimer.start();
			savedMotion = motion;
			motion = Vector2(0.0, 0.0);
			changingPowerupHit = true;
			
			pause_mode = PAUSE_MODE_PROCESS; get_tree().paused = true;
		else:
			die();

func powerup(pw, changingpowerup = false):
	if (currentPowerup != pw && !died):
		match (pw):
			"Star":
				yield(get_tree(), "idle_frame");
				yield(get_tree(), "idle_frame");
				yield(get_tree(), "idle_frame");
				get_parent().gameMusic(false);
				$SoundStar.play();
				star = true;
				$AnimationPlayer.play("star");
				$Light2D.enabled = true;
			"Mushroom":
				if (currentPowerup == "small"):
					lastCurrentPowerup = currentPowerup;
					#currentPowerup = "mush";
					currentChangingPowerup = "mush";
					changingPowerup = true;
					$ChangingPowerupTimer.start();
					_on_ChangingPowerupTransitionTimer_timeout();
					savedMotion = motion;
					motion = Vector2(0.0, 0.0);
					
					pause_mode = PAUSE_MODE_PROCESS; get_tree().paused = true;
			"Fireflower":
				if (currentPowerup != "fireflower"):
					lastCurrentPowerup = currentPowerup;
					#currentPowerup = "fireflower";
					currentChangingPowerup = "fireflower";
					changingPowerup = true;
					$ChangingPowerupTimer.start();
					_on_ChangingPowerupTransitionTimer_timeout();
					savedMotion = motion;
					motion = Vector2(0.0, 0.0);
					
					pause_mode = PAUSE_MODE_PROCESS; get_tree().paused = true;

func _on_SoundStar_finished():
	if (!in_flag_pole && !died && !course_clear):
		get_parent().gameMusic(true);
		star = false;
		$AnimationPlayer.play("RESET");
		$Light2D.enabled = false;

func _on_InvincibleTimer_timeout():
	invincible = false;
	if (!star):
		$AnimationPlayer.play("RESET");

func _on_ChangingPowerup_timeout():
	changingPowerup = false;
	motion = savedMotion;
	
	if (sneaking):
		releaseSneak();
	
	falling = false;
	jumping = true;
	currentPowerup = currentChangingPowerup;
	if (currentPowerup == "small"):
		current_sprite.offset.y = 0;
	else:
		current_sprite.offset.y = -8;
	
	get_tree().paused = false;
	pause_mode = PAUSE_MODE_INHERIT;
		
	match (currentPowerup):
		"small":
			$SmallCollision.disabled = false;
			$SneakCollision.disabled = true;
			$MushCollision.disabled = true;
		"mush":
			$SmallCollision.disabled = true;
			$SneakCollision.disabled = true;
			$MushCollision.disabled = false;
		"fireflower":
			$SmallCollision.disabled = true;
			$SneakCollision.disabled = true;
			$MushCollision.disabled = false;
	
	if (changingPowerupHit):
		$AnimationPlayer.play("invincible");
		invincible = true;
		$InvincibleTimer.start();
	changingPowerupHit = false;

func _on_ChangingPowerupTransitionTimer_timeout():
	#Animation Transition
	if (changingPowerup):
		if (!CPTTSwitch):
			current_sprite.play(currentPowerup+"_jump");
			CPTTSwitch = true;
			
			if (currentPowerup == "small"):
				current_sprite.offset.y = 0;
			else:
				current_sprite.offset.y = -8;
		else:
			current_sprite.play(currentChangingPowerup+"_jump");
			CPTTSwitch = false;
			
			if (currentChangingPowerup == "small"):
				current_sprite.offset.y = 0;
			else:
				current_sprite.offset.y = -8;
		
		$ChangingPowerupTransitionTimer.start();

func _on_BigAttackingTimer_timeout():
	canAttack = true;
	attacks = 0;
	
func _on_AttackingTimer_timeout():
	attacking = false;

func _on_SoundPButton_finished():
	if (died):
		return
	if (!in_flag_pole):
		get_parent().gameMusic(true);
	p = false;
	var nodes = get_tree().get_nodes_in_group("P");
	for node in nodes:
		if (node.currentSprite.animation == "pressed"):
			node.release();

func _on_RTFDecreaseTimer_timeout():
	RTFCanDecrease = true;

func _on_KickingTimer_timeout():
	kicking = false;

func _on_Character_tree_exiting():
	eraseShadow();

func enterPipe(direction : String, pipeNode : Node, code : int):
	if (enteringPipe || died || changingPowerup || !canEnterPipe):
		return
	if (sneaking):
		releaseSneak()
	
	canEnterPipe = false
	
	for node in get_tree().get_nodes_in_group("Pipe"):
		if (node != pipeNode):
			if (node.pipe_code == code):
				pause_mode = PAUSE_MODE_PROCESS; get_tree().paused = true;
				enteringPipe = true
				$SoundEnterPipe.play()
				#$AnimationPlayer.play("enter_pipe")
				z_index = -1
				lastPipeNode = node
				enterPipePosition = pipeNode.position
				match (direction):
					"up":
						#position.x = pipeNode.position.x+26
						current_sprite.play(currentPowerup+"_pipe");
					"left":
						#position.y = pipeNode.position.y+26+18
						current_sprite.play(currentPowerup+"_walk");
						if (currentPowerup != "small"):
							current_sprite.scale.y = (3.25)*0.85
					"right":
						#position.y = pipeNode.position.y+26+18
						current_sprite.play(currentPowerup+"_walk");
						if (currentPowerup != "small"):
							current_sprite.scale.y = (3.25)*0.85
					"down":
						#position.x = pipeNode.position.x+26
						current_sprite.play(currentPowerup+"_pipe");
				$EnterPipeTimer.start()
				enteringPipeDirection = direction
				exitingPipeDirection = node.seldirection
				exitPipePosition = node.position
				motion = Vector2(0, 0)

func _on_EnterPipeTimer_timeout():
	get_parent().get_node("CircleTransition/Transition/AnimationPlayer").play("in")
	enteringPipe = false
	hide()
	match (exitingPipeDirection):
		"up":
			position.x = exitPipePosition.x+26
			position.y = exitPipePosition.y-52+1
			current_sprite.play(currentPowerup+"_pipe");
		"left":
			position.x = exitPipePosition.x-52
			position.y = exitPipePosition.y+26+18
			current_sprite.play(currentPowerup+"_walk");
			current_sprite.flip_h = true
		"right":
			position.x = exitPipePosition.x+52+52
			position.y = exitPipePosition.y+26+18
			current_sprite.play(currentPowerup+"_walk");
			current_sprite.flip_h = false
		"down":
			position.x = exitPipePosition.x+26
			position.y = exitPipePosition.y+52+52
			if (currentPowerup != "small"):
				position.y += 52
			current_sprite.play(currentPowerup+"_pipe");
	$ExitPipeTimer.start()
	get_tree().paused = false; pause_mode = PAUSE_MODE_INHERIT;

func _on_ExitPipeTimer_timeout():
	current_sprite.scale.y = 3.25
	match (exitingPipeDirection):
		"up":
			current_sprite.offset = Vector2(0, 32);
		"left":
			current_sprite.offset = Vector2(25, 0);
			if (currentPowerup != "small"):
				current_sprite.scale.y = (3.25)*0.85
		"right":
			current_sprite.offset = Vector2(-25, 0);
			if (currentPowerup != "small"):
				current_sprite.scale.y = (3.25)*0.85
		"down":
			current_sprite.offset = Vector2(0, -32);
	
	if (currentPowerup != "small"):
		current_sprite.offset.y -= 8;
	
	var campos = Vector2(get_node("../Editor/GamepadCursorDefaultPosition").rect_position.x, get_node("../Editor/GamepadCursorDefaultPosition").rect_position.y);
	get_node("../Camera2D").position.x = position.x-campos.x;
	
	if (get_parent().freecam):
		get_node("../Camera2D").position.y = position.y-campos.y;
	else:
		get_node("../Camera2D").position.y = 840;
		
	if (get_node("../Camera2D").position.y < 0): get_node("../Camera2D").position.y = 0;
	if (get_node("../Camera2D").position.x < 0): get_node("../Camera2D").position.x = 0;
	if (get_node("../Camera2D").position.y > 840): get_node("../Camera2D").position.y = 840;
	var px = get_node("../EndFloor").position.x+(52*9)-26-get_node("../Editor/SectionTop").rect_size.x;
	if (get_node("../Camera2D").position.x > px): get_node("../Camera2D").position.x = px;
	
	get_parent().get_node("CircleTransition/Circle").material.set_shader_param("screen_width", get_parent().get_node("CircleTransition/Circle").rect_size.x)
	get_parent().get_node("CircleTransition/Circle").material.set_shader_param("screen_height", get_parent().get_node("CircleTransition/Circle").rect_size.y)
	get_parent().get_node("CircleTransition/Circle").material.set_shader_param("offset_x", 0.0)
	get_parent().get_node("CircleTransition/Circle").material.set_shader_param("offset_y", 0.0)
	get_parent().get_node("CircleTransition/Transition/AnimationPlayer").play("RESET")
	get_parent().get_node("CircleTransition/AnimationPlayer").play("out")
	yield(get_tree().create_timer(0.5), "timeout")
	$FinishPipeTimer.start()
	exitingPipe = true
	$SoundEnterPipe.play()
	show()

func _on_FinishPipeTimer_timeout():
	current_sprite.scale.y = 3.25
	exitingPipe = false
	enteringPipeDirection = ""
	exitingPipeDirection = ""
	z_index = 2
	current_sprite.offset.x = 0
	if (currentPowerup == "small"):
		current_sprite.offset.y = 0;
	else:
		current_sprite.offset.y = -8;
	canEnterPipe = true
	recentlyPipeExited = true
	$RecentlyPipeExitedTimer.start()

func _on_RecentlyPipeExitedTimer_timeout() -> void:
	recentlyPipeExited = false
