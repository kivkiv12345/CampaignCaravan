extends Resource

class_name CaravanUtils


static func delay(callable: Callable, time: float, node: Node):
	
	if time == 0.0:
		callable.call()
		return

	var timer: Timer = Timer.new()
	timer.wait_time = time
	timer.one_shot = true
	timer.connect("timeout", callable, ConnectFlags.CONNECT_ONE_SHOT)  # ONE_SHOT automatically cleans up
	node.add_child(timer)  # Add the timer to the scene tree
	timer.start()
