extends Node2D

var sprite_shadow:Sprite

func _ready():
	sprite_shadow = add_shadow($Sprite);
	add_shadow($Block);

func _process(_delta):
	if (Input.is_action_pressed("right")): $Sprite.position.x += 5;
	if (Input.is_action_pressed("left")): $Sprite.position.x -= 5;
	if (Input.is_action_pressed("down")): $Sprite.position.y += 5;
	if (Input.is_action_pressed("up")): $Sprite.position.y -= 5;
	
	sprite_shadow.position = $Sprite.position+Vector2(3*3.25, 3*3.25);

func add_shadow(ref):
	var sprite = Sprite.new();
	sprite.texture = ref.texture;
	sprite.scale = ref.scale
	sprite.position = ref.position+Vector2(3*3.25, 3*3.25);
	$Viewport.add_child(sprite);
	
	return sprite;
