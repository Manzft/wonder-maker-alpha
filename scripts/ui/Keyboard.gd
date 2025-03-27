extends CanvasLayer

var shift = false;

var blink = false;
var blinkpos = 0;

var button_pressed = {}

var canErase = false;
var canEraseTimer = 0.0;

var capsLockPressed = false;

var realmenu = null;
var type = "";

func _ready():
	var nodes = get_tree().get_nodes_in_group("Word");
	for node in nodes:
		button_pressed[node.text] = false;
	$TextBlinkTimer.start(0.5);
	$TextEdit.text = "|";
	
	if (get_parent().get_name() == "Editor"):
		get_parent().editingText = true;
	
#	if (get_parent().get_name() == "Editor"):
#		if (get_parent().CurrentMenu == "SideMenu"):
#			rect_position.x += 610;

func _process(delta):
	if ($AnimationPlayer.current_animation == "out"):
		return
	
	var nodes = get_tree().get_nodes_in_group("Word");
	for node in nodes:
		if (!button_pressed[node.text.to_lower()] && node.get_parent().pressed):
			if ($TextEdit.text.length()-1 < 64):
				$TextEdit.text[$TextEdit.text.length()-1] = "";
				button_pressed[node.text.to_lower()] = true;
				$AudioKey.play();
				$TextEdit.text += node.text;
				
				$TextEdit.text += "|";
	#			if (blink):
	#				blink = false;
	#				$TextEdit.text[blinkpos] = "";
	#			$TextBlinkTimer.start(1.0);
		elif (!node.get_parent().pressed):
			button_pressed[node.text.to_lower()] = false;
	
	if ($ColorRect/Keys/BackspaceButton.disabled):
		$ColorRect/Keys/BackspaceButton/Icon.modulate = Color("#51000000");
	else:
		$ColorRect/Keys/BackspaceButton/Icon.modulate = Color("#ffffff");
	
	if ($ColorRect/Keys/DoneButton.disabled):
		$ColorRect/Keys/DoneButton/Label.modulate = Color("#51000000");
	else:
		$ColorRect/Keys/DoneButton/Label.modulate = Color("#ffffff");
	
	if ($TextEdit.text.length() > 1):
		$ColorRect/Keys/DoneButton.disabled = false;
		$ColorRect/Keys/BackspaceButton.disabled = false;
	else:
		$ColorRect/Keys/DoneButton.disabled = true;
		$ColorRect/Keys/BackspaceButton.disabled = true;
	
	$TypeBase/LabelCharacters.text = str($TextEdit.text.length()-1)+"/64";
	
	if (!$ColorRect/Keys/BackspaceButton.pressed && canErase):
		canErase = false;
	
	if (canErase):
		canEraseTimer += 1;
		if (canEraseTimer >= 3):
			_on_BackspaceButton_pressed();
			canEraseTimer = 0.0;
	
	if (Input.is_key_pressed(KEY_CAPSLOCK) && !capsLockPressed):
		_on_ShiftButton_pressed();
		capsLockPressed = true;
	elif (!Input.is_key_pressed(KEY_CAPSLOCK) && capsLockPressed):
		capsLockPressed = false;

func switchShiftState():
	if (shift):
		shift = false;
		$ColorRect/Keys/ShiftButton/Icon.modulate = Color("#b6000000");
		var nodes = get_tree().get_nodes_in_group("Word");
		for node in nodes:
			node.text = node.text.to_lower();
	else:
		shift = true;
		$ColorRect/Keys/ShiftButton/Icon.modulate = Color("#b60064ff");
		var nodes = get_tree().get_nodes_in_group("Word");
		for node in nodes:
			node.text = node.text.to_upper();

func _on_DoneButton_pressed():
	$AudioDone.play();
	finish();

func _on_BackspaceButton_pressed():
#	if (!$AudioBackspace.playing):
	$AudioBackspace.play();
	if ($TextEdit.text != ""):
		if ($TextEdit.text.length() > 1):
			$TextEdit.text[$TextEdit.text.length()-1] = "";
			$TextEdit.text[$TextEdit.text.length()-1] = "";
		
			$TextEdit.text += "|";
		$CanEraseTimer.start();
#		$TextBlinkTimer.start(1.0);

func _on_ShiftButton_pressed():
	$AudioShift.play();
	switchShiftState();

func _on_SpaceButton_pressed():
	if ($TextEdit.text.length()-1 < 64):
		$TextEdit.text[$TextEdit.text.length()-1] = "";
		$AudioSpace.play();
		$TextEdit.text += " ";
		$TextEdit.text += "|";

func _on_TextBlinkTimer_timeout():
	return
	if (!blink):
		blink = true;
		blinkpos = $TextEdit.text.length();
		$TextEdit.text += "|";
	else:
		blink = false;
		if ($TextEdit.text.length() >= blinkpos+1):
			$TextEdit.text[blinkpos] = "";
	$TextBlinkTimer.start(0.5);

func _on_CanEraseTimer_timeout():
	if ($ColorRect/Keys/BackspaceButton.pressed && !canErase):
		canErase = true;
		canEraseTimer = 0.0;

func finish(cancel : bool = false):
	$AnimationPlayer.play("out");
	
	if (Global.CurrentInput == "Gamepad"):
		if (realmenu == null):
			if (get_parent().savedFocus != null):
				get_parent().savedFocus.grab_focus();
			get_parent().updateFocusSprite();
		else:
			if (realmenu.savedFocus != null):
				realmenu.savedFocus.grab_focus();
			realmenu.updateFocusSprite();
	
	get_parent().savedFocus = null;
	if (get_parent().get_name() == "Editor"):
		get_parent().editingText = false;
	
	yield(get_tree().create_timer(1.0), "timeout");
	if (!cancel):
		get_parent().enterTextFinished($TextEdit.text.trim_suffix("|"), type);

func setText(text : String):
	$LabelGuide.text = text;

func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "out"):
		queue_free();

func _on_BackButton_pressed():
	$AudioBack.play();
	finish(true);
