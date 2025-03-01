extends Area2D

onready var currentSprite = get_node("SpriteGround");

var p = false;
var powner = false;

var canSyncAnim = false;

func _ready():
	styleChanged();
	yield(get_tree(), "idle_frame");
	if (get_parent().editing):
		$AnimationPlayer.play("start");
	canSyncAnim = true;
	$VisibilityEnabler2D.emit_signal("screen_exited")

func _process(_delta):
	if (get_node("../Editor").playing):
		currentSprite.speed_scale = 1;
	else:
		if (p):
			queue_free();
		if (powner):
			powner = false;
		
		if (!visible):
			show();
		currentSprite.speed_scale = 0;
		currentSprite.frame = 0;

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
			currentSprite = get_node("SpriteUnderground");
			currentSprite.show();
		_:
			currentSprite.hide();
			currentSprite = get_node("SpriteGround");
			currentSprite.show();

func _on_Coin_body_entered(body):
	if (body.is_in_group("Character") && visible):
		hide();
		if (body.get_node("SoundCoin").playing):
			body.get_node("SoundCoin").stop();
		body.get_node("SoundCoin").play();
		
		get_parent().get_node("Editor").Coins += 1;
		get_node("../Editor").Score += 200;
		
		if (!p):
			var grid = get_parent().calculateGrid(position.x, position.y);
			var gr = get_parent().grid[grid.x][grid.y+1];
			if (gr == Global.OBJ_LUCKYBLOCK || gr == Global.OBJ_BRICK || gr == Global.OBJ_INVISIBLE_LUCKYBLOCK):
				var nodes = get_tree().get_nodes_in_group("Insideable");
				for node in nodes:
					if (node.position == get_parent().calculateGridPosition(Vector2(grid.x, grid.y+1))):
						node.myUpCoinDone = true;
		else:
			var grid = get_parent().calculateGrid(position.x, position.y);
			get_parent().grid_node[grid.x][grid.y].powner = false;
			queue_free();
