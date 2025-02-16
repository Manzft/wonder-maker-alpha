extends StaticBody2D

onready var currentSprite = get_node("SpriteGround");
onready var flameCurrentSprite = get_node("Flame");

var hitCharacter = false;
var sleep = false;

var canSyncAnim = false;

var seldirection = "up";

func _ready():
	styleChanged();
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");
	canSyncAnim = true;
	$VisibilityEnabler2D.emit_signal("screen_exited")

func _process(_delta):
	flameCurrentSprite.get_node("Shadow").frame = flameCurrentSprite.frame;
	flameCurrentSprite.get_node("Shadow").animation = flameCurrentSprite.animation;
	
	$DirectionButton/ArrowLeft.hide();
	$DirectionButton/ArrowRight.hide();
	$DirectionButton/ArrowUp.hide();
	$DirectionButton/ArrowDown.hide();
	match (seldirection):
		"down":
			$DirectionButton/ArrowDown.show();
			$SpriteGround.rotation_degrees = 180;
			$SpriteGround/Shadow.position = Vector2(-3, -3);
			
			$Flame.position = Vector2(0, 104);
			$Flame.rotation_degrees = 180;
			$Flame/Shadow.position = Vector2(-3, -3);
			
			$Area2D/Up.disabled = true;
			$Area2D/Left.disabled = true;
			$Area2D/Right.disabled = true;
			$Area2D/Down.disabled = false;
		"up":
			$DirectionButton/ArrowUp.show();
			$SpriteGround.rotation_degrees = 0;
			$SpriteGround/Shadow.position = Vector2(3, 3);
			
			$Flame.position = Vector2(0, -104);
			$Flame.rotation_degrees = 0;
			$Flame/Shadow.position = Vector2(3, 3);
			
			$Area2D/Up.disabled = false;
			$Area2D/Left.disabled = true;
			$Area2D/Right.disabled = true;
			$Area2D/Down.disabled = true;
		"left":
			$DirectionButton/ArrowLeft.show();
			$SpriteGround.rotation_degrees = 270;
			$SpriteGround/Shadow.position = Vector2(-3, 3);
			
			$Flame.position = Vector2(-104, 0);
			$Flame.rotation_degrees = 270;
			$Flame/Shadow.position = Vector2(-3, 3);
			
			$Area2D/Up.disabled = true;
			$Area2D/Left.disabled = false;
			$Area2D/Right.disabled = true;
			$Area2D/Down.disabled = true;
		"right":
			$DirectionButton/ArrowRight.show();
			$SpriteGround.rotation_degrees = 90;
			$SpriteGround/Shadow.position = Vector2(3, -3);
			
			$Flame.position = Vector2(104, 0);
			$Flame.rotation_degrees = 90;
			$Flame/Shadow.position = Vector2(3, -3);
			
			$Area2D/Up.disabled = true;
			$Area2D/Left.disabled = true;
			$Area2D/Right.disabled = false;
			$Area2D/Down.disabled = true;
	if (get_node("../Editor").playing):
		flameCurrentSprite.speed_scale = 1;
		$DirectionButton.hide();
		
		if (sleep):
			if (abs(position.x-get_node("../Character").position.x) <= 1280*0.75):
				get_node("../Character/SoundBurnerFlame").play();
			sleep = false;
		
		if (flameCurrentSprite.animation == "idle"):
			if ($SleepTimer.is_stopped()):
				$SleepTimer.start();
		
		if (hitCharacter && flameCurrentSprite.animation == "idle"):
			if (!get_node("../Character").invincible && !get_node("../Character").died && !get_node("../Character").changingPowerup):
				if (!get_node("../Character").star):
					get_node("../Character").hit();
					
		if (canSyncAnim):
			var nodes = get_tree().get_nodes_in_group("Burner");
			for node in nodes:
				node.flameCurrentSprite.frame = flameCurrentSprite.frame;
				node.flameCurrentSprite.animation = flameCurrentSprite.animation;
	else:
		
		$DirectionButton.show();
		sleep = true;
		if (!flameCurrentSprite.visible):
			flameCurrentSprite.show();
		$SleepTimer.stop();
		$WakeTimer.stop();
		$ToSleepTimer.stop();
		$ToWakeTimer.stop();
		
		if (get_parent().grab && get_parent().grab_node == self):
			flameCurrentSprite.play("idle");
			flameCurrentSprite.speed_scale = 1;
		else:
			flameCurrentSprite.play("idle");
			flameCurrentSprite.speed_scale = 0;
			flameCurrentSprite.frame = 0;
			
		#DirectionButton Gamepad Press
		if (Global.CurrentInput == "Gamepad"):
			var gamepad_pos = get_node("../Editor/GamepadCursor").rect_position+get_node("../Camera2D").position;
			var dirbutton_pos = position+$DirectionButton.rect_position;
			var dirbutton_size = $DirectionButton.rect_size;
			if (gamepad_pos.x >= dirbutton_pos.x && gamepad_pos.y >= dirbutton_pos.y &&
			gamepad_pos.x <= dirbutton_pos.x+dirbutton_size.x && gamepad_pos.y <= dirbutton_pos.y+dirbutton_size.y):
					get_node("../Editor").externalButton = true;
					if (Input.is_action_just_pressed("a")):
						_on_DirectionButton_pressed();
			else:
				get_node("../Editor").externalButton = false;

func styleChanged():
	match (Global.CurrentStyle):
		_:
			currentSprite.hide();
			currentSprite = get_node("SpriteGround");
			currentSprite.show();

func _on_Area2D_body_entered(body):
	if (body.is_in_group("Character")):
		hitCharacter = true;

func _on_Area2D_body_exited(body):
	if (body.is_in_group("Character")):
		hitCharacter = false;

func _on_SleepTimer_timeout():
	if (flameCurrentSprite.animation == "idle"):
		flameCurrentSprite.play("turning");
		$ToSleepTimer.start();

func _on_ToSleepTimer_timeout():
	if (flameCurrentSprite.animation == "turning"):
		flameCurrentSprite.play("off");
		$WakeTimer.start();
		flameCurrentSprite.hide();

func _on_WakeTimer_timeout():
	if (flameCurrentSprite.animation == "off"):
		flameCurrentSprite.play("onturning");
		$ToWakeTimer.start();
		flameCurrentSprite.show();

func _on_ToWakeTimer_timeout():
	if (flameCurrentSprite.animation == "onturning"):
		flameCurrentSprite.play("idle");
		sleep = true;

func _on_DirectionButton_pressed():
	match (seldirection):
		"up":
			seldirection = "right";
		"down":
			seldirection = "left";
		"left":
			seldirection = "up";
		"right":
			seldirection = "down";
	$AudioGrabMove.play();
	if (OS.get_name() == "Android"):
		get_node("../Editor").externalButton = false;

func _on_DirectionButton_mouse_entered():
	get_node("../Editor").externalButton = true;

func _on_DirectionButton_mouse_exited():
	get_node("../Editor").externalButton = false;
