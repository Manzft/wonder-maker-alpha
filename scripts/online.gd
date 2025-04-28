extends Node

var logged: bool = false
var playing_online: bool = false

var to_publish: bool = false

var request_type: String = ""
var request_tree: Node = null

var http_request = HTTPRequest.new()

var waiting_for_response: bool = false

var persistency_menu: String = ""

var user_name: String = ""

var timer = 0.0

func _ready() -> void:
	add_child(http_request)

func _process(delta: float) -> void:
	if (waiting_for_response):
		timer += delta
		if (timer >= 5.0):
			timer = 0.0
			waiting_for_response = false
	else:
		timer = 0.0

func login(tree: Node):
	if (waiting_for_response):
		return
	var data = null
	request_type = "login"
	request_tree = tree
	waiting_for_response = true
	SupabaseClient.fetch_all_rows("accounts", http_request, self)

func register(tree: Node):
	if (waiting_for_response):
		return
	request_type = "register"
	request_tree = tree
	waiting_for_response = true
	SupabaseClient.fetch_all_rows("accounts", http_request, self)

func get_users(tree: Node):
	if (waiting_for_response):
		return
	request_type = "get_users"
	request_tree = tree
	waiting_for_response = true
	SupabaseClient.fetch_all_rows("accounts", http_request, self)

func get_levels(tree: Node):
	if (waiting_for_response):
		return
	request_type = "get_levels"
	request_tree = tree
	waiting_for_response = true
	SupabaseClient.fetch_all_rows("levels", http_request, self)

func publish_level(level_data: Dictionary, level_name: String):
	if (waiting_for_response):
		return
	var level = {
		"name": level_name,
		"data": level_data
	}
	SupabaseClient.insert_row("levels", level, http_request)

func set_played():
	if (waiting_for_response):
		return
	request_type = "set_played"
	waiting_for_response = true
	SupabaseClient.fetch_all_rows("accounts", http_request, self)

func add_death():
	if (waiting_for_response):
		return
	var level_code = str(int(Global.current_lodaded_level_data.id))
	var send_data = int(Global.current_lodaded_level_data.deaths)+1
	var condition = {
		"id": int(Global.current_lodaded_level_data.id)
	}
	Global.current_lodaded_level_data.deaths = int(Global.current_lodaded_level_data.deaths)+1
	SupabaseClient.set_value("levels", "deaths", send_data, condition, http_request)

func add_level_clear():
	if (waiting_for_response):
		return
	request_type = "add_level_clear"
	waiting_for_response = true
	SupabaseClient.fetch_all_rows("accounts", http_request, self)

func add_like():
	if (waiting_for_response):
		return
	request_type = "add_like"
	waiting_for_response = true
	SupabaseClient.fetch_all_rows("accounts", http_request, self)

func add_dislike():
	if (waiting_for_response):
		return
	request_type = "add_dislike"
	waiting_for_response = true
	SupabaseClient.fetch_all_rows("accounts", http_request, self)

