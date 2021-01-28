
extends MenuButton


var popup

enum {UNDO, REDO, SIZE_UP, SIZE_DOWN}


func _ready():
	popup = get_popup()
	popup.add_item("Undo", UNDO, KEY_Z | KEY_MASK_CTRL)
	popup.add_item("Redo", REDO, KEY_Y | KEY_MASK_CTRL)
	popup.add_item("Increase Font", SIZE_UP, KEY_PLUS | KEY_SHIFT | KEY_MASK_SHIFT)
	popup.add_item("Decrease Font", SIZE_DOWN, KEY_MINUS)
	popup.connect("id_pressed", self, "_on_id_pressed")


func _on_id_pressed(ID):
	print(popup.get_item_text(ID), " pressed")
