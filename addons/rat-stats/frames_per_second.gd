class_name FramesPerSecond extends MetricMonitor

func get_metric() -> Variant:
	return Performance.get_monitor(Performance.Monitor.TIME_FPS)
