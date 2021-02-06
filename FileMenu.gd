extends MenuButton


var popup

enum {NEW, LOAD, SAVE}


func _ready():
	popup = get_popup()
	popup.add_item("New", NEW, KEY_N | KEY_MASK_CTRL)
	popup.add_item("Load", LOAD, KEY_L | KEY_MASK_CTRL)
	popup.add_item("Save", SAVE, KEY_S | KEY_MASK_CTRL)
	popup.connect("id_pressed", self, "_on_id_pressed")


func _on_id_pressed(ID):
	print(popup.get_item_text(ID), " pressed")
	match ID:
		NEW:
			print("Yep, New!")
			var _cat_count=5
			var _cat_size=5
			var _lp=LogicGridPuzzle.new(_cat_count,_cat_size)
			print(str(_lp))
