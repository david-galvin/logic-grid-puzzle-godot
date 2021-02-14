extends Node2D




const GRID_CELL_STATE = preload("res://grid_cell_state.gd")
const FONT_ROBOTO_REGULAR: Font = preload("res://fonts/Roboto/Roboto_regular.tres")
const INNER_SEPARATION := 1
const OUTER_SEPARATION := 4




var _hbox_top_cats := HBoxContainer.new()
var _hbox_side_cats := HBoxContainer.new()
var _vbox_top_elts := VBoxContainer.new()
var _vbox_side_elts := VBoxContainer.new()
var _main_grid := GridContainer.new()
var _cat_elt_v2_to_color_style := {}
var _cat_elt_v2_to_buttons := {}
var _cat_to_buttons := {}
var _grid_buttons: Array
var _lp: LogicGridPuzzle
var _color_styles: Array
var _default_style = StyleBoxFlat.new()
var _moves: Array = []
var _cat_count: int
var _cat_size: int




func _clear_all():
	_hbox_top_cats.free()
	_hbox_side_cats.free()
	_vbox_top_elts.free()
	_vbox_side_elts.free()
	_main_grid.free()
	_hbox_top_cats = HBoxContainer.new()
	_hbox_side_cats = HBoxContainer.new()
	_vbox_top_elts = VBoxContainer.new()
	_vbox_side_elts = VBoxContainer.new()
	_main_grid = GridContainer.new()
	_cat_elt_v2_to_color_style = {}
	_cat_elt_v2_to_buttons = {}
	_cat_to_buttons = {}
	_grid_buttons = []
	_color_styles = []
	_moves = []




func _generate_puzzle(_cat_count_sb: SpinBox, _cat_size_sb: SpinBox):
	_clear_all()
	_cat_count = int(_cat_count_sb.get_value())
	_cat_size = int(_cat_size_sb.get_value())
	_lp = LogicGridPuzzle.new(_cat_count, _cat_size)
	_initialize_color_styles()
	_build_puzzle()
	_update_gui_positions()



func _initialize_color_styles():
	_color_styles.clear()
	_default_style.set_bg_color(Color.from_hsv(0.708, 0.15, 0.25))
	var hue: float
	var lightness: float = 0.8
	var saturation: float = 1.0
	var num_color_styles: int = (_cat_count / 2) * (_cat_size)
	for i in range(num_color_styles):
		hue = float(i) / float(num_color_styles)
		var color_style := StyleBoxFlat.new()
		var color := Color.from_hsv(hue, saturation, lightness)
		color_style.set_bg_color(color)
		if i % (_cat_count / 2) == 0:
			_color_styles.push_front(color_style)
		else:
			_color_styles.push_back(color_style)




func _build_puzzle():
	for cat in range(_cat_count):
		if cat <= _cat_count - 2:
			var cat_button: Button = _make_cat_button(cat)
			_cat_to_buttons[cat] = [cat_button]
			_hbox_top_cats.add_child(cat_button)
			var inner_vbox := VBoxContainer.new()
			inner_vbox.size_flags_vertical = VBoxContainer.SIZE_EXPAND_FILL
			inner_vbox.add_constant_override("separation", INNER_SEPARATION)
			for elt in range(_cat_size - 1, -1, -1):
				var elt_button: Button = _make_elt_button(_cat_count - cat - 2, elt)
				_cat_elt_v2_to_buttons[Vector2(_cat_count - cat - 2, elt)] = [elt_button]
				inner_vbox.add_child(elt_button)
			_vbox_top_elts.add_child(inner_vbox)
		if cat >= 1:
			var cat_button: Button = _make_cat_button(cat)
			if _cat_to_buttons.has(cat):
				_cat_to_buttons[cat].append(cat_button)
			else:
				_cat_to_buttons[cat] = [cat_button]
			_hbox_side_cats.add_child(cat_button)
			var inner_vbox := VBoxContainer.new()
			inner_vbox.size_flags_vertical = VBoxContainer.SIZE_EXPAND_FILL
			inner_vbox.add_constant_override("separation", INNER_SEPARATION)
			for elt in range(_cat_size):
				var elt_button: Button = _make_elt_button(_cat_count - cat, elt)
				var cat_elt_v2 := Vector2(_cat_count - cat, elt)
				if _cat_elt_v2_to_buttons.has(cat_elt_v2):
					_cat_elt_v2_to_buttons[cat_elt_v2].append(elt_button)
				else:
					_cat_elt_v2_to_buttons[cat_elt_v2] = [elt_button]
				inner_vbox.add_child(elt_button)
			_vbox_side_elts.add_child(inner_vbox)
	_hbox_side_cats.set_rotation(deg2rad(-90))
	_vbox_top_elts.set_rotation(deg2rad(90))
	self.add_child(_hbox_side_cats)
	self.add_child(_hbox_top_cats)
	self.add_child(_vbox_side_elts)
	self.add_child(_vbox_top_elts)
	_build_main_grid()




