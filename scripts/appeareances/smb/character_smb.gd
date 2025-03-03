extends KinematicBody2D

const acceleration = 10;
const max_walk_speed = 300;
const max_run_speed = 550;
const jump_h  = -1000;
const gravity = 40;
const max_fall = jump_h*-1;

var running = false;
var jumping = false;
var koyoteTime = false;
var sneaking = false;
var falling = false;

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

func _ready():
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

func _physics_process(_delta):
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
	if (!deadwait && !changingPowerup):
		motion.y += gravity
	var friction = false;
	
	if (motion.y > max_fall):
		motion.y = max_fall;
	
	#Walk Animation Speed Controller
	var max_speed = 0;
	
	#In Flag Pole
	if (in_flag_pole):
		motion.y = 200;
		if (current_sprite.animation != currentPowerup+"_climb"):
			current_sprite.play(currentPowerup+"_climb");
	
	#Out Flag Pole
	if (course_clear && !in_flag_pole):
		motion.x = max_walk_speed;
	
	#Start Menu Check
	var startmenucheck = true;
	if (get_parent().startmenu):
		if (!get_node("../../StartMenu/StartButton").visible):
			startmenucheck = false;
	
	if (!died && !in_flag_pole && !changingPowerup):
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
			if (current_sprite.animation == currentPowerup+"_walk" && abs(motion.x) > max_walk_speed):
				current_sprite.speed_scale = abs(motion.x)/(max_walk_speed*1.25);
			else:
				current_sprite.speed_scale = 1;
		elif (star && !running):
			current_sprite.speed_scale = 1.25;
			max_speed = max_walk_speed*1.25;
		elif (running):
			max_speed = max_run_speed;
			if (current_sprite.animation == currentPowerup+"_walk" && abs(motion.x) > max_walk_speed):
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
			if (current_sprite.animation != currentPowerup+"_jump"):
				if  (falling || jumping):
					if (!sneaking):
						current_sprite.play(currentPowerup+"_jump");
					else:
						pass
				
			if (!falling):
				koyoteTime = true;
				$KoyoteTimer.start();
				falling = true;
		elif (is_on_floor()):
			jumping = false;
			koyoteTime = false;
			falling = false;
			singlegridcheck = false;
			lastScore = 0;
		
		#Movement Controller
		if (drifting && is_on_floor()):
			current_sprite.play(currentPowerup+"_drift");
		
		var inpchckr = Input.is_action_pressed("right") || Input.is_action_pressed("dright");
		var inpchckl = Input.is_action_pressed("left") || Input.is_action_pressed("dleft");
		var sneakchck = !sneaking || !is_on_floor();
		if (inpchckr && sneakchck && !course_clear && startmenucheck):
			var acc = acceleration * 2.5;
			if (is_on_floor() && !attacking):
				if (current_sprite.flip_h):
					current_sprite.flip_h = false;
					drifting = false;
			
				if (motion.x < 0 && abs(motion.x) > max_run_speed*0.8):
					drifting = true;
				
				if (motion.x > 0 && drifting):
					drifting = false;
				
				if (!drifting):
					current_sprite.play(currentPowerup+"_walk");
				var chck1 = motion.x > 0 && !current_sprite.flip_h
				var chck2 = motion.x < 0 && current_sprite.flip_h;
				if (chck1 || chck2):
					acc = acceleration;
				else:
					acc = acceleration * 2;
			if (motion.x < max_speed):
				motion.x += acc;
			else:
				motion.x -= acc/2;
		elif (inpchckl && sneakchck && !course_clear && startmenucheck):
			var acc = acceleration * 2.5;
			if (is_on_floor() && !attacking):
				if (!current_sprite.flip_h):
					current_sprite.flip_h = true;
					drifting = false;
				
				if (motion.x > 0 && abs(motion.x) > max_run_speed*0.8):
					drifting = true;
					
				if (motion.x < 0 && drifting):
					drifting = false;
					
				var chck1 = motion.x > 0 && !current_sprite.flip_h
				var chck2 = motion.x < 0 && current_sprite.flip_h;
				if (chck1 || chck2):
					acc = acceleration;
				else:
					acc = acceleration * 2;
				
				if (!drifting):
					current_sprite.play(currentPowerup+"_walk");
			if (motion.x > -max_speed):
				motion.x -= acc;
			else:
				motion.x += acc/2;
		else:
			friction = true;
			if (is_on_floor() && !attacking):
				if (!sneaking && !drifting):
					if (round(abs(motion.x)) > 0):
						current_sprite.play(currentPowerup+"_walk");
					else:
						current_sprite.play(currentPowerup+"_idle");
				if (abs(motion.x) <= max_walk_speed*0.1):
					motion.x = 0;
				if (abs(motion.x) <= max_walk_speed*0.4):
					drifting = false;
		
		#Jump and friction controller
		if (is_on_floor() || koyoteTime):
			if (!course_clear && startmenucheck):
				if (Input.is_action_just_pressed("a") || Input.is_action_just_pressed("b")):
					#High Jump Controller
					if (abs(motion.x) >= max_run_speed):
						motion.y = jump_h*1.1;
					else:
						motion.y = jump_h;
					
					if (!sneaking && !attacking):
						current_sprite.play(currentPowerup+"_jump");
					jumping = true;
					$SoundJump.play();
					koyoteTime = false;
					drifting = false;
					
					detectSingleGrid();
			if (friction):
				motion.x = lerp(motion.x, 0, 0.0625);
		else:
			if (friction):
				motion.x = lerp(motion.x, 0, 0.01);
		
		if (Input.is_action_just_released("a") || Input.is_action_just_released("b")):
			if (jumping && motion.y < jump_h*0.35 && !is_on_floor() && !course_clear && startmenucheck):
				motion.y = jump_h*0.35
				if (!sneaking):
					current_sprite.play(currentPowerup+"_jump");
				
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
		
		#Debug
		#if (Input.is_action_just_pressed("r")):
		#	if (!died): die();
		
	#Global Movement Controller
	motion = move_and_slide(motion, Vector2(0, -1));

