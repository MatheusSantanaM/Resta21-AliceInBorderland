extends Control

# Variáveis globais para armazenar as seleções
var player_a_character: int = 0
var player_b_character: int = 0

var characters_data: Dictionary = {
	1: {"name": "Arisu", "icon": "res://Characters/Arisu.jpg", "passive": "Último Segundo"},
	2: {"name": "Usagi", "icon": "res://Characters/Usagi.jpg", "passive": "Esquiva Reflexa"},
	3: {"name": "Chishiya", "icon": "res://Characters/Chishiya.jpg", "passive": "Previsão de Cartas"},
	4: {"name": "Mira", "icon": "res://Characters/Mira.jpg", "passive": "Chá das Quatro"}
}

# Retorna os dados completos do personagem do Jogador A
func get_player_a_data() -> Dictionary:
	return characters_data.get(player_a_character, {})

# Retorna os dados completos do personagem do Jogador B
func get_player_b_data() -> Dictionary:
	return characters_data.get(player_b_character, {})

@onready var board = get_node_or_null('Board')
@onready var end_game_screen = get_node_or_null('EndGame')
@onready var hand_board = get_node_or_null('hand')
@onready var current_player = player_1 if player_active else player_2
@onready var skill_label: Label = $SkillLabel
var player_1 : Player
var player_2 : Player
var player_1_continue = true
var player_2_continue = true
var player_active = true
var skill_message: String = ""
var deck : Array
var score_antigo:int = 0
func generate_deck():
	var cards = []
	var houses = ["Paus", "Espadas", "Ouro", "Copas"]
	
	for np in houses:
		for i in range(1, 14):
			cards.append( Card.new(i, np) )
	return cards

func updateBoard():
	if not is_instance_valid(board):
		return
		
	var current_player = player_1 if player_active else player_2
	if current_player.character_id == 3:
		var carta_propria = "Nenhuma"
		var carta_oponente = "Nenhuma"

		if deck.size() >= 1:
			carta_propria = str(deck[0].get_value())
		if deck.size() >= 2:
			carta_oponente = str(deck[1].get_value())
		skill_message = "[HABILIDADE] Chishiya prevê: sua próxima carta será " + carta_propria + ", a do oponente será " + carta_oponente + "."

	var nome_1 = player_1.character_data.get("name", player_1.player_name)
	var nome_2 = player_2.character_data.get("name", player_2.player_name)
	var nome_atual = nome_1 if player_active else nome_2

	board.text = 'Vez de ' + nome_atual
	board.text += ' | ' + nome_1 + ' - ' + str(player_1.score) + ' pontos '
	board.text += ' | ' + nome_2 + ' - ' + str(player_2.score) + ' pontos '
	
	board.text += '\n' + player_1.show_hands()
	board.text += '\n' + player_2.show_hands()
	
	if skill_message != "":
		skill_label.text = skill_message
		skill_label.show()
	else:
		skill_label.text = ""
		skill_label.hide()

func end_game():
	if not is_instance_valid(board):
		return
	var result = ''
	if( player_1.score == player_2.score ):
		result = 'Os jogadores optaram por empate'
	elif( player_1.score > 21 ):
		result = player_2.player_name
	elif( player_2.score > 21 ):
		result = player_1.player_name
	elif(player_1.score > player_2.score ):
		result = player_1.player_name
	else:
		result = player_2.player_name
	
	end_game_screen.text = result + ' venceu!!'

func _ready():
	if not is_instance_valid(board):
		return

	player_1 = Player.new("Jogador A", Global.player_a_character)
	player_2 = Player.new("Jogador B", Global.player_b_character)
	print("Jogador A - ID selecionado: ", player_1.character_id)
	print("Jogador B - ID selecionado: ", player_2.character_id)
	print('Gerando baralho')
	
	deck = generate_deck()
	
	print('Embaralhando')
	deck.shuffle()

	print('Entregando duas cartas para cada jogador')
	board.text += ''
	apply_character_passives(player_1)
	apply_character_passives(player_2)
	updateBoard()
