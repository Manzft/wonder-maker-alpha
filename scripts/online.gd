extends Node

var logged: bool = false
var playing_online: bool = false

var to_publish: bool = false

var request_data = null

var persistency_menu: String = ""

var user_name: String = ""

var local_accounts_data = {}
var local_loaded_level_data = {}

var timer = 0.0

func _ready() -> void:
	yield(auth(), "completed")

func auth():
	var auth_result = yield(Supabase.auth.sign_in_anonymous(), "completed")
	if auth_result.error:
		print("Auth error:", auth_result.error)
	else:
		print("Logged sucessfully.")
	return

func send_data(table: String, data: Dictionary):
	var query = SupabaseQuery.new().from(table).insert([data])
	
	# Conectar señal para manejar el resultado
	Supabase.database.connect("inserted", self, "_on_send_data_finished")
	
	var task = Supabase.database.query(query)
	
	request_data = null
	var var_to_send = yield(internal_check_request(), "completed")
	return var_to_send

func _on_send_data_finished(result):
	request_data = result

func send_data_condition(table: String, data: Dictionary, condition: Array):
	var query = SupabaseQuery.new().from(table).update(data).eq(condition[0], condition[1])

	Supabase.database.connect("updated", self, "_on_send_data_condition_finished")
	
	var task = Supabase.database.query(query)
	
	request_data = null
	var var_to_send = yield(internal_check_request(), "completed")
	return var_to_send

func _on_send_data_condition_finished(result):
	request_data = result

func receive_data(table: String):
	var query = SupabaseQuery.new().from(table).select()
	
	# Conectar señal para manejar el resultado
	Supabase.database.connect("selected", self, "_on_receive_data_finished")
	
	var task = Supabase.database.query(query)
	
	request_data = null
	var var_to_send = yield(internal_check_request(), "completed")
	return var_to_send

func _on_receive_data_finished(result):
	request_data = result

func login(nickname: String, password: String):
	print("Requesting login...")
	var accounts = yield(receive_data("accounts"), "completed")
	
	if (accounts == null):
		return "request_error"
	
	var server = yield(receive_data("server"), "completed")
	
	if (server == null):
		return "request_error"
	
	var user_found = false
	
	local_accounts_data = accounts
	
	for account in accounts:
		if (account.nick == nickname):
			user_found = true
			if (account.password == password):
				if (server[0]["server_opened"] == "yes"):
					if (account.banned == "yes"):
						print("User ", nickname, " can't login, he's banned from Wonder Maker Online server")
						return "banned"
					else:
						print("User ", nickname, " logged in Wonder Maker Online successfully")
						logged = true
						user_name = nickname
						return "logged"
				else:
					print("Servers Closed can't auth in Wonder Maker Online server")
					return "server_closed"
			else:
				print("Incorrect Password")
				return "incorrect_password"
			break
	
	if (!user_found):
		print("This user doesn't exists")
		return "user_not_found"

func register(nickname: String, password: String):
	print("Requesting register...")
	var accounts = yield(receive_data("accounts"), "completed")
	
	if (accounts == null):
		return "request_error"
	
	var server = yield(receive_data("server"), "completed")
	
	if (server == null):
		return "request_error"
	
	var user_found = false
	
	local_accounts_data = accounts
	
	for account in accounts:
		if (account.nick == nickname):
			user_found = true
			break
	
	if (user_found):
		print("This user already exists")
		return "user_found"
	else:
		print("User not found, trying to register...")
		var result = yield(send_data("accounts", {"nick": nickname, "password": password}), "completed")
		if (result != null):
			if (server[0]["server_opened"] == "yes"):
				print("User ", nickname, " registered in Wonder Maker Online successfully")
				logged = true
				user_name = nickname
				return "registered"
			else:
				print("Servers Closed can't auth in Wonder Maker Online server")
				return "server_closed"
		else:
			return "request_error"

func set_played():
	print("Requesting set played...")
	var accounts = yield(receive_data("accounts"), "completed")
	
	if (accounts == null):
		return "request_error"
	
	local_accounts_data = accounts
	
	for account in accounts:
		if (account.nick == user_name):
			var level_code = str(int(Online.local_loaded_level_data.id))
			var dir = {}
			if (account.levels_interacted != null):
				dir = account.levels_interacted
				if (level_code in dir):
					return "success"
			
			var send_data = {}
			
			#Sending Data
			if (account.levels_interacted != null):
				send_data = {"levels_interacted": account.levels_interacted}
			else:
				send_data = {"levels_interacted": {}}
			
			send_data.levels_interacted[level_code] = {"played": true}
			var condition = ["nick", user_name]
			print("Updating account info of ", user_name)
			var result = yield(send_data_condition("accounts", send_data, condition), "completed")
			
			if (result == null):
				return null
			
			send_data = {"played": int(local_loaded_level_data.played)+1}
			condition = ["id", str(local_loaded_level_data.id)]
			print("Updating level info: ", local_loaded_level_data.name)
			result = yield(send_data_condition("levels", send_data, condition), "completed")
			
			if (result == null):
				return null
			
			#Updating local data
			result = yield(receive_data("levels"), "completed")
			if (result != null):
				for level in result:
					if (str(level.id) == str(local_loaded_level_data.id)):
						local_loaded_level_data = level
						print("Updated local level data")
						break
			else:
				print("Could not update local level data")
				return null
			
			result = yield(receive_data("accounts"), "completed")
			if (result != null):
				local_accounts_data = result
				print("Updated local accounts data")
			else:
				print("Could not update local level data")
				return null
			
			if (result == null):
				return null
			return "success"