func _make_elt_button(var cat: int, var elt: int) -> Button:
	var default_text: String = "elt " + str(cat) + "." + str(elt)
	if elt == 1:
		default_text = "element " + str(cat) + "." + str(elt)
	var elt_button := Button.new()
	elt_button.add_font_override("font", FONT_ROBOTO_REGULAR)
	elt_button.size_flags_vertical = Button.SIZE_EXPAND_FILL
	elt_button.align = Button.ALIGN_RIGHT
	elt_button.rect_min_size = Vector2(23, 23)
	elt_button.text = default_text
	elt_button.set("custom_styles/normal", _default_style)
	elt_button.set("custom_styles/hover", _default_style)
	elt_button.set("custom_styles/pressed", _default_style)
	elt_button.set("custom_styles/focus", _default_style)
	elt_button.set("custom_styles/disabled", _default_style)
	elt_button.connect("pressed", self, "relabel_puzzle_ui", [Vector2(elt+1, cat)])
	return elt_button




func _make_cat_button(cat: int) -> Button:
	var default_text := "cat " + str(cat)
	var cat_button := Button.new()
	cat_button.add_font_override("font", FONT_ROBOTO_REGULAR)
	cat_button.clip_text = true
	cat_button.size_flags_horizontal = Button.SIZE_EXPAND_FILL
	cat_button.text = default_text
	cat_button.connect("pressed", self, "relabel_puzzle_ui", [Vector2(0, cat)])
	return cat_button




func relabel_puzzle_ui(row_col_v2: Vector2):
	var panel = PopupPanel.new()
	add_child(panel)
	panel.size_flags_horizontal = PopupPanel.SIZE_EXPAND_FILL
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = VBoxContainer.SIZE_EXPAND_FILL
	panel.add_child(vbox)
	
	var label := Label.new()
	label.text = "Relabel Categories & Elements"
	label.align = Label.ALIGN_CENTER
	#label.set("custom_styles/normal", _default_style)
	vbox.add_child(label)
	
	var grid := GridContainer.new()
	grid.add_constant_override("hseparation", INNER_SEPARATION)
	grid.add_constant_override("vseparation", INNER_SEPARATION)
	vbox.add_child(grid)
	grid.columns = _cat_count
	grid.size_flags_horizontal = GridContainer.SIZE_EXPAND_FILL
	
	var matrix := []
	for _i in range(_cat_size + 1):
		var arr := []
		arr.resize(_cat_count)
		matrix.append(arr)
	
	for cat in range(_cat_count):
		var line_edit := NavigationLineEdit.new()
		line_edit.text = _cat_to_buttons[cat][0].text
		line_edit.size_flags_horizontal = LineEdit.SIZE_EXPAND_FILL
		line_edit.connect("focus_entered", self, "_line_edit_select", [line_edit])
		line_edit.connect("focus_exited", self, "_line_edit_deselect", [line_edit])
		grid.add_child(line_edit)
		matrix[0][cat] = line_edit
		
	for elt in range(_cat_size):
		for cat in range(_cat_count):
			var line_edit := NavigationLineEdit.new()
			line_edit.text = _cat_elt_v2_to_buttons[Vector2(cat, elt)][0].text
			line_edit.size_flags_horizontal = LineEdit.SIZE_EXPAND_FILL
			line_edit.connect("focus_entered", self, "_line_edit_select", [line_edit])
			line_edit.connect("focus_exited", self, "_line_edit_deselect", [line_edit])
			grid.add_child(line_edit)
			matrix[elt + 1][cat] = line_edit

	var button = Button.new()
	button.text = "Relabel!"
	button.connect("pressed", self, "_relabel_puzzle", [matrix])
	vbox.add_child(button)
	
	for row in range(_cat_size + 1):
		for col in range(_cat_count):
			var a: NavigationLineEdit = matrix[row][col]
			var b: NavigationLineEdit
			var c: NavigationLineEdit
			
			if row == _cat_size and col == _cat_count - 1:
				b = matrix[0][0]
				c = matrix[0][0]
			elif row == _cat_size:
				b = matrix[row][col + 1]
				c = matrix[0][col + 1]
			elif col == _cat_count - 1:
				b = matrix[row + 1][0]
				c = matrix[row + 1][col]
			else:
				b = matrix[row][col + 1]
				c = matrix[row + 1][col]
			a.neighbor_right = b
			b.neighbor_left = a
			a.neighbor_down = c
			c.neighbor_up = a
	panel.rect_min_size = Vector2(150 * _cat_count,0)
	panel.popup_centered()
	matrix[row_col_v2[0]][row_col_v2[1]].grab_focus()




