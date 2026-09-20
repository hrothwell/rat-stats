## Maintains a log of metric points emitted by MetricMonitor instances.
## Logs are exported as <log_folder>/rat-stats/<utc timestamp at export time>.json.
class_name MetricRecorder extends Node

## Initial monitors that will be recorded in _metric_logs.
## Additional monitors can be recorded via record_monitor but will not be added here. If
## all currently recording monitors are needed use currently_recording.
@export
var _initial_monitors_to_record: Array[MetricMonitor] = []

## MetricMonitors that are currently being recorded.
var currently_recording: Array[MetricMonitor] = []

## Export logs on timer timeout. 
## If not present no logs will be exported unless export_logs is called manually.
@export 
var export_logs_timer: Timer

## Root folder to export logs.
@export
var log_folder: String = "user://logs/"

## Calculated log location. <log_folder>/rat-stats/
var _folder: String

## Entries contain: { utc_timestamp: String, metric: String, value: Variant }. 
var _metric_logs: Array[Dictionary]

func _ready() -> void:
	_folder = str(log_folder, "rat-stats/")
	if !DirAccess.dir_exists_absolute(_folder):
		DirAccess.make_dir_recursive_absolute(_folder)
	
	for m in _initial_monitors_to_record:
		record_monitor(m)
	
	if export_logs_timer:
		export_logs_timer.timeout.connect(export_logs)

## Start recording a new montior. Upon exiting tree this monitor will be removed from currently_recording.
func record_monitor(monitor: MetricMonitor) -> void:
	monitor.value_updated.connect(log_metric.bind(monitor.get_metric_name()))
	monitor.tree_exiting.connect(remove_monitor.bind(monitor))
	
	if !currently_recording.has(monitor):
		currently_recording.append(monitor)
	
## Stop recording monitor.
func remove_monitor(monitor: MetricMonitor) -> void:
	monitor.value_updated.disconnect(log_metric)
	monitor.tree_exiting.disconnect(remove_monitor)
	
	var index := currently_recording.find(monitor)
	if index > -1:
		currently_recording.remove_at(index)

## Record a new metric point.
func log_metric(value: Variant, name: String) -> void:
	_metric_logs.append(
		{
			"utc_timestamp": Time.get_datetime_string_from_system(true),
			 "metric": name,
			 "value": value
		}
	)

## Export the logs to configured folder. _metric_logs are cleared. 
func export_logs() -> void:
	var date_string := Time.get_datetime_string_from_system(true).replace(":", ".")
	var filepath: String = str(_folder, date_string, "Z", ".json")
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	file.store_line(JSON.stringify(_metric_logs))
	_metric_logs.clear()
