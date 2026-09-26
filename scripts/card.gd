class_name Card

var house : String
var num : int
var title : String
var mesa : Label

var interface = preload("res://card.tscn").instantiate()

func _init(p_num: int, p_house: String) -> void:
	self.num = p_num
	self.house = p_house
	
	self.title = ''
	if(self.num < 11):
		self.title += str(self.num)
	elif(self.num == 1):
		self.title += 'Às '
		self.num = 11
	elif(self.num == 11):
		self.title += 'Valete'
		self.num = 10
	elif(self.num == 12):
		self.title += 'Rainha'
		self.num = 10
	elif(self.num == 13):
		self.title += 'Rei'
		self.num = 10
	
	self.title += " de " + self.house
	
	# Interface
	self.interface.get_node("num1").text = str(num)
	self.interface.get_node("num2").text = str(num)
	
	var house_temp = ''
	if(house == "Ouro"):
		house_temp = '♦️'
	elif(house == "Copas"):
		house_temp = '♥️'
	elif(house == "Espadas"):
		house_temp = '♠️'
	elif(house == "Paus"):
		house_temp = '♣️'
	self.interface.get_node("house1").text = house_temp
	self.interface.get_node("house2").text = house_temp
	
	self.interface.setup_view(num, house_temp)
	
func get_value():
	if( self.num > 1 and self.num < 11):
		return self.num
	elif( self.num == 1 ):
		return 11
	elif( self.num > 10 ):
		return 10