func _relabel_puzzle(matrix: Array):
	for cat in range(_cat_count):
		for button in _cat_to_buttons[cat]:
			button.text = matrix[0][cat].text
		for elt in range(_cat_size):
			for button in _cat_elt_v2_to_buttons[Vector2(cat, elt)]:
				button.text = matrix[elt+1][cat].text
	_update_gui_positions()




func file_new_puzzle():
	var panel = PopupPanel.new()
	add_child(panel)
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	var label := Label.new()
	label.text = "Logic Puzzle Size"
	label.align = Label.ALIGN_CENTER
	#label.set("custom_styles/normal", _default_style)
	vbox.add_child(label)
	
	var grid := GridContainer.new()
	vbox.add_child(grid)
	grid.columns = 2
	
	var cat_label := Label.new()
	cat_label.text = "Number of categories (3-12): "
	var _cat_count_spinbox = make_spinbox(1, 12, 5)
	grid.add_child(cat_label)
	grid.add_child(_cat_count_spinbox)
	
	var elt_label := Label.new()
	elt_label.text = "Number of elements (2-7): "
	var _cat_size_spinbox = make_spinbox(2, 7, 5)
	grid.add_child(elt_label)
	grid.add_child(_cat_size_spinbox)
	
	var button = Button.new()
	button.text = "Generate blank logic puzzle"
	button.connect("pressed", self, "_generate_puzzle", [_cat_count_spinbox, _cat_size_spinbox])
	vbox.add_child(button)
	
	panel.popup_centered()




func make_spinbox(min_val: int, max_val: int, default_val: int) -> SpinBox:
	var spinbox := SpinBox.new()
	spinbox.set_min(min_val)
	spinbox.set_max(max_val)
	spinbox.set_value(default_val)
	spinbox.set_step(1)
	var line_edit := spinbox.get_line_edit()
	line_edit.align = LineEdit.ALIGN_CENTER
	line_edit.connect("focus_exited", self, "_line_edit_deselect", [line_edit])
	line_edit.connect("focus_entered", self, "_line_edit_select", [line_edit])
	return spinbox




func _line_edit_select(line_edit: LineEdit):
	line_edit.select_all()




func _line_edit_deselect(line_edit: LineEdit):
	line_edit.deselect()




func _build_main_grid():
	_grid_buttons = []
	_main_grid.columns = _cat_count - 1
	_main_grid.add_constant_override("hseparation", OUTER_SEPARATION)
	_main_grid.add_constant_override("vseparation", OUTER_SEPARATION)
	for side_cat in range(_cat_count - 1, 0, -1):
		for top_cat in range(0, _cat_count - 1):
			var inner_grid := GridContainer.new()
			if side_cat > top_cat:
				inner_grid.size_flags_horizontal = GridContainer.SIZE_EXPAND_FILL
				inner_grid.size_flags_vertical = GridContainer.SIZE_EXPAND_FILL
				inner_grid.columns = _cat_size
				inner_grid.add_constant_override("hseparation", INNER_SEPARATION)
				inner_grid.add_constant_override("vseparation", INNER_SEPARATION)
				for side_elt in range(_cat_size):
					for top_elt in range(_cat_size):
						var button := EventButton.new(side_cat, side_elt, top_cat, top_elt)
						var x_move := Move.new(side_cat, side_elt, top_cat, top_elt, false)
						var o_move := Move.new(side_cat, side_elt, top_cat, top_elt, true)
						button.connect("left_click", self, "_enter_move", [x_move])
						button.connect("right_click", self, "_enter_move", [o_move])
						button.size_flags_horizontal = Button.SIZE_EXPAND_FILL
						button.size_flags_vertical = Button.SIZE_EXPAND_FILL
						button.button_mask = BUTTON_MASK_LEFT | BUTTON_MASK_RIGHT
						button.add_font_override("font", FONT_ROBOTO_REGULAR)
						_grid_buttons.append(button)
						inner_grid.add_child(button)
			_main_grid.add_child(inner_grid)
	self.add_child(_main_grid)




