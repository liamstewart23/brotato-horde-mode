extends Node

const MOD_DIR = "PapiLeem-HordeMode"
const MOD_LOG = "PapiLeem-HordeMode"

var mod_dir_path := ""
var ext_dir := ""


func _init():
	ModLoaderLog.info("Init", MOD_LOG)
	mod_dir_path = ModLoaderMod.get_unpacked_dir().plus_file(MOD_DIR)
	ext_dir = mod_dir_path.plus_file("extensions")

	ModLoaderMod.install_script_extension(ext_dir + "/entities/units/enemies/enemy.gd")
	ModLoaderMod.install_script_extension(ext_dir + "/singletons/run_data.gd")
	ModLoaderMod.install_script_extension(ext_dir + "/global/entity_spawner.gd")
	ModLoaderMod.install_script_extension(ext_dir + "/ui/menus/run/difficulty_selection/difficulty_selection.gd")
	ModLoaderMod.install_script_extension(ext_dir + "/ui/menus/run/base_end_run.gd")
	ModLoaderMod.install_script_extension(ext_dir + "/ui/menus/ingame/ingame_main_menu.gd")
	ModLoaderMod.install_script_extension(ext_dir + "/ui/menus/shop/shop.gd")
	ModLoaderMod.install_script_extension(ext_dir + "/main.gd")


func _ready():
	_add_translations()
	_register_challenge()
	_load_config()
	get_tree().connect("node_added", self, "_on_node_added")
	ModLoaderLog.info("Ready", MOD_LOG)


func _on_node_added(node: Node) -> void:
	if node is MarginContainer and node.get_script() and node.get_script().resource_path == "res://ui/menus/pages/menu_options.gd":
		_patch_menu_options(node)


func _patch_menu_options(menu_node: Node) -> void:
	var button_path = "Buttons/HBoxContainer3/TabContainer/Gameplay_Container/GameplayVBoxContainer/CompletedChallengeCheckButton"
	if not menu_node.has_node(button_path):
		return
	var button = menu_node.get_node(button_path)
	if button.is_connected("pressed", menu_node, "_on_CompletedChallengeCheckButton_pressed"):
		button.disconnect("pressed", menu_node, "_on_CompletedChallengeCheckButton_pressed")
	if not button.is_connected("pressed", self, "_on_CompletedChallengeCheckButton_pressed"):
		button.connect("pressed", self, "_on_CompletedChallengeCheckButton_pressed")


func _on_CompletedChallengeCheckButton_pressed():
	for challenge in ChallengeService.challenges:
		if ChallengeService.is_challenge_completed(challenge.my_id_hash) and (challenge.reward_type == RewardType.ITEM or challenge.reward_type == RewardType.WEAPON):
			ChallengeService.unlock_reward(challenge)
		if not ChallengeService.is_challenge_completed(challenge.my_id_hash):
			if challenge.reward_type == RewardType.ITEM and ProgressData.items_unlocked.has((challenge.reward as ItemData).my_id):
				ProgressData.items_unlocked.erase((challenge.reward as ItemData).my_id)
			if challenge.reward_type == RewardType.WEAPON and ProgressData.weapons_unlocked.has((challenge.reward as WeaponData).weapon_id):
				ProgressData.weapons_unlocked.erase((challenge.reward as WeaponData).weapon_id)
	ProgressData.save()


func _load_config():
	var config = ModLoaderConfig.get_current_config(MOD_DIR)
	if config and config.data:
		for key in config.data:
			RunData.horde_config[key] = config.data[key]
		ModLoaderLog.info("Config loaded", MOD_LOG)


func _register_challenge():
	var chal_dir = "res://mods-unpacked/PapiLeem-HordeMode/content/challenges/"
	var challenges = {
		"horde_survivor_data.tres": "_chal_horde_survivor_hash",
		"horde_slayer_data.tres": "_chal_horde_slayer_hash",
		"horde_master_data.tres": "_chal_horde_master_hash",
		"horde_endurance_data.tres": "_chal_horde_endurance_hash",
	}
	for filename in challenges:
		var chal_data = load(chal_dir + filename)
		if chal_data:
			chal_data._generate_hashes()
			RunData.set(challenges[filename], chal_data.get_my_id_hash())
			ModLoaderLog.info("Registered challenge: " + filename, MOD_LOG)
		else:
			ModLoaderLog.error("Failed to load challenge: " + filename, MOD_LOG)


