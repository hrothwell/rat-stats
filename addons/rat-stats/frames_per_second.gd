class_name FramesPerSecond extends MetricMonitor

func _get_metric() -> Variant:
	return Performance.get_monitor(Performance.Monitor.TIME_FPS)

func get_metric_name() -> String:
	return "FramesPerSecond"
