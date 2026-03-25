extends Node

const MOD_DIR = "PapiLeem-HoardMode"
const MOD_LOG = "PapiLeem-HoardMode"

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
			RunData.hoard_config[key] = config.data[key]
		ModLoaderLog.info("Config loaded", MOD_LOG)


func _register_challenge():
	var chal_dir = "res://mods-unpacked/PapiLeem-HoardMode/content/challenges/"
	var challenges = {
		"hoard_survivor_data.tres": "_chal_hoard_survivor_hash",
		"hoard_slayer_data.tres": "_chal_hoard_slayer_hash",
		"hoard_master_data.tres": "_chal_hoard_master_hash",
		"hoard_endurance_data.tres": "_chal_hoard_endurance_hash",
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
			"HOARD_MODE": "Hoard Mode",
			"HOARD_MODE_DESC_ENEMIES": "Enemies: 5x Count | -40% HP | -20% Damage",
			"HOARD_MODE_DESC_PLAYER": "Player: -40% Materials | -40% XP",
			"CHAL_HOARD_SURVIVOR": "Hoard Survivor",
			"CHAL_HOARD_SURVIVOR_DESC": "Win a run in Hoard Mode",
			"CHAL_HOARD_SLAYER": "Hoard Slayer",
			"CHAL_HOARD_SLAYER_DESC": "Win a run in Hoard Mode on Danger 5",
			"CHAL_HOARD_MASTER": "Hoard Master",
			"CHAL_HOARD_MASTER_DESC": "Win Hoard Mode with 5 different characters",
"CHAL_HOARD_ENDURANCE": "Hoard Endurance",
			"CHAL_HOARD_ENDURANCE_DESC": "Reach wave 30 in Hoard + Endless Mode",
		},
		"fr": {
			"HOARD_MODE": "Mode Horde",
			"HOARD_MODE_DESC_ENEMIES": "Ennemis: 5x Nombre | -40% PV | -20% D\u00e9g\u00e2ts",
			"HOARD_MODE_DESC_PLAYER": "Joueur: -40% Mat\u00e9riaux | -40% XP",
			"CHAL_HOARD_SURVIVOR": "Survivant de la Horde",
			"CHAL_HOARD_SURVIVOR_DESC": "Gagner une partie en Mode Horde",
			"CHAL_HOARD_SLAYER": "Tueur de Horde",
			"CHAL_HOARD_SLAYER_DESC": "Gagner en Mode Horde au Danger 5",
			"CHAL_HOARD_MASTER": "Ma\u00eetre de la Horde",
			"CHAL_HOARD_MASTER_DESC": "Gagner en Mode Horde avec 5 personnages diff\u00e9rents",
"CHAL_HOARD_ENDURANCE": "Hoard Endurance",
			"CHAL_HOARD_ENDURANCE_DESC": "Atteindre la vague 30 en Mode Horde + Sans Fin",
		},
		"es": {
			"HOARD_MODE": "Modo Horda",
			"HOARD_MODE_DESC_ENEMIES": "Enemigos: 5x Cantidad | -40% Vida | -20% Da\u00f1o",
			"HOARD_MODE_DESC_PLAYER": "Jugador: -40% Materiales | -40% XP",
			"CHAL_HOARD_SURVIVOR": "Superviviente de la Horda",
			"CHAL_HOARD_SURVIVOR_DESC": "Ganar una partida en Modo Horda",
			"CHAL_HOARD_SLAYER": "Hoard Slayer",
			"CHAL_HOARD_SLAYER_DESC": "Ganar en Modo Horda en Peligro 5",
			"CHAL_HOARD_MASTER": "Hoard Master",
			"CHAL_HOARD_MASTER_DESC": "Ganar en Modo Horda con 5 personajes distintos",
"CHAL_HOARD_ENDURANCE": "Hoard Endurance",
			"CHAL_HOARD_ENDURANCE_DESC": "Alcanzar la oleada 30 en Modo Horda + Sin Fin",
		},
		"de": {
			"HOARD_MODE": "Horden-Modus",
			"HOARD_MODE_DESC_ENEMIES": "Gegner: 5x Anzahl | -40% HP | -20% Schaden",
			"HOARD_MODE_DESC_PLAYER": "Spieler: -40% Materialien | -40% EP",
			"CHAL_HOARD_SURVIVOR": "Horden\u00fcberlebender",
			"CHAL_HOARD_SURVIVOR_DESC": "Gewinne einen Lauf im Horden-Modus",
			"CHAL_HOARD_SLAYER": "Hoard Slayer",
			"CHAL_HOARD_SLAYER_DESC": "Gewinne im Horden-Modus auf Gefahr 5",
			"CHAL_HOARD_MASTER": "Hoard Master",
			"CHAL_HOARD_MASTER_DESC": "Gewinne im Horden-Modus mit 5 verschiedenen Charakteren",
"CHAL_HOARD_ENDURANCE": "Hoard Endurance",
			"CHAL_HOARD_ENDURANCE_DESC": "Welle 30 im Horden-Modus + Endlos erreichen",
		},
		"ru": {
			"HOARD_MODE": "\u0420\u0435\u0436\u0438\u043c \u043e\u0440\u0434\u044b",
			"HOARD_MODE_DESC_ENEMIES": "\u0412\u0440\u0430\u0433\u0438: 5x \u041a\u043e\u043b-\u0432\u043e | -40% \u0417\u0434. | -20% \u0423\u0440\u043e\u043d",
			"HOARD_MODE_DESC_PLAYER": "\u0418\u0433\u0440\u043e\u043a: -40% \u041c\u0430\u0442\u0435\u0440\u0438\u0430\u043b\u043e\u0432 | -40% \u041e\u043f\u044b\u0442",
			"CHAL_HOARD_SURVIVOR": "\u0412\u044b\u0436\u0438\u0432\u0448\u0438\u0439 \u0432 \u043e\u0440\u0434\u0435",
			"CHAL_HOARD_SURVIVOR_DESC": "\u041f\u043e\u0431\u0435\u0434\u0438\u0442\u044c \u0432 \u0440\u0435\u0436\u0438\u043c\u0435 \u043e\u0440\u0434\u044b",
			"CHAL_HOARD_SLAYER": "Hoard Slayer",
			"CHAL_HOARD_SLAYER_DESC": "\u041f\u043e\u0431\u0435\u0434\u0438\u0442\u044c \u0432 \u0440\u0435\u0436\u0438\u043c\u0435 \u043e\u0440\u0434\u044b \u043d\u0430 \u041e\u043f\u0430\u0441\u043d\u043e\u0441\u0442\u044c 5",
			"CHAL_HOARD_MASTER": "Hoard Master",
			"CHAL_HOARD_MASTER_DESC": "\u041f\u043e\u0431\u0435\u0434\u0438\u0442\u044c \u0432 \u0440\u0435\u0436\u0438\u043c\u0435 \u043e\u0440\u0434\u044b \u0437\u0430 5 \u0440\u0430\u0437\u043d\u044b\u0445 \u043f\u0435\u0440\u0441\u043e\u043d\u0430\u0436\u0435\u0439",
"CHAL_HOARD_ENDURANCE": "Hoard Endurance",
			"CHAL_HOARD_ENDURANCE_DESC": "Reach wave 30 in Hoard + Endless Mode",
		},
		"pt": {
			"HOARD_MODE": "Modo Horda",
			"HOARD_MODE_DESC_ENEMIES": "Inimigos: 5x Quantidade | -40% Vida | -20% Dano",
			"HOARD_MODE_DESC_PLAYER": "Jogador: -40% Materiais | -40% XP",
			"CHAL_HOARD_SURVIVOR": "Sobrevivente da Horda",
			"CHAL_HOARD_SURVIVOR_DESC": "Vencer uma partida no Modo Horda",
			"CHAL_HOARD_SLAYER": "Hoard Slayer",
			"CHAL_HOARD_SLAYER_DESC": "Vencer no Modo Horda no Perigo 5",
			"CHAL_HOARD_MASTER": "Hoard Master",
			"CHAL_HOARD_MASTER_DESC": "Vencer no Modo Horda com 5 personagens diferentes",
"CHAL_HOARD_ENDURANCE": "Hoard Endurance",
			"CHAL_HOARD_ENDURANCE_DESC": "Reach wave 30 in Hoard + Endless Mode",
		},
		"pl": {
			"HOARD_MODE": "Tryb Hordy",
			"HOARD_MODE_DESC_ENEMIES": "Wrogowie: 5x Ilo\u015b\u0107 | -40% HP | -20% Obra\u017ce\u0144",
			"HOARD_MODE_DESC_PLAYER": "Gracz: -40% Materia\u0142\u00f3w | -40% XP",
			"CHAL_HOARD_SURVIVOR": "Ocalony z Hordy",
			"CHAL_HOARD_SURVIVOR_DESC": "Wygraj parti\u0119 w Trybie Hordy",
			"CHAL_HOARD_SLAYER": "Hoard Slayer",
			"CHAL_HOARD_SLAYER_DESC": "Wygraj w Trybie Hordy na Niebezpiecze\u0144stwo 5",
			"CHAL_HOARD_MASTER": "Hoard Master",
			"CHAL_HOARD_MASTER_DESC": "Wygraj w Trybie Hordy 5 r\u00f3\u017cnymi postaciami",
"CHAL_HOARD_ENDURANCE": "Hoard Endurance",
			"CHAL_HOARD_ENDURANCE_DESC": "Reach wave 30 in Hoard + Endless Mode",
		},
		"it": {
			"HOARD_MODE": "Modalit\u00e0 Orda",
			"HOARD_MODE_DESC_ENEMIES": "Nemici: 5x Quantit\u00e0 | -40% Salute | -20% Danni",
			"HOARD_MODE_DESC_PLAYER": "Giocatore: -40% Materiali | -40% XP",
			"CHAL_HOARD_SURVIVOR": "Sopravvissuto all'Orda",
			"CHAL_HOARD_SURVIVOR_DESC": "Vinci una partita in Modalit\u00e0 Orda",
			"CHAL_HOARD_SLAYER": "Hoard Slayer",
			"CHAL_HOARD_SLAYER_DESC": "Vinci in Modalit\u00e0 Orda a Pericolo 5",
			"CHAL_HOARD_MASTER": "Hoard Master",
			"CHAL_HOARD_MASTER_DESC": "Vinci in Modalit\u00e0 Orda con 5 personaggi diversi",
"CHAL_HOARD_ENDURANCE": "Hoard Endurance",
			"CHAL_HOARD_ENDURANCE_DESC": "Reach wave 30 in Hoard + Endless Mode",
		},
		"tr": {
			"HOARD_MODE": "S\u00fcr\u00fc Modu",
			"HOARD_MODE_DESC_ENEMIES": "D\u00fc\u015fmanlar: 5x Say\u0131 | -40% Can | -20% Hasar",
			"HOARD_MODE_DESC_PLAYER": "Oyuncu: -40% Malzeme | -40% XP",
			"CHAL_HOARD_SURVIVOR": "S\u00fcr\u00fc Hayatta Kalan\u0131",
			"CHAL_HOARD_SURVIVOR_DESC": "S\u00fcr\u00fc Modunda bir oyun kazan",
			"CHAL_HOARD_SLAYER": "Hoard Slayer",
			"CHAL_HOARD_SLAYER_DESC": "S\u00fcr\u00fc Modunda Tehlike 5 ile kazan",
			"CHAL_HOARD_MASTER": "Hoard Master",
			"CHAL_HOARD_MASTER_DESC": "S\u00fcr\u00fc Modunda 5 farkl\u0131 karakterle kazan",
"CHAL_HOARD_ENDURANCE": "Hoard Endurance",
			"CHAL_HOARD_ENDURANCE_DESC": "Reach wave 30 in Hoard + Endless Mode",
		},
		"zh": {
			"HOARD_MODE": "\u7fa4\u653b\u6a21\u5f0f",
			"HOARD_MODE_DESC_ENEMIES": "\u654c\u4eba: 5x \u6570\u91cf | -40% \u751f\u547d | -20% \u4f24\u5bb3",
			"HOARD_MODE_DESC_PLAYER": "\u73a9\u5bb6: -40% \u6750\u6599 | -40% \u7ecf\u9a8c",
			"CHAL_HOARD_SURVIVOR": "\u7fa4\u653b\u5e78\u5b58\u8005",
			"CHAL_HOARD_SURVIVOR_DESC": "\u5728\u7fa4\u653b\u6a21\u5f0f\u4e2d\u83b7\u80dc",
			"CHAL_HOARD_SLAYER": "Hoard Slayer",
			"CHAL_HOARD_SLAYER_DESC": "\u5728\u7fa4\u653b\u6a21\u5f0f\u5371\u96695\u4e2d\u83b7\u80dc",
			"CHAL_HOARD_MASTER": "Hoard Master",
			"CHAL_HOARD_MASTER_DESC": "\u7528\u0035\u4e2a\u4e0d\u540c\u89d2\u8272\u5728\u7fa4\u653b\u6a21\u5f0f\u4e2d\u83b7\u80dc",
"CHAL_HOARD_ENDURANCE": "Hoard Endurance",
			"CHAL_HOARD_ENDURANCE_DESC": "Reach wave 30 in Hoard + Endless Mode",
		},
		"zh_TW": {
			"HOARD_MODE": "\u7fa4\u653b\u6a21\u5f0f",
			"HOARD_MODE_DESC_ENEMIES": "\u6575\u4eba: 5x \u6578\u91cf | -40% \u751f\u547d | -20% \u50b7\u5bb3",
			"HOARD_MODE_DESC_PLAYER": "\u73a9\u5bb6: -40% \u7d20\u6750 | -40% \u7d93\u9a57",
			"CHAL_HOARD_SURVIVOR": "\u7fa4\u653b\u5016\u5b58\u8005",
			"CHAL_HOARD_SURVIVOR_DESC": "\u5728\u7fa4\u653b\u6a21\u5f0f\u4e2d\u7372\u52dd",
			"CHAL_HOARD_SLAYER": "Hoard Slayer",
			"CHAL_HOARD_SLAYER_DESC": "\u5728\u7fa4\u653b\u6a21\u5f0f\u5371\u96aa5\u4e2d\u7372\u52dd",
			"CHAL_HOARD_MASTER": "Hoard Master",
			"CHAL_HOARD_MASTER_DESC": "\u7528\u0035\u500b\u4e0d\u540c\u89d2\u8272\u5728\u7fa4\u653b\u6a21\u5f0f\u4e2d\u7372\u52dd",
"CHAL_HOARD_ENDURANCE": "Hoard Endurance",
			"CHAL_HOARD_ENDURANCE_DESC": "Reach wave 30 in Hoard + Endless Mode",
		},
		"ja": {
			"HOARD_MODE": "\u30db\u30fc\u30c9\u30e2\u30fc\u30c9",
			"HOARD_MODE_DESC_ENEMIES": "\u6575: 5x \u6570 | -40% HP | -20% \u30c0\u30e1\u30fc\u30b8",
			"HOARD_MODE_DESC_PLAYER": "\u30d7\u30ec\u30a4\u30e4\u30fc: -40% \u30de\u30c6\u30ea\u30a2\u30eb | -40% XP",
			"CHAL_HOARD_SURVIVOR": "\u30db\u30fc\u30c9\u30b5\u30d0\u30a4\u30d0\u30fc",
			"CHAL_HOARD_SURVIVOR_DESC": "\u30db\u30fc\u30c9\u30e2\u30fc\u30c9\u3067\u52dd\u5229\u3059\u308b",
			"CHAL_HOARD_SLAYER": "Hoard Slayer",
			"CHAL_HOARD_SLAYER_DESC": "\u30db\u30fc\u30c9\u30e2\u30fc\u30c9\u306e\u5371\u967a\u5ea65\u3067\u52dd\u5229\u3059\u308b",
			"CHAL_HOARD_MASTER": "Hoard Master",
			"CHAL_HOARD_MASTER_DESC": "\u30db\u30fc\u30c9\u30e2\u30fc\u30c9\u30675\u4eba\u306e\u7570\u306a\u308b\u30ad\u30e3\u30e9\u30af\u30bf\u30fc\u3067\u52dd\u5229\u3059\u308b",
"CHAL_HOARD_ENDURANCE": "Hoard Endurance",
			"CHAL_HOARD_ENDURANCE_DESC": "Reach wave 30 in Hoard + Endless Mode",
		},
		"ko": {
			"HOARD_MODE": "\ubb34\ub9ac \ubaa8\ub4dc",
			"HOARD_MODE_DESC_ENEMIES": "\uc801: 5x \uc218 | -40% \uccb4\ub825 | -20% \ud53c\ud574",
			"HOARD_MODE_DESC_PLAYER": "\ud50c\ub808\uc774\uc5b4: -40% \uc7ac\ub8cc | -40% XP",
			"CHAL_HOARD_SURVIVOR": "\ubb34\ub9ac \uc0dd\uc874\uc790",
			"CHAL_HOARD_SURVIVOR_DESC": "\ubb34\ub9ac \ubaa8\ub4dc\uc5d0\uc11c \uc2b9\ub9ac",
			"CHAL_HOARD_SLAYER": "Hoard Slayer",
			"CHAL_HOARD_SLAYER_DESC": "\ubb34\ub9ac \ubaa8\ub4dc \uc704\ud5d8 5\uc5d0\uc11c \uc2b9\ub9ac",
			"CHAL_HOARD_MASTER": "Hoard Master",
			"CHAL_HOARD_MASTER_DESC": "\ubb34\ub9ac \ubaa8\ub4dc\uc5d0\uc11c 5\uba85\uc758 \ub2e4\ub978 \uce90\ub9ad\ud130\ub85c \uc2b9\ub9ac",
"CHAL_HOARD_ENDURANCE": "Hoard Endurance",
			"CHAL_HOARD_ENDURANCE_DESC": "Reach wave 30 in Hoard + Endless Mode",
		},
	}
	for locale in translations:
		var t = Translation.new()
		t.locale = locale
		for key in translations[locale]:
			t.add_message(key, translations[locale][key])
		TranslationServer.add_translation(t)
