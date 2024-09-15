extends Control

# Variáveis inicializadas no início da cena.
@onready var main_menu = $mainMenu
@onready var margin_container = $dictionary/backPanel/ScrollContainer/MarginContainer
@onready var v_box_container = $dictionary/backPanel/ScrollContainer/MarginContainer/VBoxContainer
@onready var jogar_but = $mainMenu/VBoxContainer/jogarBut
@onready var opcoes_but = $mainMenu/VBoxContainer/opcoesBut
@onready var sair_but = $mainMenu/VBoxContainer/sairBut
@onready var dici_but = $diciBut
@onready var title_label_1 = $mainMenu/titleLabel1
@onready var sound_player = $soundPlayer
@onready var animation_player = $mainMenu/titleLabel1/AnimationPlayer
@onready var dictionary = $dictionary
@onready var back_panel = $dictionary/backPanel
@onready var label_pontos = $dictionary/ScrollContainer2/VBoxContainer/labelPontos

# Chamado quando o nó entra na árvore de cena pela primeira vez.
func _ready():
	Global.load_dict()
	Global.load_player_data()
	animation_player.play("moving")
	jogar_but.grab_focus()
	
	# Chama todas as palavras que foram vistas nas jogatinas.
	for key in Global.word_dict:
		add_word_to_dict(key, Global.word_dict[key])
	
	# As organiza de maneira alfabética.
	var sorted_keys = Global.player_data.keys()
	sorted_keys.sort_custom(func(a, b): return int(Global.player_data[a]) > int(Global.player_data[b])) # Classificar chaves em ordem decrescente

	# Chama a pontuação, e a salva em um rótulo de texto.
	for key in sorted_keys:
		var line = "[center]" + str(key) + " - " + str(Global.player_data[key]) + "\n" + "[/center]"
		label_pontos.append_text(line)

# Quando o botão de jogar é pressionado e vai para a cena onde o jogo ocorre.
func _on_jogar_but_pressed():
	sound_player.play()
	jogar_but.disabled = true
	await sound_player.finished 
	get_tree().change_scene_to_file("res://resources/cenes/game.tscn")

# Botão de sair quando pressionado e sai do jogo.
func _on_sair_but_pressed():
	sound_player.play()
	await sound_player.finished 
	get_tree().quit()

# Código que modifica a visão do entre dicionário e menu.
func _on_dici_but_toggled(toggled_on):
	if toggled_on:
		sound_player.play()
		main_menu.visible = false
		dictionary.visible = true
		dici_but.text = "Voltar"
	else:
		sound_player.play()
		main_menu.visible = true
		dictionary.visible = false
		dici_but.text = "Dicionário"
	dici_but.grab_focus()

# Botão de controle de erros, criado para apagar as palavras obtidas e verificar se as palavras estaavm salvando.
func _on_del_button_pressed():
	Global.word_dict.clear()
	var dir = DirAccess.open("user://")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name == "save_game.dat":
				if dir.remove(file_name) == OK:
					print("File deleted successfully")
				else:
					print("Failed to delete file")
				break
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	
	# Limpar apenas os filhos de v_box_container
	for child in v_box_container.get_children():
		child.queue_free()

# Função personalizada para adicionar palavras ao dicionário com botões que tocam a pronúncia da palavra.
func add_word_to_dict(word, translation):
	
	# Criar um novo HBoxContainer
	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v_box_container.add_child(hbox)
	
	# Criar um novo rótulo
	var label = Label.new()
	label.text = word.capitalize() + " - " + translation.capitalize()
	label.set_theme(load("res://resources/themes/bartext.tres"))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hbox.add_child(label)

	# Criar um novo botão
	var button = Button.new()
	button.text = "Play"
	button.set_theme(load("res://resources/themes/bartext.tres"))
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	hbox.add_child(button)

	# Conecte o sinal "pressionado" do botão a uma função
	button.pressed.connect(_on_play_button_pressed.bind(word))

# Função que carrega os arquivos de som do jogo, com base no nome do arquivo e da palavra salva.
func _on_play_button_pressed(word):
	# Carregar o arquivo de som
	var sound = AudioStreamPlayer.new()
	var audio_path = "res://sounds/" + word
	if ResourceLoader.exists(audio_path + ".wav"):
		sound.stream = load(audio_path + ".wav")
	elif ResourceLoader.exists(audio_path + ".ogg"):
		sound.stream = load(audio_path + ".ogg")
	elif ResourceLoader.exists(audio_path + ".mp3"):
		sound.stream = load(audio_path + ".mp3")
	elif ResourceLoader.exists(audio_path + ".flac"):
		sound.stream = load(audio_path + ".flac")
	else:
		print("Audio file not found for word: " + word)
		return

	# Adicionar o reprodutor de som à cena
	add_child(sound)

	# Reproduzir o som
	sound.play()
