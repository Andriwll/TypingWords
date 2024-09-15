# Global.gd
extends Node

# Variavéis Globbais
var word_dict = {}
var player_data = {}

# Função para salvar os dados do jogador.
func save_player_data(player_name: String, player_score: int) -> void:
	var config = ConfigFile.new()
	var previous_score = 0

	# Carregar os dados existentes
	if config.load("user://save_pontos.dat") == OK:
		previous_score = config.get_value("player_data", player_name, 0)

	# Salvar a pontuação somente se ela for maior que a anterior
	if player_score > previous_score:
		player_data[player_name] = player_score
		config.set_value("player_data", player_name, player_data[player_name])
		config.save("user://save_pontos.dat")

# Função para carregar os dados do jogador
func load_player_data() -> void:
	var config = ConfigFile.new()
	if config.load("user://save_pontos.dat") == OK:
		player_data.clear()  # Limpar dados existentes
		var keys = config.get_section_keys("player_data")
		for key in keys:
			player_data[key] = config.get_value("player_data", key, 0)

# Salva as palavras descobertas nos arquivos do usuário.
func save_dict():
	print("Saving dictionary. Current content:", word_dict)
	var config = ConfigFile.new()
	config.set_value("words", "translations", word_dict)
	var err = config.save("user://save_game.dat")
	if err == OK:
		print("Dictionary saved successfully")
	else:
		print("Error saving dictionary:", err)

# Carregas as palavras descobertas nos arquivos do usuário.
func load_dict():
	var config = ConfigFile.new()
	var err = config.load("user://save_game.dat")
	if err == OK:
		word_dict = config.get_value("words", "translations", {})
		print("Loaded dictionary:", word_dict)
	else:
		print("Error loading dictionary:", err)
