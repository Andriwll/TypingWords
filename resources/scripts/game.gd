extends Control

# Variáveis
var difficulty = "fácil" # Pode ser "facil", "normal" ou "dificil"
var score =  0
var currentText = "" # Variável para rastrear o texto atual do LineEdit
var currentWord = ""
var currentTranslation = "" # Tradução da palavra inicial
var similarityThreshold = 0  # Ajuste o limite de similaridade conforme necessário
var died
var player = ""
var tempo_corrido = 0.0


var shake_amplitude = 35  # Ajustar esse valor para controlar a intensidade dos efeitos de tremida
var shake_speed = 10  # Ajustar esse valor para controlar a velocidade dos efeitos de tremida
var deltaShake = 1
var countdowndone = false
var finished = 0

# Nódulos que são Iniciados juntos da cena (Tela).
@onready var back_panel = $game/backPanel
@onready var back_diff = $game/backDiff
@onready var game = $game
@onready var lose_popup = $losePopup
@onready var label_dificuldade = $game/labelDificuldade
@onready var label_english = $game/backPanel/labelEnglish
@onready var response_edit = $game/backPanel/responseEdit
@onready var label_ptbr = $game/backPanel/labelPTBR
@onready var label_time = $game/labelTime
@onready var label_pontos = $game/labelPontos
@onready var tempo = $game/Tempo
@onready var check = $game/Tempo/check
@onready var play_but = $losePopup/HBoxContainer/playBut
@onready var menu_but = $losePopup/HBoxContainer/menuBut
@onready var lose_appear = $losePopup/loseAppear
@onready var correct_sound = $game/correctSound
@onready var click = $losePopup/click
@onready var name_popup = $namePopup
@onready var name_appear = $namePopup/nameAppear
@onready var name_edit = $namePopup/nameEdit
@onready var contagem_label = $contagemLabel
@onready var parar_particula = $game/vitoriaPart/pararParticula
@onready var particle_fade = $game/vitoriaPart/particleFade
@onready var contagem = $game/Contagem
@onready var vitoria_part = $game/vitoriaPart
@onready var countdown = $game/countdown
@onready var label_countdown = $game/labelCountdown
@onready var spin = $game/spin

# Variável que salva todas as palavras do jogo
var words = {}

# Função que é iniciada no começo que a cena é instanciada.
func _ready():
	countdowndone = false
	difficulty_change()
	Global.load_dict()
	Global.load_player_data()
	var file_path = "res://words.txt"
	load_words_from_file(file_path)
	#print(words)  # Verifica se as palavras foram carregadas corretamente
	lose_popup.visible = false
	new_word() # Inicializa o jogo com uma palavra aleatória
	start_game() # Inicia diversas informações do jogo, também utilizado para jogar novamente.
	response_edit.grab_focus()

# Função para calcular a distância de diferença entre duas strings
func levenshtein_distance(a: String, b: String) -> int:
	var matrix = []
	for i in range(a.length() + 1):
		matrix.append([])
		for j in range(b.length() + 1):
			if i == 0:
				matrix[i].append(j)
			elif j == 0:
				matrix[i].append(i)
			else:
				var cost = 0
				if a[i - 1] != b[j - 1]:
					cost = 1
				var delete_cost = matrix[i - 1][j] + 1
				var insert_cost = matrix[i][j - 1] + 1
				var replace_cost = matrix[i - 1][j - 1] + cost
				matrix[i].append(min(delete_cost, insert_cost, replace_cost))
	
	return matrix[a.length()][b.length()]

# Correção da inserção do usuário baseado na palavra que deve ser traduzida
func correct():
	var inputText = response_edit.text.strip_edges()
	var distance = levenshtein_distance(inputText, currentWord)
	if distance == similarityThreshold:
		score += 100
		update_score()
		set_timer_time()
		
		# Adicione esta linha para salvar a palavra atual no dicionário global
		Global.word_dict[currentWord] = currentTranslation
		
		Global.save_dict()
		new_word()
		correct_sound.play()
		shake_node(label_english)
		vitoria_part.emitting = true
		parar_particula.start()
		particle_fade.play("disappear")
		await particle_fade.animation_finished
		particle_fade.play("RESET")
		
		died = false
	else:
		died = true

# Função que finaliza o jogo ao pressionar a tecla escape.
func playerInput():
	if Input.is_action_pressed("ui_cancel") and died == true:
		tempo.stop()
		_on_tempo_timeout()

