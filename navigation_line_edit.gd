class_name NavigationLineEdit
extends LineEdit




var neighbor_up := self
var neighbor_left := self
var neighbor_right := self
var neighbor_down := self




func _input(event):
	if event.is_action_pressed("ui_up") and self.has_focus():
		neighbor_up.grab_focus()
		get_tree().set_input_as_handled()
	if event.is_action_pressed("ui_left") and self.has_focus():
		neighbor_left.grab_focus()
		get_tree().set_input_as_handled()
	if event.is_action_pressed("ui_right") and self.has_focus():
		neighbor_right.grab_focus()
		get_tree().set_input_as_handled()
	if (event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_down")) and self.has_focus():
		neighbor_down.grab_focus()
		get_tree().set_input_as_handled()
