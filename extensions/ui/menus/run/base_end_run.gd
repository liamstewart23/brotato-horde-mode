extends "res://ui/menus/run/base_end_run.gd"


func _ready() -> void :
	._ready()
	if RunData.is_hoard_mode:
		_run_info.text += " - " + tr("HOARD_MODE")
