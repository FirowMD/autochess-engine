class_name AcCombatLogger
extends AcShowHide
## Combat Logger

const NAME_LOG_TEXT: String = "LogText"
## Used for menu button with following:
## "Clear" - Clear logs
## "Copy" - Copy logs to clipboard
const NAME_BTN_MENU: String = "BtnMenu"


## BBCode must be enabled in the RichTextLabel node
@export var log_label: RichTextLabel = null
## Menu button for log
@export var btn_menu: MenuButton = null
## Maximum number of lines to be printed in the log
@export var max_printed_lines: int = 100


func setup_child_nodes() -> void:
	const NODE_MAPPINGS = {
		NAME_LOG_TEXT: "log_label",
		NAME_BTN_MENU: "btn_menu"
	}
	
	for node in get_children():
		if node.name in NODE_MAPPINGS:
			set(NODE_MAPPINGS[node.name], node)


func setup_logger() -> void:
	if not check_setup_logger():
		push_error("setup is not complete (logger)")
		return
	init_menu()
	log_label.bbcode_enabled = true


func check_setup_logger() -> bool:
	if log_label == null:
		push_error("log_label not set")
		return false
	elif btn_menu == null:
		push_error("btn_menu not set")
		return false

	return true


func print_log(text: String) -> void:
	adjust_line_number_if_need()
	log_label.text += "[" + game_controller.get_current_time() + "] "
	log_label.text += text + "\n"


func print_log_ext(text: String, color: Color) -> void:
	adjust_line_number_if_need()
	log_label.text += "[color=" + color.to_html() + "]"
	log_label.text += "[" + game_controller.get_current_time() + "] "
	log_label.text += text
	log_label.text += "[/color]\n"

func print_log_format(template: String, ...values: Array) -> void:
	var formatted_text = template
	for i in range(values.size()):
		formatted_text = formatted_text.replace("{" + str(i) + "}", str(values[i]))
	print_log(formatted_text)

func print_log_format_color(template: String, color: Color, ...values: Array) -> void:
	var formatted_text = template
	for i in range(values.size()):
		formatted_text = formatted_text.replace("{" + str(i) + "}", str(values[i]))
	print_log_ext(formatted_text, color)


func clear_log() -> void:
	log_label.clear()


func adjust_line_number_if_need() -> void:
	var line_count: int = log_label.get_line_count()
	if line_count > max_printed_lines:
		clear_first_line()


func clear_first_line() -> void:
	log_label.text = log_label.text.substr(log_label.text.find("\n") + 1)


func copy_log_to_clipboard() -> void:
	DisplayServer.clipboard_set(log_label.text)


func init_menu() -> void:
	btn_menu.get_popup().add_item("Clear", 0)
	btn_menu.get_popup().add_separator("", 1)
	btn_menu.get_popup().add_item("Copy", 2)

	btn_menu.get_popup().connect("id_pressed", handler_menu_id_pressed)


func handler_menu_id_pressed(id) -> void:
	if id == 0:
		clear_log()
	elif id == 2:
		copy_log_to_clipboard()


func _validate_setup() -> bool:
	return super._validate_setup() and check_setup_logger()


func _ready() -> void:
	super._ready()
	setup_logger()

	game_controller.connect("controller_log_printed", print_log_ext)
