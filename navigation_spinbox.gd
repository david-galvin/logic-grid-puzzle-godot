class_name NavigationSpinBox
extends SpinBox


var neighbor_up = self
var neighbor_left = self
var neighbor_right = self
var neighbor_down = self


func _input(event):
	if self.get_line_edit().has_focus() or self.has_focus():
		if event.is_action_pressed("ui_up") and not neighbor_up == self:
			neighbor_up.grab_focus()
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("ui_left") and not neighbor_left == self:
			neighbor_left.grab_focus()
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("ui_right") and not neighbor_right == self:
			neighbor_right.grab_focus()
			get_tree().set_input_as_handled()
		elif event is InputEventKey and event.pressed and event.scancode == KEY_ENTER \
				and not neighbor_down == self:
			neighbor_down.grab_focus()
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("ui_down") and not neighbor_down == self:
			neighbor_down.grab_focus()
			get_tree().set_input_as_handled()
