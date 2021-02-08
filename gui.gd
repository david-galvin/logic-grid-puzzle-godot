extends MarginContainer





# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.

func _ready():
	self._build_puzzle(5,5)


func _build_puzzle(cat_count: int, elt_count: int):
	var cat_buttons_top_hbox = HBoxContainer.new()
	var cat_buttons_left_hbox = HBoxContainer.new()
	var elt_buttons_outer_top_vbox = VBoxContainer.new()
	var elt_buttons_outer_left_vbox = VBoxContainer.new()
	for i in range(cat_count):
		if i <= cat_count - 2:
			var cat_button = Button.new()
			cat_button.text = "cat " + str(i)
			cat_button.size_flags_horizontal = 3
			cat_buttons_top_hbox.add_child(cat_button)
			var inner_vbox = VBoxContainer.new()
			
			for j in range(elt_count):
				var elt_button = Button.new()
				elt_button.text = "elt " + str(i) + "." + str(j)
				inner_vbox.add_child(elt_button)
			elt_buttons_outer_top_vbox.add_child(inner_vbox)
		if i >= 1:
			var cat_button = Button.new()
			cat_button.text = "cat " + str(i)
			cat_button.size_flags_horizontal = 3
			cat_buttons_left_hbox.add_child(cat_button)
			var inner_vbox = VBoxContainer.new()
			for j in range(elt_count):
				var elt_button = Button.new()
				elt_button.text = "elt " + str(i) + "." + str(j)
				inner_vbox.add_child(elt_button)
			elt_buttons_outer_left_vbox.add_child(inner_vbox)

	cat_buttons_left_hbox.set_rotation(deg2rad(-90))
	elt_buttons_outer_top_vbox.set_rotation(deg2rad(-90))
	self.add_child(cat_buttons_left_hbox)
	self.add_child(cat_buttons_top_hbox)
	self.add_child(elt_buttons_outer_left_vbox)
	self.add_child(elt_buttons_outer_top_vbox)
	var offset = cat_buttons_top_hbox.rect_size[1] + elt_buttons_outer_top_vbox.rect_size[0]
	cat_buttons_top_hbox.rect_position = Vector2(offset, 0)
	elt_buttons_outer_top_vbox.rect_position = Vector2(offset, offset)
	cat_buttons_left_hbox.rect_position = Vector2(0, offset + elt_buttons_outer_left_vbox.rect_size[1])
	elt_buttons_outer_left_vbox.rect_position = Vector2(cat_buttons_left_hbox.rect_size[1], offset)
	cat_buttons_top_hbox.rect_min_size = Vector2(elt_buttons_outer_left_vbox.rect_size[1], 1)
	cat_buttons_left_hbox.rect_min_size = Vector2(elt_buttons_outer_left_vbox.rect_size[1], 1)
	print(elt_buttons_outer_left_vbox.rect_size)
