class_name Player

var player_name: String
var hand: Array = []
var score: int = 0
var character_id: int = 0
var character_data: Dictionary = {}

func _init(player_name, p_char_id) -> void:
	self.player_name = player_name
	self.hand = []
	self.score = 0
	if p_char_id > 0:
		set_character(p_char_id)

func set_character(p_char_id: int) -> void:
	self.character_id = p_char_id
	self.character_data = Global.characters_data.get(p_char_id, {})
		
func take_card( deck ):
	self.hand.append( deck[0] )
	deck.remove_at(0)
	
	self.score += self.hand[-1].get_value()

func show_hands():
	var cards_in_hand = ' | '
	for card in self.hand:
		cards_in_hand += card.title + ' | '
	return cards_in_hand

func reset( parent_card, deck ):
	var cards_in_hand = len(self.hand)
	while( cards_in_hand ):
		#self.hand[0].queue_free()
		parent_card.remove_child( self.hand[0].interface )
		deck.append( self.hand[0] )
		self.hand.remove_at(0)
		cards_in_hand -= 1
	score = 0
