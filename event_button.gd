class_name EventButton
extends Button

signal left_click
signal right_click

var side_cat: int
var side_elt: int
var top_cat: int
var top_elt: int

func _init(my_side_cat: int, my_side_elt: int, my_top_cat: int, my_top_elt: int):
	side_cat = my_side_cat
	side_elt = my_side_elt
	top_cat = my_top_cat
	top_elt = my_top_elt

func _ready():
# warning-ignore:return_value_discarded
	connect("gui_input", self, "_on_Button_gui_input")

func _on_Button_gui_input(event):
	if event is InputEventMouseButton and event.pressed and not disabled:
		match event.button_index:
			BUTTON_LEFT:
				self.text = "X"
				emit_signal("left_click")
			BUTTON_RIGHT:
				self.text = "O"
				emit_signal("right_click")
