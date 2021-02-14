class_name NavigationLineEdit
extends LineEdit




var neighbor_up := self
var neighbor_left := self
var neighbor_right := self
var neighbor_down := self




func _input(event):
	if self.has_focus():
		if event.is_action_pressed("ui_up"):
			neighbor_up.grab_focus()
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("ui_left"):
			neighbor_left.grab_focus()
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("ui_right"):
			neighbor_right.grab_focus()
			get_tree().set_input_as_handled()
		elif event is InputEventKey and event.pressed and event.scancode == KEY_ENTER:
			neighbor_down.grab_focus()
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("ui_down"):
			neighbor_down.grab_focus()
			get_tree().set_input_as_handled()