func add_level_clear():
	print("Requesting add level clear...")
	var accounts = yield(receive_data("accounts"), "completed")
	
	if (accounts == null):
		return "request_error"
	
	local_accounts_data = accounts
	
	for account in accounts:
		if (account.nick == user_name):
			var level_code = str(int(Online.local_loaded_level_data.id))
			var dir = {}
			if (account.levels_interacted != null):
				dir = account.levels_interacted
				if (level_code in dir):
					if ("clear" in dir[level_code]):
						return "success"
			
			var send_data = {}
			
			#Sending Data
			if (account.levels_interacted != null):
				send_data = {"levels_interacted": account.levels_interacted}
			else:
				send_data = {"levels_interacted": {}}
			
			var r = find_for_str_in_array_dir(local_accounts_data, user_name)
			if (r == -1):
				print("User ", user_name," not found in local account data")
				return
			send_data.levels_interacted[level_code] = {"clear": true}
			if (local_loaded_level_data.data.user != user_name):
				send_data.finished_levels = int(local_accounts_data[r].finished_levels)+1
			var condition = ["nick", user_name]
			print("Updating account info of ", user_name)
			var result = yield(send_data_condition("accounts", send_data, condition), "completed")
			
			if (result == null):
				return null
			
			send_data = {"clear": int(local_loaded_level_data.clear)+1}
			condition = ["id", str(local_loaded_level_data.id)]
			print("Updating level info: ", local_loaded_level_data.name)
			result = yield(send_data_condition("levels", send_data, condition), "completed")
			
			if (result == null):
				return null
			
			#Updating local data
			result = yield(receive_data("levels"), "completed")
			if (result != null):
				for level in result:
					if (str(level.id) == str(local_loaded_level_data.id)):
						local_loaded_level_data = level
						print("Updated local level data")
						break
			else:
				print("Could not update local level data")
				return null
			
			result = yield(receive_data("accounts"), "completed")
			if (result != null):
				local_accounts_data = result
				print("Updated local accounts data")
			else:
				print("Could not update local level data")
				return null
			
			if (result == null):
				return null
			return "success"

func add_death():
	print("Requesting add death...")
	var accounts = yield(receive_data("accounts"), "completed")
	
	if (accounts == null):
		return "request_error"
	
	local_accounts_data = accounts
	
	for account in accounts:
		if (account.nick == user_name):
			var level_code = str(int(Online.local_loaded_level_data.id))
			
			var send_data = {}
			
			#Sending Data
			send_data = {"deaths": int(local_loaded_level_data.deaths)+1}
			var condition = ["id", str(local_loaded_level_data.id)]
			print("Updating level info: ", local_loaded_level_data.name)
			var result = yield(send_data_condition("levels", send_data, condition), "completed")
			
			if (result == null):
				return null
			
			#Updating local data
			result = yield(receive_data("levels"), "completed")
			if (result != null):
				for level in result:
					if (str(level.id) == str(local_loaded_level_data.id)):
						local_loaded_level_data = level
						print("Updated local level data")
						break
			else:
				print("Could not update local level data")
				return null
			return "success"

func add_like():
	print("Requesting add like...")
	var accounts = yield(receive_data("accounts"), "completed")
	
	if (accounts == null):
		return "request_error"
	
	local_accounts_data = accounts
	
	for account in accounts:
		if (account.nick == Online.user_name):
			var level_code = str(int(Online.local_loaded_level_data.id))
			var dir = {}
			if (account.levels_interacted != null):
				dir = account.levels_interacted
				if (level_code in dir):
					if ("reacted" in dir[level_code]):
						return
			
			var send_data = {}
			
			#Sending Data
			if (account.levels_interacted != null):
				send_data = {"levels_interacted": account.levels_interacted}
			else:
				send_data = {"levels_interacted": {}}
			
			send_data.levels_interacted[level_code]["reacted"] = "like"
			var condition = ["nick", user_name]
			print("Updating account info of ", user_name)
			var result = yield(send_data_condition("accounts", send_data, condition), "completed")
			
			if (result == null):
				return null
			
			send_data = {"likes": int(local_loaded_level_data.likes)+1}
			condition = ["id", str(local_loaded_level_data.id)]
			print("Updating level info: ", local_loaded_level_data.name)
			result = yield(send_data_condition("levels", send_data, condition), "completed")
			
			if (result == null):
				return null
			
			#Updating local data
			result = yield(receive_data("levels"), "completed")
			if (result != null):
				for level in result:
					if (str(level.id) == str(local_loaded_level_data.id)):
						local_loaded_level_data = level
						print("Updated local level data")
						break
			else:
				print("Could not update local level data")
				return null
			
			result = yield(receive_data("accounts"), "completed")
			if (result != null):
				local_accounts_data = result
				print("Updated local accounts data")
			else:
				print("Could not update local level data")
				return null
			
			if (result == null):
				return null
			return "success"

