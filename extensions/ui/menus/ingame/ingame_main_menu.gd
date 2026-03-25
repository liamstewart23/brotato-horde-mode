extends "res://ui/menus/ingame/ingame_main_menu.gd"


func _ready() -> void :
	._ready()
	if RunData.is_hoard_mode:
		_difficulty_label.text = _difficulty_label.text.replace(
			" - " + Text.text("WAVE", [str(RunData.current_wave)]),
			" - " + tr("HOARD_MODE") + " - " + Text.text("WAVE", [str(RunData.current_wave)])
		)
