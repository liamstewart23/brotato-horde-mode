extends "res://ui/menus/pages/menu_options.gd"


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
