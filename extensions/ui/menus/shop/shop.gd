extends "res://ui/menus/shop/shop.gd"


func _ready() -> void :
	._ready()
	if RunData.is_horde_mode:
		_title.text += " - " + tr("HORDE_MODE")