func sneak():
	sneaking = true;
	current_sprite.play(currentPowerup+"_crouch");
	drifting = false;
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
	motion.x = 0;
	motion.y = 0;
	current_sprite.offset.y = 0;
	deadwait = true;
	get_parent().gameMusic(false);
	died = true;
	current_sprite.play("small_dead");
	
	$SoundDead.play();
	
	star = false;
	$AnimationPlayer.play("RESET");
	$Light2D.enabled = false;
	$SoundStar.stop();
	
	#Online Dead Signal
#	var inst = load("res://scenes/appearances/OnlineDeath.tscn").instance();
#	get_parent().add_child(inst);
#	inst.get_node("AnimationPlayer").play("start");
#	inst.position = position;
#	if (inst.position.y > 1545):
#		inst.position.y = 1545;
	
	yield(get_tree().create_timer(0.8), "timeout");
	
	current_sprite.play("small_dead");
	$DeadTimer.start();
	deadwait = false;
	$SmallCollision.disabled = true;
	$SneakCollision.disabled = true;
	$MushCollision.disabled = true;
	motion.y = jump_h*1;

func _process(_delta):
	if (Global.playing):
		Global.charpos = position;
	#Shadow Animation Sync Controller
	current_sprite.get_node("Shadow").animation = current_sprite.animation;
	current_sprite.get_node("Shadow").flip_h = current_sprite.flip_h;
	current_sprite.get_node("Shadow").frame = current_sprite.frame;
	current_sprite.get_node("Shadow").offset = current_sprite.offset;
	
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
	
	#Wall Dead
	if (!died && position.y < get_parent().calculateGridPosition(Vector2(0, get_parent().grid_size.y-1)).y):
		var mygrid = get_parent().calculateGrid(position.x, position.y+12);
		var node = get_parent().grid_node[mygrid.x][mygrid.y];
		if (node != null):
			if (!node.is_in_group("OffBlock2") &&
			!node.is_in_group("OnBlock2") &&
			!node.is_in_group("OffBlock") &&
			!node.is_in_group("OnBlock") &&
			node.is_in_group("Solid") &&
			!node.get_node("CollisionShape2D").disabled &&
			node.position == get_parent().calculateGridPosition(mygrid)):
				die();

func _on_KoyoteTimer_timeout():
	koyoteTime = false;

func _on_DeadTimer_timeout():
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
				$SoundJump.stop();
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

func deactivateSubPixelSprite():
	$Mario.position.y = -3;