func http_finished(data):
	if (data != null):
		match (request_type):
			"set_played":
				Global.current_users_data = data
				for user in data:
					if (user.nick == Online.user_name):
						var level_code = str(int(Global.current_lodaded_level_data.id))
						var dir = {}
						if (user.levels_interacted != null):
							dir = user.levels_interacted
							if (level_code in dir):
								return
						var send_data = {}
						if (user.levels_interacted != null): send_data = user.levels_interacted
						send_data[level_code] = {
							"played": true
						}
						var condition = {
							"nick": Online.user_name
						}
						for us in range(Global.current_users_data.size()):
							if (Global.current_users_data[us].nick == user.nick):
								Global.current_users_data[us].levels_interacted = send_data
						#await SupabaseClient.set_value("accounts", "levels_interacted", send_data, condition, http_request)
						send_data = int(Global.current_lodaded_level_data.played)+1
						Global.current_lodaded_level_data.played = int(Global.current_lodaded_level_data.played)+1
						condition = {
							"id": int(Global.current_lodaded_level_data.id)
						}
						#await SupabaseClient.set_value("levels", "played", send_data, condition, http_request)
						break
			"add_level_clear":
				Global.current_users_data = data
				for user in data:
					if (user.nick == Online.user_name):
						var level_code = str(int(Global.current_lodaded_level_data.id))
						var dir = {}
						if (user.levels_interacted != null):
							dir = user.levels_interacted
							if (level_code in dir):
								if ("clear" in dir[level_code]):
									return
							else:
								return
						
						var send_data = user.levels_interacted
						send_data[level_code]["clear"] = true
						var condition = {
							"nick": Online.user_name
						}
						for us in range(Global.current_users_data.size()):
							if (Global.current_users_data[us].nick == user.nick):
								Global.current_users_data[us].levels_interacted = send_data
						#await SupabaseClient.set_value("accounts", "levels_interacted", send_data, condition, http_request)
						
						for us in range(Global.current_users_data.size()):
							if (Global.current_users_data[us].nick == user.nick):
								send_data = int(Global.current_users_data[us].finished_levels)+1
								Global.current_users_data[us].finished_levels = send_data
						#await SupabaseClient.set_value("accounts", "finished_levels", send_data, condition, http_request)
						
						send_data = int(Global.current_lodaded_level_data["clear"])+1
						Global.current_lodaded_level_data["clear"] = int(Global.current_lodaded_level_data["clear"])+1
						condition = {
							"id": int(Global.current_lodaded_level_data.id)
						}
						#await SupabaseClient.set_value("levels", "clear", send_data, condition, http_request)
						break
			"add_like":
				Global.current_users_data = data
				for user in data:
					if (user.nick == Online.user_name):
						var level_code = str(int(Global.current_lodaded_level_data.id))
						var dir = {}
						if (user.levels_interacted != null):
							dir = user.levels_interacted
							if (level_code in dir):
								if ("reacted" in dir[level_code]):
									return
						
						var send_data = user.levels_interacted
						send_data[level_code]["reacted"] = "like"
						var condition = {
							"nick": Online.user_name
						}
						for us in range(Global.current_users_data.size()):
							if (Global.current_users_data[us].nick == user.nick):
								Global.current_users_data[us].levels_interacted = send_data
						#await SupabaseClient.set_value("accounts", "levels_interacted", send_data, condition, http_request)
						
						send_data = int(Global.current_lodaded_level_data["likes"])+1
						Global.current_lodaded_level_data["likes"] = send_data
						condition = {
							"id": int(Global.current_lodaded_level_data.id)
						}
						#await SupabaseClient.set_value("levels", "likes", send_data, condition, http_request)
						break
			"add_dislike":
				Global.current_users_data = data
				for user in data:
					if (user.nick == Online.user_name):
						var level_code = str(int(Global.current_lodaded_level_data.id))
						var dir = {}
						if (user.levels_interacted != null):
							dir = user.levels_interacted
							if (level_code in dir):
								if ("reacted" in dir[level_code]):
									return
						
						var send_data = user.levels_interacted
						send_data[level_code]["reacted"] = "dislike"
						var condition = {
							"nick": Online.user_name
						}
						for us in range(Global.current_users_data.size()):
							if (Global.current_users_data[us].nick == user.nick):
								Global.current_users_data[us].levels_interacted = send_data
						#await SupabaseClient.set_value("accounts", "levels_interacted", send_data, condition, http_request)
						
						send_data = int(Global.current_lodaded_level_data["dislikes"])+1
						Global.current_lodaded_level_data["dislikes"] = send_data
						condition = {
							"id": int(Global.current_lodaded_level_data.id)
						}
						#await SupabaseClient.set_value("levels", "dislikes", send_data, condition, http_request)
						break
			_:
				request_tree.online_request_finished(data, request_type)
				request_type = ""
				request_tree = null
	else:
		print("Error")
	
	waiting_for_response = false
