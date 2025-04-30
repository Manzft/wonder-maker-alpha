extends Node2D

export var SideSprite: bool = false

var node: Node

func _ready():
	node = get_parent()

func check(delta: float):
	var dead = node.dead
	
	if (node.chained && node.chainObject != null):
		if (node.chainObject.dead):
			node.chained = false;
			node.canChain = false;
			node.motion.x = -node.max_walk_speed;
	
	if (node.canChain && !node.chained && !dead):
		var gr = node.get_parent().calculateGrid(position.x, position.y);
		if (Global.isChainable(node.get_parent().grid[gr.x][gr.y+1])):
			node.chained = true;
			node.canChain = false;
			node.chainObject = node.get_parent().grid_node[gr.x][gr.y+1];
			node.arrived = true;
		
		var ir = round(rand_range(0, 1));
		if (ir == 1):
			node.chainMoving = "";
		else:
			node.chainMoving = "2"
		
	node.canChain = false;
	
	if (node.stopped && node.chained):
		node.stopChainObject = true;
	if (!node.stopped && !dead && node.chained):
		node.stopChainObject = false;
		if (node.chainObject != null):
			node.chainObject.stopped = false;
	
	if (node.stopChainObject && node.chainObject != null):
		node.chainObject.stopped = true;
	
	if (node.chained):
		if (node.chainObject != null):
			if (node.chainObject.visible):
				position.y = node.chainObject.position.y-51;
				if (node.chainObject.stopped):
					if (!SideSprite):
						if (node.currentSprite.animation != "idle"):
							node.currentSprite.animation = "idle";
				else:
					if (node.currentSprite.animation != "walk"):
						node.currentSprite.animation = "walk";
						#$AnimationPlayer.play("incolumn"+chainMoving);
				
				if (node.chainMoving == ""):
					node.currentSprite.position.x = lerp(node.currentSprite.position.x, -4.0, 12.0*delta);
					#currentSprite.flip_h = true;
					if (node.currentSprite.position.x <= -3.9):
						node.chainMoving = "2";
				else:
					node.currentSprite.position.x = lerp(node.currentSprite.position.x, 4.0, 12.0*delta);
					#currentSprite.flip_h = false;
					if (node.currentSprite.position.x >= 3.9):
						node.chainMoving = "";
					
				node.motion.x = node.chainObject.motion.x;
				if (SideSprite):
					node.currentSprite.flip_h = (node.motion.x <= 0);
				
				if (abs(node.position.x-node.chainObject.position.x) > 13):
					node.motion.y = 0;
					node.chained = false;
					node.chainObject = null;
			
			if (node.chainObject != null):
				if ("inbones" in node.chainObject):
					if (node.chainObject.inbones):
						node.chained = false;
						node.chainObject = null;
				if (node.chainObject != null):
					if ("inShell" in node.chainObject):
						if (node.chainObject.inShell):
							node.chained = false;
							node.chainObject = null;
		else:
			node.chainObject = null;
			node.chained = false;
			
	if (!node.chained && node.currentSprite.position.x != 0):
		node.currentSprite.position.x = 0;

func uncheck():
	node.chainMoving = "";
	node.chainMovingTimer = 0.0;
	node.stopped = false;
	node.stopChainObject = false;
	node.chainObject = null;
	node.canChain = true;
	node.chained = false;
