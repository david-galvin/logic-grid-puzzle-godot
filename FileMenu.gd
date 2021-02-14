extends MenuButton

signal file_new

var popup

enum {NEW, LOAD, SAVE}


func _ready():
	popup = get_popup()
	popup.add_item("New", NEW, KEY_N | KEY_MASK_CTRL)
	popup.add_item("Load", LOAD, KEY_L | KEY_MASK_CTRL)
	popup.add_item("Save", SAVE, KEY_S | KEY_MASK_CTRL)
	popup.connect("id_pressed", self, "_on_id_pressed")
	connect("file_new", get_owner(), "file_new_puzzle")


func _on_id_pressed(ID):
	match ID:
		NEW:
			emit_signal("file_new")
