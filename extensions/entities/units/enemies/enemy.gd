extends "res://entities/units/enemies/enemy.gd"


func init_effect_behaviors() -> void :
	# Fix base game bug: clear stale effect_behavior children before re-adding.
	# Cannot call parent because it has an assert that fails on pool reuse.
	for child in effect_behaviors.get_children():
		effect_behaviors.remove_child(child)
		child.queue_free()
	for effect_behavior_data in EffectBehaviorService.active_enemy_effect_behavior_data:
		effect_behaviors.add_child(effect_behavior_data.scene.instance().init(self))
