class_name AcCombatLogger
extends AcShowHide
## Combat Logger

const NAME_SCROLL_CONTAINER = "ScrollContainer"


## BBCode must be enabled in the RichTextLabel node
@export var log_label: RichTextLabel = null
## Maximum number of lines to be printed in the log
@export var max_printed_lines: int = 100


func print_log(text: String) -> void:
	adjust_line_number_if_need()
	log_label.text += text + "\n"


func print_log_ext(text: String, color: Color) -> void:
	adjust_line_number_if_need()
	log_label.text += "[color=" + color.to_html() + "]" + text + "[/color]\n"


func clear_log() -> void:
	log_label.clear()


func adjust_line_number_if_need() -> void:
	var line_count = log_label.get_line_count()
	if line_count > max_printed_lines:
		clear_first_line()


func clear_first_line() -> void:
	log_label.text = log_label.text.substr(log_label.text.find("\n") + 1)


func _ready():
	ac_show_hide_ready()

	log_label.bbcode_enabled = true
