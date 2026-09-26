extends Node2D

# Nós de interface
@onready var character_a: MenuButton = $CharacterA
@onready var character_b: MenuButton = $CharacterB

# PopupMenus internos dos MenuButtons
var popup_a: PopupMenu
var popup_b: PopupMenu

# Lista com os dados dos personagens disponíveis
# O 'id' deve corresponder ao ID cadastrado nos itens do MenuButton
var characters = [
	{"id": 1, "name": "Arisu", "icon": "res://Characters/Arisu.jpg"}, # Ajuste o caminho das imagens
	{"id": 2, "name": "Usagi", "icon": "res://Characters/Usagi.jpg"},
	{"id": 3, "name": "Chishiya", "icon": "res://Characters/Chishiya.jpg"},
	{"id": 4, "name": "Mira", "icon": "res://Characters/Mira.jpg"}
]

# Variáveis para armazenar o ID do personagem selecionado por cada jogador
var player_a_char_id: int = 0
var player_b_char_id: int = 0

func _ready() -> void:
	popup_a = character_a.get_popup()
	popup_b = character_b.get_popup()
	setup_character_menus()
	# Conecta os sinais de clique nas opções dos menus
	popup_a.index_pressed.connect(func(idx): _on_item_selected(idx, popup_a, character_a, true))
	popup_b.index_pressed.connect(func(idx): _on_item_selected(idx, popup_b, character_b, false))
	
func _on_item_selected(index: int, popup: PopupMenu, button: MenuButton, is_player_a: bool) -> void:
	var char_id = popup.get_item_id(index)
	var char_name = popup.get_item_text(index)

	# Impede escolher o personagem já selecionado pelo outro jogador
	if is_player_a and char_id == player_b_char_id and char_id != 0:
		print("Personagem já selecionado pelo Jogador B!")
		return
	if not is_player_a and char_id == player_a_char_id and char_id != 0:
		print("Personagem já selecionado pelo Jogador A!")
		return

	for i in range(popup.item_count):
		popup.set_item_checked(i, false)

	popup.set_item_checked(index, true)

	button.text = "Personagem Selecionado: " + char_name

	if is_player_a:
		player_a_char_id = char_id
		Global.player_a_character = char_id
	else:
		player_b_char_id = char_id
		Global.player_b_character = char_id

# Função auxiliar para cadastrar os itens via código caso não tenha feito no Editor
func setup_character_menus() -> void:
	popup_a.clear()
	popup_b.clear()
	
	popup_a.add_theme_constant_override("icon_max_width", 140)
	popup_b.add_theme_constant_override("icon_max_width", 140)
	
	for char_data in characters:
		var tex = load(char_data["icon"]) if ResourceLoader.exists(char_data["icon"]) else null
		popup_a.add_icon_radio_check_item(tex, char_data["name"], char_data["id"])
		popup_b.add_icon_radio_check_item(tex, char_data["name"], char_data["id"])

# Retorna o nome do personagem dado o seu ID
func _get_character_name_by_id(id: int) -> String:
	for char_data in characters:
		if char_data["id"] == id:
			return char_data["name"]
	return "Selecione seu Personagem"


# Ação do botão para iniciar o jogo
func _on_start_button_up() -> void:
	if player_a_char_id == 0 or player_b_char_id == 00:
		print("Ambos os jogadores devem selecionar um personagem antes de começar!")
		return
	
	# Passa a escolha para o Singleton/Autoload do jogo ou carrega a próxima cena
	Global.player_a_character = player_a_char_id
	Global.player_b_character = player_b_char_id
	
	get_tree().change_scene_to_file("res://game.tscn")
