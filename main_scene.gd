extends Node2D



const GridCellState = preload("res://grid_cell_state.gd")
const INNER_SEPARATION := 1
const OUTER_SEPARATION := 4



var _hbox_top_cats := HBoxContainer.new()
var _hbox_side_cats := HBoxContainer.new()
var _vbox_top_elts := VBoxContainer.new()
var _vbox_side_elts := VBoxContainer.new()
var _main_grid := GridContainer.new()
var _grid_buttons: Array
var _lp: LogicGridPuzzle
var font_roboto_regular: Font = load("res://fonts/Roboto/Roboto_regular.tres")




func _ready():
	_build_puzzle(5,5)
	_lp = LogicGridPuzzle.new(5, 5)
	_update_gui_positions()




func _build_puzzle(cat_count: int, elt_count: int):
	for cat in range(cat_count):
		if cat <= cat_count - 2:
			var cat_button = _get_cat_button("cat " + str(cat))
			_hbox_top_cats.add_child(cat_button)
			var inner_vbox = VBoxContainer.new()
			inner_vbox.size_flags_vertical = VBoxContainer.SIZE_EXPAND_FILL
			inner_vbox.add_constant_override("separation", INNER_SEPARATION)
			for elt in range(elt_count - 1, -1, -1):
				var elt_button = _get_elt_button("element " + str(cat_count - cat - 2) + "." + str(elt))
				inner_vbox.add_child(elt_button)
			_vbox_top_elts.add_child(inner_vbox)
		if cat >= 1:
			var cat_button = _get_cat_button("cat " + str(cat))
			_hbox_side_cats.add_child(cat_button)
			var inner_vbox = VBoxContainer.new()
			inner_vbox.size_flags_vertical = VBoxContainer.SIZE_EXPAND_FILL
			inner_vbox.add_constant_override("separation", INNER_SEPARATION)
			for elt in range(elt_count):
				var elt_button = _get_elt_button("element " + str(cat_count - cat) + "." + str(elt))
				inner_vbox.add_child(elt_button)
			_vbox_side_elts.add_child(inner_vbox)

	_hbox_side_cats.set_rotation(deg2rad(-90))
	_vbox_top_elts.set_rotation(deg2rad(90))
	self.add_child(_hbox_side_cats)
	self.add_child(_hbox_top_cats)
	self.add_child(_vbox_side_elts)
	self.add_child(_vbox_top_elts)
	_build_main_grid(cat_count, elt_count)


func _get_elt_button(default_text: String) -> Button:
	var elt_button = Button.new()
	elt_button.add_font_override("font", font_roboto_regular)
	elt_button.size_flags_vertical = Button.SIZE_EXPAND_FILL
	elt_button.align = Button.ALIGN_RIGHT
	elt_button.rect_min_size = Vector2(23, 23)
	elt_button.text = default_text
	return elt_button

func _get_cat_button(default_text: String) -> Button:
	var cat_button = Button.new()
	cat_button.add_font_override("font", font_roboto_regular)
	cat_button.clip_text = true
	cat_button.size_flags_horizontal = Button.SIZE_EXPAND_FILL
	cat_button.text = default_text
	return cat_button


func _build_main_grid(cat_count: int, elt_count: int):
	_grid_buttons = []
	_main_grid.columns = cat_count - 1
	_main_grid.add_constant_override("hseparation", OUTER_SEPARATION)
	_main_grid.add_constant_override("vseparation", OUTER_SEPARATION)
	for side_cat in range(cat_count - 1, 0, -1):
		for top_cat in range(0, cat_count - 1):
			var inner_grid := GridContainer.new()
			if side_cat > top_cat:
				inner_grid.size_flags_horizontal = GridContainer.SIZE_EXPAND_FILL
				inner_grid.size_flags_vertical = GridContainer.SIZE_EXPAND_FILL
				inner_grid.columns = elt_count
				inner_grid.add_constant_override("hseparation", INNER_SEPARATION)
				inner_grid.add_constant_override("vseparation", INNER_SEPARATION)
				for side_elt in range(elt_count):
					for top_elt in range(elt_count):
						var button = EventButton.new(side_cat, side_elt, top_cat, top_elt)
						var x_move := Move.new(side_cat, side_elt, top_cat, top_elt, false)
						var o_move := Move.new(side_cat, side_elt, top_cat, top_elt, true)
						button.connect("left_click", self, "_enter_move", [x_move])
						button.connect("right_click", self, "_enter_move", [o_move])
						button.size_flags_horizontal = Button.SIZE_EXPAND_FILL
						button.size_flags_vertical = Button.SIZE_EXPAND_FILL
						button.button_mask = BUTTON_MASK_LEFT | BUTTON_MASK_RIGHT
						button.add_font_override("font", font_roboto_regular)
						
						_grid_buttons.append(button)
						inner_grid.add_child(button)
			_main_grid.add_child(inner_grid)
	self.add_child(_main_grid)


