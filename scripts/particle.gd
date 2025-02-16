extends CPUParticles2D

func _ready():
	if (is_in_group("SMB_P_BRICK_BREAK")):
		var app = "smb";
		
		match (Global.CurrentAppeareance):
			Global.APP_SMB:
				app = "smb";
			Global.APP_SMB3:
				app = "smb3";
		
		match (Global.CurrentStyle):
			"Underground":
				texture = load("res://sprites/appeareances/"+app+"/blocks/underground/particle_brick_break_underground.png");
			"Ghosthouse":
				texture = load("res://sprites/appeareances/"+app+"/blocks/underground/particle_brick_break_underground.png");
			"Ghostforest":
				texture = load("res://sprites/appeareances/"+app+"/blocks/ghostforest/particle_brick_break_ghostforest.png");
			"Snow":
				texture = load("res://sprites/appeareances/"+app+"/blocks/snow/particle_brick_break_snow.png");
			_:
				texture = load("res://sprites/appeareances/"+app+"/blocks/ground/particle_brick_break_ground.png");
	yield(get_tree(), "idle_frame");
	emitting = true;

func _on_Timer_timeout():
	queue_free();

func _on_PartHit_animation_finished():
	_on_Timer_timeout();