# Chamada a cada frame do aplicativo.
func _physics_process(delta):
	print("Current Global.word_dict:", Global.word_dict)
	
	# Contagem do jogo sendo arredondada e então convertida em texto
	label_countdown.text = str(round(countdown.time_left))
	
	# Tempo do tempo jogado começando apenas após do fim do contador de 3 segundos.
	if countdowndone == true:
		tempo_corrido += 1.0 * delta
	deltaShake = delta
	
	# Atualizar posições e a contagem do jogo antes dele começar
	contagem_label.text = str(round(contagem.time_left))
	response_edit.position = label_english.position
	contagem_color()
	playerInput()
	show_time()
	
# Função para mudar a dificuldade do jogo com base no tempo.
func difficulty_change():
	if tempo_corrido == 0:
		difficulty = "fácil"
	elif round(tempo_corrido) >= 40 and round(tempo_corrido) < 40.1:
		difficulty = "normal"
	elif round(tempo_corrido) >= 80 and round(tempo_corrido) < 80.1:
		difficulty = "difícil"

	label_dificuldade.text = difficulty

# Colocar o temporizador com o tempo baseado na dificuldade
func set_timer_time():
	if difficulty == "fácil":
		# Dificuldade fácil - 10 segundos (10000 milissegundos)
		tempo.wait_time = 14.0
	elif difficulty == "normal":
		# Dificuldade normal - 5 segundos (5000 milissegundos)
		tempo.wait_time = 8.0
	elif difficulty == "difícil":
		# Dificuldade difícil - 2 segundos (2000 milissegundos)
		tempo.wait_time = 6.0
	elif difficulty == "dead":
		# Dificuldade desconhecida - defina um valor padrão aqui
		tempo.wait_time = 0
	
	# Reinicie o timer com o novo tempo
	tempo.start()

# Mostrar o tempo restante do temporizador do jogo.
func show_time():
	var tempo_restante = tempo.time_left
	tempo_restante = round(tempo_restante)
	label_time.text = str(tempo_restante)


# Função para atualizar a pontuação na interface
func update_score():
	label_pontos.text = str(score)

# Função para escolher uma nova palavra aleatória
var last_word = ""
func new_word():
	var valid_keys = get_valid_keys()
	if valid_keys.size() == 0:
		print("Nenhuma palavra disponível para esta dificuldade.")
		return
	
	# Uma palavra aleatória com base na dificuldade.
	var random_index = randi() % valid_keys.size()
	currentWord = valid_keys[random_index]

	# Garantindo que não é a mesma palavra que já foi digitada
	while currentWord == last_word and valid_keys.size() > 1:
		random_index = randi() % valid_keys.size()
		currentWord = valid_keys[random_index]

	# Inserção da palavra que já foram, a palavra que vai ser e atualizando isso nos rótulos da tela.
	last_word = currentWord
	currentTranslation = words[currentWord]
	label_english.text = currentWord
	label_ptbr.text = currentTranslation
	response_edit.text = ""

# Função para obter chaves válidas com base na dificuldade e número de caracteres por palavra.
func get_valid_keys():
	var valid_keys = []
	for word in words.keys():
		match difficulty:
			"fácil":
				if word.length() >= 4 and word.length() <= 5:
					valid_keys.append(word)
			"normal":
				if word.length() >= 6 and word.length() <= 7:
					valid_keys.append(word)
			"difícil":
				if word.length() >= 8:
					valid_keys.append(word)
	return valid_keys

