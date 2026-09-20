## Maintains a log of metric points emitted by MetricMonitor instances.
class_name MetricRecorder extends Node

## Monitors that will be recorded in _metric_logs
## Additional monitors can be recorded via record_monitor but will not be added here. If
## all currently recording monitors are needed use <>
@export
var _initial_monitors_to_record: Array[MetricMonitor] = []

## MetricMonitors that are currently being recorded
var currently_recording: Array[MetricMonitor] = []

## If not present no logs will be exported, must manually call export_logs
@export 
var dump_logs_timer: Timer

@export
var log_folder: String = "user://logs/"

var _metric_logs: Array[Dictionary]

func _ready() -> void:
	for m in _initial_monitors_to_record:
		record_monitor(m)
	
	if dump_logs_timer:
		dump_logs_timer.timeout.connect(export_logs)

func record_monitor(monitor: MetricMonitor) -> void:
	monitor.value_updated.connect(func(v: Variant): _log_metric(monitor.get_metric_name(), v))
	currently_recording.append(monitor)
	monitor.tree_exiting.connect(remove_monitor.bind(monitor))
	
func remove_monitor(monitor: MetricMonitor) -> void:
	var index := currently_recording.find(monitor)
	if index > -1:
		currently_recording.remove_at(index)

func _log_metric(name: String, value: Variant) -> void:
	_metric_logs.append(
		{
			"timestamp": Time.get_datetime_string_from_system(),
			 "name": name,
			 "value": value
		}
	)

func export_logs() -> void:
	var current_time := Time.get_datetime_dict_from_system()
	var date_string: String = str(current_time.get("year"), current_time.get("month"), current_time.get("day"), current_time.get("hour"), current_time.get("minute"), current_time.get("second"))
	var filepath: String = str(log_folder, "rat-stats-", date_string, ".json")
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	file.store_line(JSON.stringify(_metric_logs))
