extends Node

var SUPABASE_URL: String = ""
var SUPABASE_KEY: String = ""
var headers: Array = []

func _ready():
	SUPABASE_URL = "https://wpatttjduqxigjcrprwa.supabase.co"
	SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndwYXR0dGpkdXF4aWdqY3JwcndhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxMTczNTQsImV4cCI6MjA1OTY5MzM1NH0.P7qkEBRlrj26VZE4rxjvB3jy4P09jZo4p4cD8OUfnXo"
	headers = [
		"Content-Type: application/json",
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY
	]

func get_value(table: String, column: String, condition: Dictionary, http_request: HTTPRequest, tree: Node):
	var endpoint = SUPABASE_URL + "/rest/v1/" + table
	endpoint += "?select=" + column
	endpoint += "&" + condition.keys()[0] + "=eq." + str(condition.values()[0])
	
	var error = http_request.request(endpoint, headers, HTTPClient.METHOD_GET)
	if error != OK:
		return null
	
	var result = yield(http_request, "request_completed")
	var response_body = result[3].get_string_from_utf8()
	var json = JSON.new()
	json.parse(response_body)
	
	if json.get_data() is Array and json.get_data().size() > 0:
		tree.http_finished(json.get_data()[0].get(column))
		return
	else:
		return null

func insert_row(table: String, data: Dictionary, http_request: HTTPRequest) -> void:
	var endpoint = SUPABASE_URL + "/rest/v1/" + table
	var json_data = JSON.stringify(data)
	
	var error = http_request.request(endpoint, headers, HTTPClient.METHOD_POST, json_data)
	if error != OK:
		push_error("Error al insertar fila")

func set_value(table: String, column: String, value, condition: Dictionary, http_request: HTTPRequest) -> void:
	# Construye el endpoint con la condición (ej: "id=eq.5")
	var endpoint = SUPABASE_URL + "/rest/v1/" + table
	endpoint += "?" + condition.keys()[0] + "=eq." + str(condition.values()[0])
	
	# Crea el payload con el valor a actualizar
	var data = { column: value }
	var json_data = JSON.stringify(data)
	
	# Envía la solicitud PATCH
	var error = http_request.request(endpoint, headers, HTTPClient.METHOD_PATCH, json_data)
	if error != OK:
		push_error("Error al actualizar el valor")
	
	yield(http_request, "request_completed")

func fetch_all_rows(table: String, http_request: HTTPRequest, tree: Node):
	var endpoint = SUPABASE_URL + "/rest/v1/" + table + "?select=*"  # Selecciona todas las columnas
	var error = http_request.request(endpoint, headers, HTTPClient.METHOD_GET)
	
	#var result = await http_request.request_completed
	#var response_body = result[3].get_string_from_utf8()
	#var response_code = result[1]
	
	if error != OK:
		push_error("Error al obtener las filas")
	else:
		var json = JSON.new()
		#var parse_error = json.parse(response_body)
		
		#if parse_error != OK:
		#	push_error("Error al parsear JSON: ", json.get_error_message())
		#	return
		
		var data = json.get_data()
		
		#if response_code == 200:
		#	if data is Array and data.size() > 0:
				#print("Filas obtenidas:")
				#for row in data:
					#print("-> ", row)  # Muestra cada fila en la consola
				#list_levels(data)
		#		tree.http_finished(data)
		#		return
		#	else:
		#		print("La tabla está vacía")
		#else:
		#	push_error("Error HTTP ", response_code, ": ", response_body)
		#	tree.http_finished(null)

func delete_row(table: String, id: int, http_request: HTTPRequest) -> void:
	# Construye el endpoint con el ID de la fila a eliminar
	var endpoint = SUPABASE_URL + "/rest/v1/" + table + "?id=eq." + str(id)
	
	# Envía la solicitud DELETE
	var error = http_request.request(endpoint, headers, HTTPClient.METHOD_DELETE)
	if error != OK:
		push_error("Error al enviar DELETE")
