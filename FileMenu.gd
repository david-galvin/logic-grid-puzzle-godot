extends MenuButton

signal file_new
signal file_load
signal file_save
signal file_quit

var popup

enum {NEW, LOAD, SAVE, QUIT}


func _ready():
	popup = get_popup()
	popup.add_item("New", NEW, KEY_N | KEY_MASK_CTRL)
	popup.add_item("Load", LOAD, KEY_L | KEY_MASK_CTRL)
	popup.add_item("Save", SAVE, KEY_S | KEY_MASK_CTRL)
	popup.add_item("Quit", QUIT, KEY_Q | KEY_MASK_CTRL)
	popup.connect("id_pressed", self, "_on_id_pressed")
	connect("file_new", get_owner(), "file_new_puzzle")
	connect("file_load", get_owner(), "file_load_puzzle")
	connect("file_save", get_owner(), "file_save_puzzle")
	connect("file_quit", get_owner(), "file_quit_puzzle")


func _on_id_pressed(ID):
	match ID:
		NEW:
			emit_signal("file_new")
		LOAD:
			emit_signal("file_load")
		SAVE:
			emit_signal("file_save")
		QUIT:
			emit_signal("file_quit")