func _update_button_color(button: Button, cat_elt_v2: Vector2):
	var style: StyleBoxFlat = _cat_elt_v2_to_color_style[cat_elt_v2]
	button.set("custom_styles/normal", style)
	button.set("custom_styles/hover", style)
	button.set("custom_styles/pressed", style)
	button.set("custom_styles/focus", style)
	button.set("custom_styles/disabled", style)




func _update_label_buttons():
	for v2 in _cat_elt_v2_to_color_style:
		for button in _cat_elt_v2_to_buttons[v2]:
			_update_button_color(button, v2)




func _update_grid_buttons():
	for button in _grid_buttons:
		var cell = _lp.read_grid_cell(button.side_cat, button.side_elt, \
				button.top_cat, button.top_elt)
		match cell:
			GRID_CELL_STATE.FALSE:
				button.text = "X"
				#button.disabled = true
			GRID_CELL_STATE.TRUE:
				button.text = "O"
				#button.disabled = true
				var side_v2 := Vector2(button.side_cat, button.side_elt)
				var top_v2 := Vector2(button.top_cat, button.top_elt)
				if _cat_elt_v2_to_color_style.has(side_v2):
					var color: StyleBoxFlat = _cat_elt_v2_to_color_style[side_v2]
					_cat_elt_v2_to_color_style[top_v2] = color
				elif _cat_elt_v2_to_color_style.has(top_v2):
					var color: StyleBoxFlat = _cat_elt_v2_to_color_style[top_v2]
					_cat_elt_v2_to_color_style[side_v2] = color
				else:
					var color: StyleBoxFlat = _color_styles.pop_front()
					_cat_elt_v2_to_color_style[top_v2] = color
					_cat_elt_v2_to_color_style[side_v2] = color
				_update_button_color(button, Vector2(button.side_cat, button.side_elt))
				
			GRID_CELL_STATE.UNKNOWN:
				button.text = ""
				#button.disabled = false
			GRID_CELL_STATE.UNSOLVABLE:
				button.text = "?"
				#button.disabled = true




func _enter_move(move):
	_lp.apply_move(move)
	_moves.append(move)
	_update_grid_buttons()
	_update_label_buttons()
	_update_gui_positions()




func _update_gui_positions():
	_vbox_top_elts.rect_size = Vector2(1,1)
	_vbox_side_elts.rect_size = Vector2(1,1)
	_vbox_top_elts.rect_position = _vbox_top_elts.rect_position
	_hbox_top_cats.rect_position = _hbox_top_cats.rect_position
	_vbox_side_elts.rect_position = _vbox_side_elts.rect_position
	_hbox_side_cats.rect_position = _hbox_side_cats.rect_position
	
	var top_cat_thickness := _hbox_top_cats.rect_size[1]
	var top_elt_thickness := _vbox_top_elts.rect_size[0]
	var top_cat_width := _hbox_top_cats.rect_size[0]
	var top_elt_width := _vbox_top_elts.rect_size[1]
	var top_grid_width := _main_grid.rect_size[0]
	var top_width: float = [top_cat_width, top_elt_width, top_grid_width].max()
	var top_thickness := top_cat_thickness + top_elt_thickness
	
	var side_cat_thickness := _hbox_side_cats.rect_size[1]
	var side_elt_thickness := _vbox_side_elts.rect_size[0]
	var side_cat_width := _hbox_side_cats.rect_size[0]
	var side_elt_width := _vbox_side_elts.rect_size[1]
	var side_grid_width := _main_grid.rect_size[1]
	var side_width: float = [side_cat_width, side_elt_width, side_grid_width].max()
	var side_thickness := side_cat_thickness + side_elt_thickness
	
	var menu: PanelContainer = get_node("MenuToolbar")
	var puz_position := Vector2(0, menu.rect_position[1] + menu.rect_size[1] + OUTER_SEPARATION - 1)
	
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
	_main_grid.rect_size = Vector2(top_width, side_width)
