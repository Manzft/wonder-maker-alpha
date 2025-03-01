extends KinematicBody2D

onready var currentSprite = get_node("SpriteGround");

const gravity = 30;

var press = false;

var motion = Vector2();

var startPos = Vector2();

var active = false;
var exiting = false;
var arrived = false;
var insided = false;

var canSyncAnim = false;

var carrying = false;

var speed_increase = 0;

var max_h_speed = 500;

func _ready():
	styleChanged();
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");
	startPos = position;
	canSyncAnim = true;
	$VisibilityEnabler2D.emit_signal("screen_exited")

func _process(_delta):
	currentSprite.get_node("Shadow").frame = currentSprite.frame;
	currentSprite.get_node("Shadow").animation = currentSprite.animation;
	if (get_node("../Editor").playing):
		currentSprite.speed_scale = 1;
		if (!insided && !active):
			active = true;
			
		#Carried by Player
		var chara = get_node("../Character");
		if (carrying && chara.carrying):
			var charpos = chara.position;
			var dif = 0;
			if (chara.current_sprite.flip_h):
				dif = -32;
			else:
				dif = 32;
			
			position.x = charpos.x+dif;
			position.y = charpos.y-5;
			
			if (!chara.running):
				carrying = false;
				chara.carrying = false;
				
				motion.y = 0;
				
				if (!chara.died && !chara.changingPowerup):
					speed_increase = abs(get_node("../Character").motion.x);
					if (Input.is_action_pressed("down") || Input.is_action_pressed("ddown")):
						if (chara.position.x >= position.x):
							position.x -= 10;
							motion.x = -70-speed_increase;
						else:
							position.x += 10;
							motion.x = 70+speed_increase;
					else:
						chara.get_node("KickingTimer").start();
						chara.kicking = true;
						if (chara.position.x >= position.x):
							var inst = load("res://scenes/appearances/smb3/particles/parthit.tscn").instance();
							get_parent().add_child(inst);
							inst.position.x = position.x-12.5;
							inst.position.y = position.y;
							position.x -= 10;
							motion.x = -max_h_speed-speed_increase;
						else:
							var inst = load("res://scenes/appearances/smb3/particles/parthit.tscn").instance();
							get_parent().add_child(inst);
							inst.position.x = position.x+12.5;
							inst.position.y = position.y;
							position.x += 10;
							motion.x = max_h_speed+speed_increase;
						chara.get_node("SoundShellHit").play();
	else:
		if (insided):
			queue_free();
		
		if (active || !visible):
			active = false;
			exiting = false;
			arrived = false;
			show();
			position = startPos;
			motion = Vector2(0, 0);
			$CollisionShape2D.disabled = false;
		
		carrying = false;
		startPos = position;
		press = false;
		
		if (get_parent().grab && get_parent().grab_node == self):
			currentSprite.play("idle");
			currentSprite.speed_scale = 1;
		else:
			currentSprite.play("idle");
			currentSprite.speed_scale = 0;
			currentSprite.frame = 0;

func _physics_process(delta):
	if (get_node("../Editor").playing):
		if (!active && exiting):
			position.y -= 2;
			if (position.y <= startPos.y-52):
				active = true;
				exiting = false;
		
		if (active && !exiting):
			motion.y += gravity
			
			if (!arrived && is_on_floor()):
				arrived = true;
			
			if (!carrying && visible && currentSprite.animation != "pressed" && press && !get_node("../Character").is_on_floor() && get_node("../Character").position.y < position.y && get_node("../Character").motion.y > 0):
				var nodes = get_tree().get_nodes_in_group("P");
				for node in nodes:
					if (node.currentSprite.animation == "pressed"):
						node.currentSprite.play("idle");
				
				currentSprite.play("pressed");
				get_node("../Character/SoundPButton").play();
				get_parent().gameMusic(false);
				
				get_node("../Character").p = true;
				
				get_node("../Character/SoundTwompHit").play();
				
				if !(Input.is_action_pressed("a") || Input.is_action_pressed("b")):
					get_node("../Character").motion.y = get_node("../Character").jump_h*0.7;
					get_node("../Character").jumping = true;
				else:
					get_node("../Character").motion.y = get_node("../Character").jump_h*1;
					get_node("../Character").jumping = true;
				
				nodes = get_tree().get_nodes_in_group("Coin");
				for node in nodes:
					if (!node.is_in_group("10Coin") && !node.is_in_group("30Coin") && !node.is_in_group("50Coin")):
						if (node.visible && !node.powner && !node.p):
							node.powner = true;
							node.hide();
							var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_BRICK][Global.OP_SCENE].instance();
							inst.position = node.position;
							inst.p = true;
							get_parent().add_child(inst);
				nodes = get_tree().get_nodes_in_group("Brick");
				for node in nodes:
					if (node.visible && !node.powner && !node.p):
						node.powner = true;
						node.hide();
						var inst = Global.object[Global.CurrentAppeareance][Global.OBJ_COIN][Global.OP_SCENE].instance();
						inst.position = node.position;
						inst.p = true;
						get_parent().add_child(inst);
				$CollisionShape2D.disabled = true;
				yield(get_tree().create_timer(0.25), "timeout");
				hide();
				
			#Carrying
			if (currentSprite.animation != "pressed" && press && !carrying && get_node("../Character").running && !get_node("../Character").carrying && !get_node("../Character").sneaking):
				carrying = true;
				get_node("../Character").carrying = true;
		
		if (!exiting && !carrying && visible):
			$CollisionShape2D.disabled = false;
			if (abs(motion.x) <= 70):
				motion.x = lerp(motion.x, 0.0, 0.125);
			else:
				motion.x = lerp(motion.x, 0.0, 0.03125);
			motion = move_and_slide(motion, Vector2(0, -1));
		else:
			$CollisionShape2D.disabled = true;

func styleChanged():
	match (Global.CurrentStyle):
		_:
			currentSprite.hide();
			currentSprite = get_node("SpriteGround");
			currentSprite.show();

func release():
	currentSprite.play("idle");
	
	var nodes = get_tree().get_nodes_in_group("Coin");
	for node in nodes:
		if (!node.is_in_group("10Coin") && !node.is_in_group("30Coin") && !node.is_in_group("50Coin")):
			if (node.powner):
				node.powner = false;
				node.show();
			if (node.p):
				node.queue_free();
	nodes = get_tree().get_nodes_in_group("Brick");
	for node in nodes:
		if (node.powner):
			node.powner = false;
			node.show();
		if (node.p):
			node.queue_free();

func _on_Area2D_body_entered(body):
	if (body.is_in_group("Character")):
		press = true;

func _on_Area2D_body_exited(body):
	if (body.is_in_group("Character")):
		press = false;