func _add_translations():
	var translations = {
		"en": {
			"HORDE_MODE": "Horde Mode",
			"HORDE_MODE_DESC_ENEMIES": "Enemies: 5x Count | -15% HP | -10% Damage | +20% Speed",
			"HORDE_MODE_DESC_PLAYER": "Player: -50% Materials | -50% XP",
			"CHAL_HORDE_SURVIVOR": "Horde Survivor",
			"CHAL_HORDE_SURVIVOR_DESC": "Win a run in Horde Mode",
			"CHAL_HORDE_SLAYER": "Horde Slayer",
			"CHAL_HORDE_SLAYER_DESC": "Win a run in Horde Mode on Danger 5",
			"CHAL_HORDE_MASTER": "Horde Master",
			"CHAL_HORDE_MASTER_DESC": "Win Horde Mode with 5 different characters",
"CHAL_HORDE_ENDURANCE": "Horde Endurance",
			"CHAL_HORDE_ENDURANCE_DESC": "Reach wave 30 in Horde + Endless Mode",
		},
		"fr": {
			"HORDE_MODE": "Mode Horde",
			"HORDE_MODE_DESC_ENEMIES": "Ennemis: 5x Nombre | -15% PV | -10% D\u00e9g\u00e2ts | +20% Vitesse",
			"HORDE_MODE_DESC_PLAYER": "Joueur: -50% Mat\u00e9riaux | -50% XP",
			"CHAL_HORDE_SURVIVOR": "Survivant de la Horde",
			"CHAL_HORDE_SURVIVOR_DESC": "Gagner une partie en Mode Horde",
			"CHAL_HORDE_SLAYER": "Tueur de Horde",
			"CHAL_HORDE_SLAYER_DESC": "Gagner en Mode Horde au Danger 5",
			"CHAL_HORDE_MASTER": "Ma\u00eetre de la Horde",
			"CHAL_HORDE_MASTER_DESC": "Gagner en Mode Horde avec 5 personnages diff\u00e9rents",
"CHAL_HORDE_ENDURANCE": "Horde Endurance",
			"CHAL_HORDE_ENDURANCE_DESC": "Atteindre la vague 30 en Mode Horde + Sans Fin",
		},
		"es": {
			"HORDE_MODE": "Modo Horda",
			"HORDE_MODE_DESC_ENEMIES": "Enemigos: 5x Cantidad | -15% Vida | -10% Da\u00f1o | +20% Velocidad",
			"HORDE_MODE_DESC_PLAYER": "Jugador: -50% Materiales | -50% XP",
			"CHAL_HORDE_SURVIVOR": "Superviviente de la Horda",
			"CHAL_HORDE_SURVIVOR_DESC": "Ganar una partida en Modo Horda",
			"CHAL_HORDE_SLAYER": "Horde Slayer",
			"CHAL_HORDE_SLAYER_DESC": "Ganar en Modo Horda en Peligro 5",
			"CHAL_HORDE_MASTER": "Horde Master",
			"CHAL_HORDE_MASTER_DESC": "Ganar en Modo Horda con 5 personajes distintos",
"CHAL_HORDE_ENDURANCE": "Horde Endurance",
			"CHAL_HORDE_ENDURANCE_DESC": "Alcanzar la oleada 30 en Modo Horda + Sin Fin",
		},
		"de": {
			"HORDE_MODE": "Horden-Modus",
			"HORDE_MODE_DESC_ENEMIES": "Gegner: 5x Anzahl | -15% HP | -10% Schaden | +20% Tempo",
			"HORDE_MODE_DESC_PLAYER": "Spieler: -50% Materialien | -50% EP",
			"CHAL_HORDE_SURVIVOR": "Horden\u00fcberlebender",
			"CHAL_HORDE_SURVIVOR_DESC": "Gewinne einen Lauf im Horden-Modus",
			"CHAL_HORDE_SLAYER": "Horde Slayer",
			"CHAL_HORDE_SLAYER_DESC": "Gewinne im Horden-Modus auf Gefahr 5",
			"CHAL_HORDE_MASTER": "Horde Master",
			"CHAL_HORDE_MASTER_DESC": "Gewinne im Horden-Modus mit 5 verschiedenen Charakteren",
"CHAL_HORDE_ENDURANCE": "Horde Endurance",
			"CHAL_HORDE_ENDURANCE_DESC": "Welle 30 im Horden-Modus + Endlos erreichen",
		},
		"ru": {
			"HORDE_MODE": "\u0420\u0435\u0436\u0438\u043c \u043e\u0440\u0434\u044b",
			"HORDE_MODE_DESC_ENEMIES": "\u0412\u0440\u0430\u0433\u0438: 5x \u041a\u043e\u043b-\u0432\u043e | -15% \u0417\u0434. | -10% \u0423\u0440\u043e\u043d | +20% \u0421\u043a\u043e\u0440\u043e\u0441\u0442\u044c",
			"HORDE_MODE_DESC_PLAYER": "\u0418\u0433\u0440\u043e\u043a: -50% \u041c\u0430\u0442\u0435\u0440\u0438\u0430\u043b\u043e\u0432 | -50% \u041e\u043f\u044b\u0442",
			"CHAL_HORDE_SURVIVOR": "\u0412\u044b\u0436\u0438\u0432\u0448\u0438\u0439 \u0432 \u043e\u0440\u0434\u0435",
			"CHAL_HORDE_SURVIVOR_DESC": "\u041f\u043e\u0431\u0435\u0434\u0438\u0442\u044c \u0432 \u0440\u0435\u0436\u0438\u043c\u0435 \u043e\u0440\u0434\u044b",
			"CHAL_HORDE_SLAYER": "Horde Slayer",
			"CHAL_HORDE_SLAYER_DESC": "\u041f\u043e\u0431\u0435\u0434\u0438\u0442\u044c \u0432 \u0440\u0435\u0436\u0438\u043c\u0435 \u043e\u0440\u0434\u044b \u043d\u0430 \u041e\u043f\u0430\u0441\u043d\u043e\u0441\u0442\u044c 5",
			"CHAL_HORDE_MASTER": "Horde Master",
			"CHAL_HORDE_MASTER_DESC": "\u041f\u043e\u0431\u0435\u0434\u0438\u0442\u044c \u0432 \u0440\u0435\u0436\u0438\u043c\u0435 \u043e\u0440\u0434\u044b \u0437\u0430 5 \u0440\u0430\u0437\u043d\u044b\u0445 \u043f\u0435\u0440\u0441\u043e\u043d\u0430\u0436\u0435\u0439",
"CHAL_HORDE_ENDURANCE": "Horde Endurance",
			"CHAL_HORDE_ENDURANCE_DESC": "Reach wave 30 in Horde + Endless Mode",
		},
		"pt": {
			"HORDE_MODE": "Modo Horda",
			"HORDE_MODE_DESC_ENEMIES": "Inimigos: 5x Quantidade | -15% Vida | -10% Dano | +20% Velocidade",
			"HORDE_MODE_DESC_PLAYER": "Jogador: -50% Materiais | -50% XP",
			"CHAL_HORDE_SURVIVOR": "Sobrevivente da Horda",
			"CHAL_HORDE_SURVIVOR_DESC": "Vencer uma partida no Modo Horda",
			"CHAL_HORDE_SLAYER": "Horde Slayer",
			"CHAL_HORDE_SLAYER_DESC": "Vencer no Modo Horda no Perigo 5",
			"CHAL_HORDE_MASTER": "Horde Master",
			"CHAL_HORDE_MASTER_DESC": "Vencer no Modo Horda com 5 personagens diferentes",
"CHAL_HORDE_ENDURANCE": "Horde Endurance",
			"CHAL_HORDE_ENDURANCE_DESC": "Reach wave 30 in Horde + Endless Mode",
		},
		"pl": {
			"HORDE_MODE": "Tryb Hordy",
			"HORDE_MODE_DESC_ENEMIES": "Wrogowie: 5x Ilo\u015b\u0107 | -15% HP | -10% Obra\u017ce\u0144 | +20% Szybko\u015b\u0107",
			"HORDE_MODE_DESC_PLAYER": "Gracz: -50% Materia\u0142\u00f3w | -50% XP",
			"CHAL_HORDE_SURVIVOR": "Ocalony z Hordy",
			"CHAL_HORDE_SURVIVOR_DESC": "Wygraj parti\u0119 w Trybie Hordy",
			"CHAL_HORDE_SLAYER": "Horde Slayer",
			"CHAL_HORDE_SLAYER_DESC": "Wygraj w Trybie Hordy na Niebezpiecze\u0144stwo 5",
			"CHAL_HORDE_MASTER": "Horde Master",
			"CHAL_HORDE_MASTER_DESC": "Wygraj w Trybie Hordy 5 r\u00f3\u017cnymi postaciami",
"CHAL_HORDE_ENDURANCE": "Horde Endurance",
			"CHAL_HORDE_ENDURANCE_DESC": "Reach wave 30 in Horde + Endless Mode",
		},
		"it": {
			"HORDE_MODE": "Modalit\u00e0 Orda",
			"HORDE_MODE_DESC_ENEMIES": "Nemici: 5x Quantit\u00e0 | -15% Salute | -10% Danni | +20% Velocit\u00e0",
			"HORDE_MODE_DESC_PLAYER": "Giocatore: -50% Materiali | -50% XP",
			"CHAL_HORDE_SURVIVOR": "Sopravvissuto all'Orda",
			"CHAL_HORDE_SURVIVOR_DESC": "Vinci una partita in Modalit\u00e0 Orda",
			"CHAL_HORDE_SLAYER": "Horde Slayer",
			"CHAL_HORDE_SLAYER_DESC": "Vinci in Modalit\u00e0 Orda a Pericolo 5",
			"CHAL_HORDE_MASTER": "Horde Master",
			"CHAL_HORDE_MASTER_DESC": "Vinci in Modalit\u00e0 Orda con 5 personaggi diversi",
"CHAL_HORDE_ENDURANCE": "Horde Endurance",
			"CHAL_HORDE_ENDURANCE_DESC": "Reach wave 30 in Horde + Endless Mode",
		},
		"tr": {
			"HORDE_MODE": "S\u00fcr\u00fc Modu",
			"HORDE_MODE_DESC_ENEMIES": "D\u00fc\u015fmanlar: 5x Say\u0131 | -15% Can | -10% Hasar | +20% H\u0131z",
			"HORDE_MODE_DESC_PLAYER": "Oyuncu: -50% Malzeme | -50% XP",
			"CHAL_HORDE_SURVIVOR": "S\u00fcr\u00fc Hayatta Kalan\u0131",
			"CHAL_HORDE_SURVIVOR_DESC": "S\u00fcr\u00fc Modunda bir oyun kazan",
			"CHAL_HORDE_SLAYER": "Horde Slayer",
			"CHAL_HORDE_SLAYER_DESC": "S\u00fcr\u00fc Modunda Tehlike 5 ile kazan",
			"CHAL_HORDE_MASTER": "Horde Master",
			"CHAL_HORDE_MASTER_DESC": "S\u00fcr\u00fc Modunda 5 farkl\u0131 karakterle kazan",
"CHAL_HORDE_ENDURANCE": "Horde Endurance",
			"CHAL_HORDE_ENDURANCE_DESC": "Reach wave 30 in Horde + Endless Mode",
		},
		"zh": {
			"HORDE_MODE": "\u7fa4\u653b\u6a21\u5f0f",
			"HORDE_MODE_DESC_ENEMIES": "\u654c\u4eba: 5x \u6570\u91cf | -15% \u751f\u547d | -10% \u4f24\u5bb3 | +20% \u901f\u5ea6",
			"HORDE_MODE_DESC_PLAYER": "\u73a9\u5bb6: -50% \u6750\u6599 | -50% \u7ecf\u9a8c",
			"CHAL_HORDE_SURVIVOR": "\u7fa4\u653b\u5e78\u5b58\u8005",
			"CHAL_HORDE_SURVIVOR_DESC": "\u5728\u7fa4\u653b\u6a21\u5f0f\u4e2d\u83b7\u80dc",
			"CHAL_HORDE_SLAYER": "Horde Slayer",
			"CHAL_HORDE_SLAYER_DESC": "\u5728\u7fa4\u653b\u6a21\u5f0f\u5371\u96695\u4e2d\u83b7\u80dc",
			"CHAL_HORDE_MASTER": "Horde Master",
			"CHAL_HORDE_MASTER_DESC": "\u7528\u0035\u4e2a\u4e0d\u540c\u89d2\u8272\u5728\u7fa4\u653b\u6a21\u5f0f\u4e2d\u83b7\u80dc",
"CHAL_HORDE_ENDURANCE": "Horde Endurance",
			"CHAL_HORDE_ENDURANCE_DESC": "Reach wave 30 in Horde + Endless Mode",
		},
		"zh_TW": {
			"HORDE_MODE": "\u7fa4\u653b\u6a21\u5f0f",
			"HORDE_MODE_DESC_ENEMIES": "\u6575\u4eba: 5x \u6578\u91cf | -15% \u751f\u547d | -10% \u50b7\u5bb3 | +20% \u901f\u5ea6",
			"HORDE_MODE_DESC_PLAYER": "\u73a9\u5bb6: -50% \u7d20\u6750 | -50% \u7d93\u9a57",
			"CHAL_HORDE_SURVIVOR": "\u7fa4\u653b\u5016\u5b58\u8005",
			"CHAL_HORDE_SURVIVOR_DESC": "\u5728\u7fa4\u653b\u6a21\u5f0f\u4e2d\u7372\u52dd",
			"CHAL_HORDE_SLAYER": "Horde Slayer",
			"CHAL_HORDE_SLAYER_DESC": "\u5728\u7fa4\u653b\u6a21\u5f0f\u5371\u96aa5\u4e2d\u7372\u52dd",
			"CHAL_HORDE_MASTER": "Horde Master",
			"CHAL_HORDE_MASTER_DESC": "\u7528\u0035\u500b\u4e0d\u540c\u89d2\u8272\u5728\u7fa4\u653b\u6a21\u5f0f\u4e2d\u7372\u52dd",
"CHAL_HORDE_ENDURANCE": "Horde Endurance",
			"CHAL_HORDE_ENDURANCE_DESC": "Reach wave 30 in Horde + Endless Mode",
		},
		"ja": {
			"HORDE_MODE": "\u30db\u30fc\u30c9\u30e2\u30fc\u30c9",
			"HORDE_MODE_DESC_ENEMIES": "\u6575: 5x \u6570 | -15% HP | -10% \u30c0\u30e1\u30fc\u30b8 | +20% \u30b9\u30d4\u30fc\u30c9",
			"HORDE_MODE_DESC_PLAYER": "\u30d7\u30ec\u30a4\u30e4\u30fc: -50% \u30de\u30c6\u30ea\u30a2\u30eb | -50% XP",
			"CHAL_HORDE_SURVIVOR": "\u30db\u30fc\u30c9\u30b5\u30d0\u30a4\u30d0\u30fc",
			"CHAL_HORDE_SURVIVOR_DESC": "\u30db\u30fc\u30c9\u30e2\u30fc\u30c9\u3067\u52dd\u5229\u3059\u308b",
			"CHAL_HORDE_SLAYER": "Horde Slayer",
			"CHAL_HORDE_SLAYER_DESC": "\u30db\u30fc\u30c9\u30e2\u30fc\u30c9\u306e\u5371\u967a\u5ea65\u3067\u52dd\u5229\u3059\u308b",
			"CHAL_HORDE_MASTER": "Horde Master",
			"CHAL_HORDE_MASTER_DESC": "\u30db\u30fc\u30c9\u30e2\u30fc\u30c9\u30675\u4eba\u306e\u7570\u306a\u308b\u30ad\u30e3\u30e9\u30af\u30bf\u30fc\u3067\u52dd\u5229\u3059\u308b",
"CHAL_HORDE_ENDURANCE": "Horde Endurance",
			"CHAL_HORDE_ENDURANCE_DESC": "Reach wave 30 in Horde + Endless Mode",
		},
		"ko": {
			"HORDE_MODE": "\ubb34\ub9ac \ubaa8\ub4dc",
			"HORDE_MODE_DESC_ENEMIES": "\uc801: 5x \uc218 | -15% \uccb4\ub825 | -10% \ud53c\ud574 | +20% \uc18d\ub3c4",
			"HORDE_MODE_DESC_PLAYER": "\ud50c\ub808\uc774\uc5b4: -50% \uc7ac\ub8cc | -50% XP",
			"CHAL_HORDE_SURVIVOR": "\ubb34\ub9ac \uc0dd\uc874\uc790",
			"CHAL_HORDE_SURVIVOR_DESC": "\ubb34\ub9ac \ubaa8\ub4dc\uc5d0\uc11c \uc2b9\ub9ac",
			"CHAL_HORDE_SLAYER": "Horde Slayer",
			"CHAL_HORDE_SLAYER_DESC": "\ubb34\ub9ac \ubaa8\ub4dc \uc704\ud5d8 5\uc5d0\uc11c \uc2b9\ub9ac",
			"CHAL_HORDE_MASTER": "Horde Master",
			"CHAL_HORDE_MASTER_DESC": "\ubb34\ub9ac \ubaa8\ub4dc\uc5d0\uc11c 5\uba85\uc758 \ub2e4\ub978 \uce90\ub9ad\ud130\ub85c \uc2b9\ub9ac",
"CHAL_HORDE_ENDURANCE": "Horde Endurance",
			"CHAL_HORDE_ENDURANCE_DESC": "Reach wave 30 in Horde + Endless Mode",
		},
	}
	for locale in translations:
		var t = Translation.new()
		t.locale = locale
		for key in translations[locale]:
			t.add_message(key, translations[locale][key])
		TranslationServer.add_translation(t)
