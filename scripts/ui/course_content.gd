extends TextureRect

onready var currentSprite = get_node("SMB/SpriteGround");
onready var currentBg = get_node("SMB/BgGround");
onready var currentAppearance = get_node("SMB");

func setAppearance(appearance):
	currentAppearance.hide();
	match (appearance):
		Global.APP_SMB:
			currentAppearance = get_node("SMB");
		Global.APP_SMB3:
			currentAppearance = get_node("SMB3");
	currentAppearance.show();

func setStyle(style):
	#print(style);
	match (style):
		"Underground":
			currentSprite.hide();
			currentBg.hide();
			currentSprite = currentAppearance.get_node("SpriteUnderground");
			currentBg = currentAppearance.get_node("BgUnderground");
			currentSprite.show();
			currentBg.show();
		"Ghosthouse":
			currentSprite.hide();
			currentBg.hide();
			currentSprite = currentAppearance.get_node("SpriteUnderground");
			currentBg = currentAppearance.get_node("BgUnderground");
			currentSprite.show();
			currentBg.show();
		"Sky":
			currentSprite.hide();
			currentBg.hide();
			currentSprite = currentAppearance.get_node("SpriteSky");
			currentBg = currentAppearance.get_node("BgSky");
			currentSprite.show();
			currentBg.show();
		"Forest":
			currentSprite.hide();
			currentBg.hide();
			currentSprite = currentAppearance.get_node("SpriteForest");
			currentBg = currentAppearance.get_node("BgForest");
			currentSprite.show();
			currentBg.show();
		"Desert":
			currentSprite.hide();
			currentBg.hide();
			currentSprite = currentAppearance.get_node("SpriteDesert");
			currentBg = currentAppearance.get_node("BgDesert");
			currentSprite.show();
			currentBg.show();
		"Snow":
			currentSprite.hide();
			currentBg.hide();
			currentSprite = currentAppearance.get_node("SpriteSnow");
			currentBg = currentAppearance.get_node("BgSnow");
			currentSprite.show();
			currentBg.show();
		"Ghostforest":
			currentSprite.hide();
			currentBg.hide();
			currentSprite = currentAppearance.get_node("SpriteGhostforest");
			currentBg = currentAppearance.get_node("BgGhostforest");
			currentSprite.show();
			currentBg.show();
		_:
			currentSprite.hide();
			currentBg.hide();
			currentSprite = currentAppearance.get_node("SpriteGround");
			currentBg = currentAppearance.get_node("BgGround");
			currentSprite.show();
			currentBg.show();