func apply_character_passives(p: Player) -> void:
	if not is_instance_valid(p):
		return

	skill_message = "" 
	
	if p.character_id == 1 and p.hand.size() > 0:
		var carta_antiga = p.hand.pop_back()
		p.score -= carta_antiga.get_value()
		if is_instance_valid(hand_board) and is_instance_valid(carta_antiga.interface):
			hand_board.remove_child(carta_antiga.interface)

		if p.score <= 16 and randf() <= 0.5:
			var valor_necessario = 21 - p.score
			var index_carta = -1

			if valor_necessario > 0 and valor_necessario <= 13:
				for i in range(deck.size()):
					if deck[i].get_value() == valor_necessario:
						index_carta = i
						break

			if index_carta != -1:
				deck.append(carta_antiga)
				var carta_perfeita = deck.pop_at(index_carta)
				p.hand.append(carta_perfeita)
				p.score += carta_perfeita.get_value()

				if is_instance_valid(hand_board):
					hand_board.add_child(carta_perfeita.interface)
					if p == player_1:
						carta_perfeita.interface.position.x = (len(p.hand) - 1) * 150
						if carta_perfeita.interface.has_node("paper"):
							carta_perfeita.interface.get_node("paper").size.y = 220
					else:
						carta_perfeita.interface.position.y = 230
						carta_perfeita.interface.position.x = (len(p.hand) - 1) * 150

				skill_message = "[HABILIDADE] Visão Lógica! Arisu achou a carta " + str(valor_necessario) + " e cravou 21!"
				print("CONSOLE: Arisu cravou 21 com a carta de valor ", valor_necessario)
				return
			else:
				p.hand.append(carta_antiga)
				p.score += carta_antiga.get_value()
				if is_instance_valid(hand_board) and is_instance_valid(carta_antiga.interface):
					hand_board.add_child(carta_antiga.interface)
		else:
			p.hand.append(carta_antiga)
			p.score += carta_antiga.get_value()
			if is_instance_valid(hand_board) and is_instance_valid(carta_antiga.interface):
				hand_board.add_child(carta_antiga.interface)
	# 2: Usagi - Esquiva Reflexa
	if p.character_id == 2 and p.score > 21:
		if p.hand.size() > 0:
			var last_card = p.hand.pop_back()
			if is_instance_valid(hand_board) and is_instance_valid(last_card.interface):
				hand_board.remove_child(last_card.interface)
			p.score -= last_card.get_value()
			deck.append(last_card)
			
			print("CONSOLE: Habilidade Usagi ativada!")
			skill_message = "[HABILIDADE] Usagi esquivou do estouro! Carta devolvida."

	# 4: Mira - Chá das Quatro
	elif p.character_id == 4 and p.score > 21:
		score_antigo = p.score
		p.score = 21
		print("CONSOLE: Habilidade Mira ativada!")
		skill_message = "[HABILIDADE] Mira: Pontuação ajustada de "+ str(score_antigo)+ " para 21!"

func _on_puxar_button_up() -> void:
	# 1. Definir quem é o jogador atual logo no início
	var current_player = player_1 if player_active else player_2

	# 2. A sua lógica visual original para adicionar as cartas ao ecrã
	if( player_active ):
		player_1.take_card( deck )
		hand_board.add_child(player_1.hand[-1].interface)
		player_1.hand[-1].interface.position.x = (len(player_1.hand)-1)*150
		player_1.hand[-1].interface.get_node('paper').size.y = 220
	else:
		player_2.take_card( deck )
		player_2.hand[-1].interface.position.y = 230
		player_2.hand[-1].interface.position.x = (len(player_2.hand)-1)*150 
		hand_board.add_child(player_2.hand[-1].interface)
		
	# 3. Aplicar as habilidades passivas (agora o current_player está definido e a carta já foi contabilizada no take_card)
	apply_character_passives(current_player)
	
	if( player_1.score == 21 or player_2.score == 21 ):
		end_game()
	elif( player_1.score < 22 and player_2.score < 22 ):
		player_active = not player_active
	else:
		end_game()
		
	updateBoard()

func _on_manter_button_up() -> void:
	
	if( player_active):
		player_1_continue = false
	else:
		player_2_continue = false
	if( not player_1_continue and not player_2_continue ):
		end_game()
	player_active = not player_active
	updateBoard()


func _on_btn_reset_button_up() -> void:
	# limpar as mãos dos jogadores
	player_1.reset( hand_board, deck )
	player_2.reset( hand_board, deck )
	
	print('Gerando baralho')
	deck = generate_deck()
	
	print('Embaralhando')
	deck.shuffle()
	player_active = true
	player_1_continue = true
	player_2_continue = true
	end_game_screen.text = ''
	
	updateBoard()


func _on_btn_character_select_button_up() -> void:
	player_1.reset( hand_board, deck )
	player_2.reset( hand_board, deck )
	
	updateBoard()
	get_tree().change_scene_to_file("res://player.tscn")
