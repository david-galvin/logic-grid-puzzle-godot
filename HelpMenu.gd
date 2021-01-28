extends MenuButton


var popup


func _ready():
	popup = get_popup()
	popup.add_item("Instructions")
	popup.add_item("About")
	popup.add_item("License")
	popup.connect("id_pressed", self, "_on_id_pressed")


func _on_id_pressed(ID):
	print(popup.get_item_text(ID), " pressed")
