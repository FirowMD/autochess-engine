class_name AcCombatLogger
extends AcShowHide
## Combat Logger

const NAME_SCROLL_CONTAINER = "ScrollContainer"


## BBCode must be enabled in the RichTextLabel node
@export var log_label: RichTextLabel = null
## Maximum number of lines to be printed in the log
@export var max_printed_lines: int = 5


func print_log(text: String, color: Color = Color(1, 1, 1)) -> void:
	if log_label.get_line_count() > max_printed_lines:
		clear_first_line()
	
	log_label.append_text(text + "\n")
	log_label.scroll_to_line(log_label.get_line_count() - 1)


func clear_log() -> void:
	log_label.clear()


func clear_first_line() -> void:
	var tmp_text = log_label.get_parsed_text()
	var first_line_end = tmp_text.find("\n")
	tmp_text = tmp_text.substr(first_line_end + 1)
	clear_log()
	log_label.append_text(tmp_text)