# Carregando as palavras para o dicionário (tipo primitivo) com base num arquivo de texto com todas as palavras.
func load_words_from_file(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		words.clear()
		while not file.eof_reached():
			var line = file.get_line()
			var parts = line.split(":")
			if parts.size() == 2:
				words[parts[0]] = parts[1]
		file.close()
	else:
		print("Erro ao abrir o arquivo para leitura.")

# Função para universal para tremer alguns nódulos
func shake_node(node: Node, radius: float = 30.0):
	var original_position = node.position
	var noise = FastNoiseLite.new()  # Instancia o FastNoiseLite
	noise.seed = randi()  # Escolhe uma seed específica
	noise.frequency = 10  # Ajusta a frequência do ruído
	var timer = get_tree().create_timer(0.1)  # Ajusta o intevalo do temporizador em que a tremida vai acontecer
	var elapsed_time: float = 0.0

	# Ativando a tremida.
	var noise_x = noise.get_noise_2d(elapsed_time, 300.0)
	var noise_y = noise.get_noise_2d(elapsed_time + 300.0, 0.0)
	var shake_amount = Vector2(noise_x, noise_y) * radius
	node.position = original_position + shake_amount
	elapsed_time += timer.time_left
	await timer.timeout
	# Reiniciar posição após tremida
	node.position = original_position

# Inicia diversas informações do jogo, também utilizado para jogar novamente.
func start_game():
	finished = 0 # Finaliza paramtros para a animação spin.
	spin.play("RESET")
	var contagemAudio = $AudioStreamPlayer # Áudio da contagem.
	contagemAudio.play()
	game.visible = false # Deixa o jogo invisível durante a contagem
	contagem_label.visible = true
	contagem.start(3)
	check.stop()
	

# Função para modificação das cores da contagem regressiva.
func contagem_color():
	var _contagemLabel = $contagemLabel
	if round(contagem.time_left) == 3:
		contagem_label.add_theme_color_override("font_color", Color.GREEN)
	elif round(contagem.time_left) == 2:
		contagem_label.add_theme_color_override("font_color", Color.YELLOW)
	elif round(contagem.time_left) == 1:
		contagem_label.add_theme_color_override("font_color", Color.RED)

# Tempo do jogo finalizando o jogo e chamando as telas de fim de jogo.
func _on_tempo_timeout():
	if died:
		tempo.stop()
		lose_popup.visible = true
		countdown.stop()
		lose_appear.play("appear")
		name_appear.play("appear")
		response_edit.visible = false
		name_popup.visible = true
		name_edit.grab_focus()

# Checagem se o jogo a cada milisegundo se o tempo acabou e a palavra não foi digitada.
func _on_check_timeout():
	difficulty_change()
	if tempo.wait_time == 0:
		_on_tempo_timeout()
	correct()
	

# Personalização do texto inserido pelo usuário com base no número de caracteres inseridos.
func _on_response_edit_text_changed(_new_text):
	var sound = AudioStreamPlayer.new()
	sound.pitch_scale = randf_range(0.8, 1)
	response_edit.add_child(sound)
	sound.stream = load("res://resources/sounds/typing.wav")
	sound.play()
	shake_node(response_edit)
	
	# Altere a cor de response_edit com base na proximidade da palavra atual
	var color_close = Color.GREEN  # Verde quando está perto
	color_close.a = 1.0
	var color_far = Color.RED  # Vermelho quando está longe
	color_far.a = 1.0

	var t = 0.0
	if currentWord.length() != 0:
		t = float(response_edit.text.length()) / float(currentWord.length())  # Normalizar o comprimento

	var color_result = color_far.lerp(color_close, t)
	color_result.a = 1.0  # Garantir que a cor do resultado seja completamente opaca
	response_edit.add_theme_color_override("font_color", color_result)
	
	# Quando o jogo finaliza ele salva as palavras com a função global save_dict() e pontuação e usuário com a
	# funcão save_player_data()
	
func _exit_tree():
	Global.save_dict()
	Global.save_player_data(player, score)

# Código do botão de jogar novamente na tela de fim de jogo.
func _on_play_but_pressed():
	click.play()
	difficulty = "fácil"
	score = 0
	response_edit.visible = true
	response_edit.grab_focus()
	_ready()

# Código do botão de menu na tela de fim de jogo.
func _on_menu_but_pressed():
	click.play()
	await click.finished
	get_tree().change_scene_to_file("res://resources/cenes/menu.tscn")

# Código quando o nome do usuário da partida é digitado e enter é pressionado.
func _on_name_edit_text_submitted(new_text):
	click.play()
	player = new_text.to_lower().left(3)
	name_edit.clear()
	Global.save_player_data(player, score)
	name_popup.visible = false
	menu_but.grab_focus()
	#print(Global.player_data)

# Código de quando a contagem regressiva é finelizada, inicializando o jogo após finalizar a contagem regressiva.
func _on_contagem_timeout():
	countdowndone = true
	countdown.start()
	game.visible = true
	contagem_label.visible = false
	check.start()
	set_timer_time()
	contagem.stop()

# Código para que a partícula de vitória desapareça.
func _on_parar_particula_timeout():
	vitoria_part.emitting = false
	parar_particula.stop()

# Finalização da contagem regressiva para mudança de dificuldade. Mudando duas vezes apenas.
func _on_countdown_timeout():
	finished += 1
	
	if finished == 1 or finished == 2:
		spin.play("spin")
		await spin.animation_finished
		spin.play("RESET")
		if finished == 2:
			spin.play("fadeout")
	
	if finished > 2:
		spin.stop()
		
