extends "res://singletons/run_data.gd"

var is_hoard_mode: bool = false
var hoard_config: Dictionary = {
	"enemy_count_percent": 400,
	"enemy_hp_percent": -40,
	"enemy_damage_percent": -20,
	"materials_percent": -40,
	"xp_percent": -40,
	"max_enemies_multiplier": 5.0,
}
var _chal_hoard_survivor_hash: int = 0
var _chal_hoard_slayer_hash: int = 0
var _chal_hoard_master_hash: int = 0
var _chal_hoard_endurance_hash: int = 0


func _is_valid_player_index(player_index: int) -> bool:
	return player_index >= 0 and player_index < players_data.size()


func get_player_effects(player_index: int) -> Dictionary:
	if not _is_valid_player_index(player_index):
		return dummy_player_effects
	return players_data[player_index].effects


func get_player_xp(player_index: int) -> float:
	if not _is_valid_player_index(player_index):
		return 0.0
	return players_data[player_index].current_xp


func get_player_level(player_index: int) -> int:
	if not _is_valid_player_index(player_index):
		return 0
	return players_data[player_index].current_level


func get_player_gold(player_index: int) -> int:
	if not _is_valid_player_index(player_index):
		return 0
	return players_data[player_index].gold


func get_player_current_health(player_index: int) -> int:
	if not _is_valid_player_index(player_index):
		return 0
	return players_data[player_index].current_health if wave_in_progress else get_player_max_health(player_index)


func reset(restart: bool = false) -> void :
	var was_hoard = is_hoard_mode
	.reset(restart)
	if restart:
		is_hoard_mode = was_hoard
	else:
		is_hoard_mode = false


func get_state() -> Dictionary:
	var state = .get_state()
	state["is_hoard_mode"] = is_hoard_mode
	return state


func resume_from_state(state: Dictionary) -> void :
	.resume_from_state(state)
	is_hoard_mode = state.get("is_hoard_mode", false)


func apply_run_won() -> void :
	.apply_run_won()
	if not is_hoard_mode:
		return

	if _chal_hoard_survivor_hash != 0:
		ChallengeService.complete_challenge(_chal_hoard_survivor_hash)

	if _chal_hoard_slayer_hash != 0 and current_difficulty >= 5:
		ChallengeService.complete_challenge(_chal_hoard_slayer_hash)

	if _chal_hoard_master_hash != 0:
		var char_hash = get_player_character(0).get_my_id_hash()
		if not ProgressData.data.has("hoard_characters_won"):
			ProgressData.data["hoard_characters_won"] = []
		var won_chars: Array = ProgressData.data["hoard_characters_won"]
		if not won_chars.has(char_hash):
			won_chars.append(char_hash)
		if won_chars.size() >= 5:
			ChallengeService.complete_challenge(_chal_hoard_master_hash)
