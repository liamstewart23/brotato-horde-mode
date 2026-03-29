extends "res://ui/menus/run/difficulty_selection/difficulty_selection.gd"

var _horde_effects = [
	preload("res://mods-unpacked/PapiLeem-HordeMode/content/effects/horde_effect_enemy_count.tres"),
	preload("res://mods-unpacked/PapiLeem-HordeMode/content/effects/horde_effect_enemy_health.tres"),
	preload("res://mods-unpacked/PapiLeem-HordeMode/content/effects/horde_effect_enemy_damage.tres"),
	preload("res://mods-unpacked/PapiLeem-HordeMode/content/effects/horde_effect_enemy_speed.tres"),
	preload("res://mods-unpacked/PapiLeem-HordeMode/content/effects/horde_effect_gold_drops.tres"),
	preload("res://mods-unpacked/PapiLeem-HordeMode/content/effects/horde_effect_xp_gain.tres"),
]

var _horde_toggle: CheckButton
var _horde_multiplier: OptionButton
var _horde_desc_container: VBoxContainer
var _horde_desc_enemies: Label
var _horde_desc_player: Label

var _multiplier_options = [
	{"label": "2x", "enemy_count_percent": 100, "max_enemies_multiplier": 2.0},
	{"label": "3x", "enemy_count_percent": 200, "max_enemies_multiplier": 3.0},
	{"label": "5x", "enemy_count_percent": 400, "max_enemies_multiplier": 5.0},
	{"label": "10x", "enemy_count_percent": 900, "max_enemies_multiplier": 10.0},
]


func _ready() -> void :
	._ready()
	_apply_config_to_effects()
	_setup_horde_toggle()


func _apply_config_to_effects() -> void :
	var cfg = RunData.horde_config
	var key_map = {
		0: "enemy_count_percent",
		1: "enemy_hp_percent",
		2: "enemy_damage_percent",
		3: "enemy_speed_percent",
		4: "materials_percent",
		5: "xp_percent",
	}
	for i in key_map:
		if cfg.has(key_map[i]):
			_horde_effects[i].value = int(cfg[key_map[i]])


func _setup_horde_toggle() -> void :
	var font_26 = load("res://resources/fonts/actual/base/font_26.tres")
	var font_22 = load("res://resources/fonts/actual/base/font_22.tres")
	var empty_style = StyleBoxEmpty.new()

	var outer_vbox = VBoxContainer.new()
	outer_vbox.set("custom_constants/separation", 4)
	outer_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var toggle_row = HBoxContainer.new()
	toggle_row.set("custom_constants/separation", 20)
	toggle_row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	_horde_toggle = CheckButton.new()
	_horde_toggle.text = tr("HORDE_MODE")
	_horde_toggle.pressed = false
	RunData.is_horde_mode = false
	if font_26:
		_horde_toggle.set("custom_fonts/font", font_26)
	_horde_toggle.set("custom_styles/hover", empty_style)
	_horde_toggle.set("custom_styles/hover_pressed", empty_style)
	_horde_toggle.set("custom_styles/focus", empty_style)
	_horde_toggle.set("custom_styles/normal", empty_style)
	_horde_toggle.set("custom_styles/pressed", empty_style)
	toggle_row.add_child(_horde_toggle)

	_horde_multiplier = OptionButton.new()
	_horde_multiplier.rect_min_size = Vector2(120, 0)
	if font_26:
		_horde_multiplier.set("custom_fonts/font", font_26)
	var default_idx = 2
	for i in _multiplier_options.size():
		_horde_multiplier.add_item(_multiplier_options[i].label, i)
		if _multiplier_options[i].enemy_count_percent == int(RunData.horde_config.get("enemy_count_percent", 400)):
			default_idx = i
	_horde_multiplier.select(default_idx)
	_horde_multiplier.visible = false
	toggle_row.add_child(_horde_multiplier)

	outer_vbox.add_child(toggle_row)

	_horde_desc_container = VBoxContainer.new()
	_horde_desc_container.set("custom_constants/separation", 0)
	_horde_desc_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_horde_desc_container.visible = false

	_horde_desc_enemies = Label.new()
	if font_22:
		_horde_desc_enemies.set("custom_fonts/font", font_22)
	_horde_desc_container.add_child(_horde_desc_enemies)

	_horde_desc_player = Label.new()
	if font_22:
		_horde_desc_player.set("custom_fonts/font", font_22)
	_horde_desc_container.add_child(_horde_desc_player)

	outer_vbox.add_child(_horde_desc_container)

	var vbox = $MarginContainer / VBoxContainer
	vbox.add_child(outer_vbox)

	_update_desc_text(false)

	var _e = _horde_toggle.connect("toggled", self, "_on_horde_toggled")
	var _e2 = _horde_multiplier.connect("item_selected", self, "_on_multiplier_selected")


