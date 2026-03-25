extends "res://main.gd"


func _on_EndWaveTimer_timeout() -> void :
	if RunData.is_hoard_mode:
		if RunData._chal_hoard_endurance_hash != 0 and RunData.is_endless_run and RunData.current_wave >= 30:
			ChallengeService.complete_challenge(RunData._chal_hoard_endurance_hash)

	._on_EndWaveTimer_timeout()


func get_node_from_pool(id: int, parent: Node) -> Node:
	if _current_pool_id != id:
		_current_pool_id = id
		if _pool.has(id):
			_current_pool = _pool[id]
		else:
			_pool[id] = []
			_current_pool = _pool[id]
			return null

	while not _current_pool.empty():
		var node = _current_pool.pop_back()
		if is_instance_valid(node):
			parent.add_child(node)
			return node

	return null


func add_node_to_pool(node: Node, id: int) -> void :
	assert (_pool.has(id))
	if not is_instance_valid(node):
		return
	_add_node_to_pool(node, id)


func _exit_tree() -> void :
	InputService.set_gamepad_echo_processing(true)
	if _pool != null:
		for key in _pool.keys():
			var pool = _pool[key]
			for node in pool:
				if is_instance_valid(node):
					node.queue_free()
