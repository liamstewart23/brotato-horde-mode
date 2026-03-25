extends "res://ui/menus/shop/shop.gd"


func _ready() -> void :
	._ready()
	if RunData.is_hoard_mode:
		_title.text += " - " + tr("HOARD_MODE")