func _update_desc_text(enabled: bool) -> void :
	_horde_multiplier.visible = enabled
	_horde_desc_container.visible = enabled

	var cfg = RunData.horde_config
	var enemy_count = int(cfg.get("enemy_count_percent", 400))
	var enemy_hp = int(cfg.get("enemy_hp_percent", -15))
	var enemy_dmg = int(cfg.get("enemy_damage_percent", -10))
	var enemy_spd = int(cfg.get("enemy_speed_percent", 20))
	var mat_pct = int(cfg.get("materials_percent", -50))
	var xp_pct = int(cfg.get("xp_percent", -50))
	var enemy_mult = (100 + enemy_count) / 100.0

	_horde_desc_enemies.text = "Enemies: %.0fx Count | %d%% HP | %d%% Damage | +%d%% Speed" % [enemy_mult, enemy_hp, enemy_dmg, enemy_spd]
	_horde_desc_player.text = "Player: %d%% Materials | %d%% XP" % [mat_pct, xp_pct]


func _on_horde_toggled(button_pressed: bool) -> void :
	RunData.is_horde_mode = button_pressed
	if not ProgressData.settings.has("horde_mode_toggled"):
		ProgressData.settings["horde_mode_toggled"] = false
	ProgressData.settings.horde_mode_toggled = button_pressed
	_update_desc_text(button_pressed)


func _on_multiplier_selected(index: int) -> void :
	var opt = _multiplier_options[index]
	RunData.horde_config["enemy_count_percent"] = opt.enemy_count_percent
	RunData.horde_config["max_enemies_multiplier"] = opt.max_enemies_multiplier
	_apply_config_to_effects()
	_update_desc_text(_horde_toggle.pressed)


func _on_element_pressed(element: InventoryElement, _inventory_player_index: int) -> void :
	if difficulty_selected:
		return

	if element.is_special:
		return
	else:
		difficulty_selected = true

		if not RunData.is_coop_run:
			var current_character = RunData.get_player_character(0)
			var character_difficulty = ProgressData.get_character_difficulty_info(current_character.my_id_hash, RunData.current_zone)
			character_difficulty.difficulty_selected_value = element.item.value

		RunData.current_difficulty = element.item.value
		RunData.reset_elites_spawn()
		RunData.init_elites_spawn()

		RunData.enabled_dlcs = ProgressData.get_active_dlc_ids()

		ProgressData.save()

		for effect in element.item.effects:
			effect.apply(0)

		if RunData.is_horde_mode:
			for effect in _horde_effects:
				effect.apply(0)

		for player_index in range(RunData.get_player_count()):
			var player_run_data = RunData.players_data[player_index]
			player_run_data.uses_ban = RunData.is_ban_mode_active
			player_run_data.remaining_ban_token = RunData.BAN_MAX_TOKEN

		RunData.init_bosses_spawn()

	RunData.current_run_accessibility_settings = ProgressData.settings.enemy_scaling.duplicate()
	ProgressData.load_status = LoadStatus.SAVE_OK
	ProgressData.increment_stat("run_started")
	ProgressData.data["chal_hourglass_quit_wave"] = false
	var _error = get_tree().change_scene(MenuData.game_scene)