func _update_grid_buttons():
	for button in _grid_buttons:
		var cell = _lp.read_grid_cell(button.side_cat, button.side_elt, \
				button.top_cat, button.top_elt)
		match cell:
			GridCellState.FALSE:
				button.text = "X"
				#button.disabled = true
			GridCellState.TRUE:
				button.text = "O"
#				var t = Theme.new()
#				t.set_color("font_color", "Button", Color(0.2, 0.4, 0.8))
#				button.set_theme(t)
				var my_style = StyleBoxFlat.new()
				my_style.set_bg_color(Color(0.8, 0.4, 0.2))
				button.set("custom_styles/normal", my_style)
				button.set("custom_styles/hover", my_style)
				button.set("custom_styles/pressed", my_style)
				button.set("custom_styles/focus", my_style)
				button.set("custom_styles/disabled", my_style)
				#button.disabled = true
			GridCellState.UNKNOWN:
				button.text = ""
				#button.disabled = false
			GridCellState.UNSOLVABLE:
				button.text = "?"
				#button.disabled = true

func _enter_move(move):
	_lp.apply_move(move)
	_update_grid_buttons()
	_update_gui_positions()
	#print(str(_lp))




func _update_gui_positions():
	var top_cat_thickness = _hbox_top_cats.rect_size[1]
	var top_elt_thickness = _vbox_top_elts.rect_size[0]
	var top_cat_width = _hbox_top_cats.rect_size[0]
	var top_elt_width = _vbox_top_elts.rect_size[1]
	var top_grid_width = _main_grid.rect_size[0]
	var top_width = [top_cat_width, top_elt_width, top_grid_width].max()
	var top_thickness = top_cat_thickness + top_elt_thickness
	
	var side_cat_thickness = _hbox_side_cats.rect_size[1]
	var side_elt_thickness = _vbox_side_elts.rect_size[0]
	var side_cat_width = _hbox_side_cats.rect_size[0]
	var side_elt_width = _vbox_side_elts.rect_size[1]
	var side_grid_width = _main_grid.rect_size[1]
	var side_width = [side_cat_width, side_elt_width, side_grid_width].max()
	var side_thickness = side_cat_thickness + side_elt_thickness
	
	var menu: PanelContainer = get_node("MenuToolbar")
	var puz_position = Vector2(0, menu.rect_position[1] + menu.rect_size[1] + OUTER_SEPARATION - 1)
	
	_hbox_top_cats.rect_position = Vector2(side_thickness + OUTER_SEPARATION, 0) + puz_position
	_vbox_top_elts.rect_position = Vector2(side_thickness + OUTER_SEPARATION + top_width, top_cat_thickness + INNER_SEPARATION) + puz_position
	_hbox_top_cats.rect_min_size = Vector2(top_width, 0)
	_vbox_top_elts.rect_min_size = Vector2(0, top_width)
	_hbox_top_cats.add_constant_override("separation", OUTER_SEPARATION)
	
	_hbox_side_cats.rect_position = Vector2(0, top_thickness + side_width + OUTER_SEPARATION) + puz_position
	_vbox_side_elts.rect_position = Vector2(side_cat_thickness + INNER_SEPARATION, top_thickness + OUTER_SEPARATION) + puz_position
	_hbox_side_cats.rect_min_size = Vector2(side_width, 0)
	_vbox_side_elts.rect_min_size = Vector2(0, side_width)
	_hbox_side_cats.add_constant_override("separation", OUTER_SEPARATION)
	
	_main_grid.rect_position = Vector2(side_thickness + OUTER_SEPARATION, top_thickness + OUTER_SEPARATION) + puz_position
	_main_grid.rect_min_size = Vector2(top_width, side_width)