func add_dislike():
	print("Requesting add dislike...")
	var accounts = yield(receive_data("accounts"), "completed")
	
	if (accounts == null):
		return "request_error"
	
	local_accounts_data = accounts
	
	for account in accounts:
		if (account.nick == Online.user_name):
			var level_code = str(int(Online.local_loaded_level_data.id))
			var dir = {}
			if (account.levels_interacted != null):
				dir = account.levels_interacted
				if (level_code in dir):
					if ("reacted" in dir[level_code]):
						return
			
			var send_data = {}
			
			#Sending Data
			if (account.levels_interacted != null):
				send_data = {"levels_interacted": account.levels_interacted}
			else:
				send_data = {"levels_interacted": {}}
			
			send_data.levels_interacted[level_code]["reacted"] = "dislike"
			var condition = ["nick", user_name]
			print("Updating account info of ", user_name)
			var result = yield(send_data_condition("accounts", send_data, condition), "completed")
			
			if (result == null):
				return null
			
			send_data = {"dislikes": int(local_loaded_level_data.dislikes)+1}
			condition = ["id", str(local_loaded_level_data.id)]
			print("Updating level info: ", local_loaded_level_data.name)
			result = yield(send_data_condition("levels", send_data, condition), "completed")
			
			if (result == null):
				return null
			
			#Updating local data
			result = yield(receive_data("levels"), "completed")
			if (result != null):
				for level in result:
					if (str(level.id) == str(local_loaded_level_data.id)):
						local_loaded_level_data = level
						print("Updated local level data")
						break
			else:
				print("Could not update local level data")
				return null
			
			result = yield(receive_data("accounts"), "completed")
			if (result != null):
				local_accounts_data = result
				print("Updated local accounts data")
			else:
				print("Could not update local level data")
				return null
			
			if (result == null):
				return null
			return "success"

func publish_level(level: String):
	print("Requesting publish level...")
	
	var f = File.new()
	f.open_encrypted_with_pass(level, File.READ, Global.SECURITY_KEY);
	var content = f.get_as_text();
	f.close()
	var json = JSON.parse(content)
	var level_data = json.result;
	level_data.user = user_name
	
	var levels = yield(send_data("levels", {"name": Global.currentCourseName, "data": level_data}), "completed")
	
	if (levels == null):
		print("Couldn't publish level: ", Global.currentCourseName)
		return "request_error"
	else:
		print("Published level: ", Global.currentCourseName, " to Wonder Maker Online server")
		return "success"

func http_finished(data):
	var request_type
	var request_tree
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

func internal_check_request():
	yield(get_tree().create_timer(1.0), "timeout")
	if (check_request()):
		var val_to_send = request_data; request_data = null; return val_to_send
	else:
		yield(get_tree().create_timer(1.0), "timeout")
		if (check_request()):
			var val_to_send = request_data; request_data = null; return val_to_send
		else:
			yield(get_tree().create_timer(1.0), "timeout")
			if (check_request()):
				var val_to_send = request_data; request_data = null; return val_to_send
			else:
				yield(get_tree().create_timer(1.0), "timeout")
				if (check_request()):
					var val_to_send = request_data; request_data = null; return val_to_send
				else:
					yield(get_tree().create_timer(1.0), "timeout")
					if (check_request()):
						var val_to_send = request_data; request_data = null; return val_to_send
					else:
						yield(get_tree().create_timer(1.0), "timeout")
						if (check_request()):
							var val_to_send = request_data; request_data = null; return val_to_send
						else:
							yield(get_tree().create_timer(1.0), "timeout")
							if (check_request()):
								var val_to_send = request_data; request_data = null; return val_to_send
							else:
								yield(get_tree().create_timer(1.0), "timeout")
								if (check_request()):
									var val_to_send = request_data; request_data = null; return val_to_send
								else:
									yield(get_tree().create_timer(1.0), "timeout")
									if (check_request()):
										var val_to_send = request_data; request_data = null; return val_to_send
									else:
										print("ERROR: The request didn't work")
										return null

func check_request():
	if (request_data == null):
		print("Waiting...")
		return false
	else:
		print("Request successful")
		return true

func find_for_str_in_array_dir(array: Array, name: String) -> int:
	for i in range(array.size()):
		var element = array[i]
		if ("nick" in element):
			if (element["nick"] == name):
				return i
	return -1
