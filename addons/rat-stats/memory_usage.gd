## Reports memory usage in MB. Only available in debug builds.
class_name MemoryUsage extends MetricMonitor

var is_debug = OS.is_debug_build()

func _get_metric() -> Variant:
	if !is_debug:
		return null
	return Performance.get_monitor(Performance.Monitor.MEMORY_STATIC) / 1_000_000
