class_name AcCombatUnit
extends Node2D


const NAME_SPRITE: String = "UnitAnisprite"
const NAME_TIMER: String = "UnitTimer"
const NAME_HP_BAR: String = "UnitHpBar"

const ATTACK_SPEED_MAX: int = 2000


@export_group("General")
## (!) Owner of the unit (if null, then it's a neutral unit)
@export var player: AcGamePlayer = null
## (!) Game group unit is assigned to (if null, then it's a neutral unit)
@export var group: AcGameGroup = null
## Position on the game board
@export var unit_pos: Vector2 = Vector2(0, 0)
## Item ID that used to identify the unit, for example, in the shop
@export var item_id: int = -1

@export_group("Base stats")
@export var base_name: String = "Unit"
@export var base_hp: int = 10
@export var base_damage: int = 1
## Attacks per minute
@export var base_attack_speed: int = 20
## Attack range in tiles
@export var base_attack_range: float = 1.5
@export var base_move_speed: int = 100
## Cost it will take to buy this unit
@export var base_cost: int = 1
## Here you can set a label for the unit
## Which can be used to identify type of the unit
@export var base_labels: Array[AcTypes.CombatUnitLabel] = []
@export var base_power: AcTypes.CombatUnitPower = AcTypes.CombatUnitPower.STANDARD
## Which combat units you need to build this one
## You can see available list of combat units in `persistent_controller.tscn` (Also known as `AcPctrl`)
@export var base_crafting: Array[String] = []

@export_group("Advanced")
@export var sprite: AnimatedSprite2D = null
@export var timer: Timer = null
@export var hp_bar: ProgressBar = null

@export_group("Unit state")
@export var state: AcTypes.CombatUnitState = AcTypes.CombatUnitState.IDLE


signal unit_started_idling
signal unit_stopped_idling
signal unit_started_moving(delta)
signal unit_stopped_moving
signal unit_started_attacking
signal unit_stopped_attacking
signal unit_started_being_attacked
signal unit_stopped_being_attacked
signal unit_selected
signal unit_unselected
signal unit_dragging
signal unit_dropped
signal unit_destroyed
signal unit_target_changed
signal unit_target_destroyed


var hp: int = base_hp
var move_speed: int = base_move_speed
var damage: int = base_damage
var attack_speed: int = base_attack_speed
var attack_timer_max: float = 60.0 / base_attack_speed
var attack_range: float = base_attack_range
var game_controller: AcGameController = null
## Also known as game board
var align_size: Vector2 = Vector2(128, 128)
var target_unit: AcCombatUnit = null:
	set(new_value):
		if new_value == target_unit:
			return
		
		var prev_target = target_unit
		target_unit = new_value
		
		if prev_target != null:
			prev_target.disconnect("unit_destroyed", handler_target_unit_destroyed)
		
		if target_unit != null:
			target_unit.connect("unit_destroyed", handler_target_unit_destroyed)

		unit_target_changed.emit()
	get:
		return target_unit

## If you click on the unit, it will be chosen
## Then you can move it on the game board
var is_selected: bool = false
var is_dragging: bool = false

var move_path: Array = []

var enemy_groups: Array[Variant] = []


func check_sprite() -> bool:
	var sframes: SpriteFrames = sprite.sprite_frames
	if sframes == null:
		push_error("sprite_frames is not set")
		return false
	else:
		var aninames: PackedStringArray = sframes.get_animation_names()
		if len(aninames) < 3:
			push_error("sprite_frames should have at least 3 animation names: idle, walk, attack")
		
		var need_names: Array[Variant] = ["idle", "walk", "attack"]
		for need_name in need_names:
			if not aninames.has(need_name):
				push_error("sprite_frames should have animation name: " + need_name)
				return false
	
	return true


func instantiate() -> Node:
	var unit: Node = duplicate(0xf)
	unit.hp = base_hp
	unit.damage = base_damage
	unit.move_speed = base_move_speed
	unit.attack_speed = base_attack_speed
	unit.attack_timer_max = 60.0 / base_attack_speed
	unit.attack_range = base_attack_range
	unit.state = AcTypes.CombatUnitState.IDLE

	return unit


func destroy():
	game_controller.game_map.free_map_place(unit_pos)
	game_controller.unit_count -= 1
	game_controller.print_log(base_name + " has been killed", Color(1, 0, 0))
	if player != null:
		player.unit_count -= 1
	unit_destroyed.emit()

	queue_free()


func update_hp_bar():
	if hp == base_hp:
		hp_bar.set_visible(false)
	else:
		hp_bar.set_visible(true)
	
	hp_bar.max_value = base_hp
	hp_bar.value = hp


func deal_damage(dmg):
	hp -= dmg
	update_hp_bar()
	if hp <= 0:
		destroy()


func change_attack_speed(att_speed):
	if attack_speed > ATTACK_SPEED_MAX:
		attack_speed = ATTACK_SPEED_MAX
	attack_speed = att_speed
	update_attack_timer(60.0 / attack_speed / get_attack_animation_time())


func change_group(group_to):
	group = group_to
	setup_enemy_groups()


func handler_target_unit_destroyed():
	if target_unit != null:
		if target_unit.hp <= 0:
			target_unit = null
			break_attack()
			unit_target_destroyed.emit()


func break_attack():
	if state == AcTypes.CombatUnitState.ATTACK:
		timer.stop()
		unit_stopped_attacking.emit()
		unit_started_idling.emit()


func get_enemy_groups() -> Array:
	return game_controller.get_enemy_groups(group)


func get_next_target() -> AcCombatUnit:
	var possible_targets = find_targets_in_attack_range()
	if len(possible_targets) == 0:
		return find_nearest_target()

	var result = null
	# Find target which doesn't move
	for target in possible_targets:
		result = target
		if target.state != AcTypes.CombatUnitState.WALK:
			return target

	return result


func find_nearest_target() -> AcCombatUnit:
	var min_distance: float = 1000000.0
	var target: AcCombatUnit = null
	for egroup in enemy_groups:
		var egroup_name = egroup.get_group_name()
		var all_egroup_nodes: Array[Variant] = get_tree().get_nodes_in_group(egroup_name)

		for node in all_egroup_nodes:
			if node is AcCombatUnit:
				var distance = (node.unit_pos - unit_pos).length()
				if distance < min_distance:
					min_distance = distance
					target = node

	return target


func find_targets_in_attack_range() -> Array[AcCombatUnit]:
	var targets: Array[AcCombatUnit] = []
	for egroup in enemy_groups:
		var egroup_name = egroup.get_group_name()
		var all_egroup_nodes: Array[Variant] = get_tree().get_nodes_in_group(egroup_name)

		for node in all_egroup_nodes:
			if node is AcCombatUnit:
				var distance = (node.unit_pos - unit_pos).length()
				if distance <= attack_range:
					targets.append(node)

	return targets


func can_attack_target(target: AcCombatUnit) -> bool:
	if has_wrong_pos():
		return false
	
	var distance: float = unit_pos.distance_to(target.unit_pos)
	if distance <= attack_range and target.state != AcTypes.CombatUnitState.WALK:
		return true
	
	return false


func sprite_animation_finished():
	if state == AcTypes.CombatUnitState.ATTACK:
		if target_unit == null:
			unit_stopped_attacking.emit()
			unit_started_idling.emit()
			return

		var log: String = base_name + " dealt " + str(damage) + " damage to " + target_unit.base_name
		game_controller.print_log(log)
		
		target_unit.deal_damage(damage)
		unit_stopped_attacking.emit()
		unit_started_idling.emit()


func idle() -> void:
	if state != AcTypes.CombatUnitState.IDLE:
		return
	
	sprite.play(AcTypes.CombatUnitStateNames[state])


func walk() -> void:
	if state != AcTypes.CombatUnitState.WALK:
		return
	
	sprite.play(AcTypes.CombatUnitStateNames[state])


func attack() -> void:
	if state != AcTypes.CombatUnitState.ATTACK:
		return
	
	adjust_sprite_direction(get_position().direction_to(target_unit.position))
	if timer.time_left == 0:
		start_attack()
	cooldown_attack()


func cooldown_attack():
	timer.wait_time = attack_timer_max
	timer.set_paused(false)
	timer.stop()
	timer.start(attack_timer_max)


func start_attack():
	if state != AcTypes.CombatUnitState.ATTACK:
		return
	
	sprite.play(AcTypes.CombatUnitStateNames[state])


func adjust_sprite_direction(direction):
	if direction.x > 0:
		sprite.flip_h = false
	elif direction.x < 0:
		sprite.flip_h = true


func change_map_pos(new_pos):
	game_controller.game_map.move_map_place(unit_pos, new_pos)
	unit_pos = new_pos


## Start moving to target_position
## Returns true if unit can move to target_position
func move_to(target_position, delta) -> bool:
	if state != AcTypes.CombatUnitState.WALK:
		move_path = game_controller.game_map.find_map_path_full_scale(get_position(), target_position)
		if len(move_path) == 0:
			return false

		var dest_map_pos: Vector2i = game_controller.game_map.convert_to_map_pos(move_path[0])
		if game_controller.game_map.is_map_place_free(dest_map_pos) == false:
			return false

		change_map_pos(dest_map_pos)
		unit_started_moving.emit(delta)
		

	var dest_pos: Vector2 = Vector2(move_path[0])
	var direction: Vector2 = dest_pos - position
	var velocity = move_speed * delta
	adjust_sprite_direction(direction)
	position = position.move_toward(dest_pos, velocity)

	if position == dest_pos:
		unit_stopped_moving.emit()
		unit_started_idling.emit()
	
	return true


func check_map_position():
	if unit_pos.x > game_controller.game_map.map_width:
		unit_pos.x = game_controller.game_map.map_width - 1
		push_error("unit_pos.x is out of map")
	elif unit_pos.x < 0:
		unit_pos.x = 0
		push_error("unit_pos.x is out of map")
	
	if unit_pos.y > game_controller.game_map.map_height:
		unit_pos.y = game_controller.game_map.map_height - 1
		push_error("unit_pos.y is out of map")
	elif unit_pos.y < 0:
		unit_pos.y = 0
		push_error("unit_pos.y is out of map")


func setup_position():
	check_map_position()

	align_size = game_controller.game_map.tile_size
	# var real_pos = unit_pos * align_size + game_controller.game_map.get_position()
	var real_pos: Vector2i = game_controller.game_map.convert_from_map_pos(unit_pos)
	set_position(real_pos)
	game_controller.game_map.take_map_place(unit_pos)


func setup_attack_timer():
	timer.wait_time = attack_timer_max
	timer.set_paused(true)
	timer.connect("timeout", start_attack)


func setup_group():
	if group == null:
		var neutral_groups = game_controller.group_manager.get_groups_by_type(
			AcTypes.GameGroupType.NEUTRAL)
		if neutral_groups.size() > 0:
			group = neutral_groups[0]

	add_to_group(group.get_group_name(), false)
	
	#! Change color according to group unit is assigned to
	var group_color: Color = group.get_group_color()
	
	hp_bar.modulate = group_color


func setup_enemy_groups():
	enemy_groups = get_enemy_groups()


func get_attack_animation_time():
	var anim_fps = sprite.frames.get_animation_speed("attack")
	return 1.0 / anim_fps


func update_attack_timer(attack_time):
	attack_timer_max = attack_time
	timer.wait_time = attack_timer_max
	timer.stop()
	timer.start()


func get_anisprite_size() -> Vector2:
	var res_size: Vector2 = Vector2(0, 0)
	var sframes: SpriteFrames = sprite.sprite_frames
	var aninames: PackedStringArray = sframes.get_animation_names()
	if len(aninames) > 0:
		for aniname in aninames:
			var frame_count: int = sframes.get_frame_count(aniname)
			if frame_count > 0:
				var texture: Texture2D = sframes.get_frame_texture(aniname, 0)
				res_size = Vector2(texture.get_size().x, texture.get_size().y)
				
				return res_size
	
	return res_size	


## Returns `ImageTexture` for combat shop
## `scale_to_size` is Vector2i with required size of image
func get_image_for_shop(scale_to_size) -> ImageTexture:
	var sframes: SpriteFrames = sprite.sprite_frames
	var aninames: PackedStringArray = sframes.get_animation_names()
	if len(aninames) > 0:
		for aniname in aninames:
			var frame_count: int = sframes.get_frame_count(aniname)
			if frame_count > 0:
				var texture: Texture2D = sframes.get_frame_texture(aniname, 0)
				var texture_size: Vector2 = texture.get_size()
				var scale_to: Vector2 = Vector2(scale_to_size.x / texture_size.x, scale_to_size.y / texture_size.y)
				var extracted_image: Image = texture.get_image()
				extracted_image.resize(texture_size.x * scale_to.x, texture_size.y * scale_to.y)
				
				# Convert `Image` to `ImageTexture`
				return ImageTexture.create_from_image(extracted_image)
	
	return null


func setup_sprite() -> void:
	if check_sprite() == false:
		return
	
	scale = align_size / get_anisprite_size()
	sprite.play("idle")
	sprite.connect("animation_finished", sprite_animation_finished)


func _ready() -> void:
	setup_references()
	setup_unit()
	setup_signals()
	setup_group()
	initialize_state()

	hp = base_hp


func setup_references() -> void:
	setup_controllers()
	setup_child_nodes()


func setup_controllers() -> void:
	if not is_inside_tree():
		push_error("not inside tree")
		return
	
	game_controller = AcPctrl.get_game_controller(get_tree())


func setup_child_nodes() -> void:
	const NODE_MAPPINGS = {
		NAME_SPRITE: "sprite",
		NAME_TIMER: "timer",
		NAME_HP_BAR: "hp_bar"
	}
	
	for node in get_children():
		if node.name in NODE_MAPPINGS:
			set(NODE_MAPPINGS[node.name], node)


func setup_unit() -> void:
	setup_position()
	setup_sprite()
	setup_group()
	setup_enemy_groups()
	setup_attack_timer()
	
	if not check_setup():
		push_error("setup is not complete")

	update_hp_bar()
	
	# Update counters
	game_controller.unit_count += 1
	if player != null:
		player.unit_count += 1


func setup_signals() -> void:
	# Combat signals
	connect("unit_started_idling", handler_unit_started_idling)
	connect("unit_stopped_idling", handler_unit_stopped_idling)
	connect("unit_started_moving", handler_unit_started_moving)
	connect("unit_stopped_moving", handler_unit_stopped_moving)
	connect("unit_started_attacking", handler_unit_started_attacking)
	connect("unit_stopped_attacking", handler_unit_stopped_attacking)
	connect("unit_started_being_attacked", handler_unit_started_being_attacked)
	connect("unit_stopped_being_attacked", handler_unit_stopped_being_attacked)
	
	# Selection signals
	connect("unit_selected", handler_unit_selected)
	connect("unit_unselected", handler_unit_unselected)

	# Sprite signals
	sprite.connect("animation_finished", sprite_animation_finished)
	
	# Timer signals
	timer.connect("timeout", start_attack)


func initialize_state() -> void:
	timer.wait_time = attack_timer_max
	timer.set_paused(true)
	sprite.play("idle")


func check_setup() -> bool:
	if sprite == null:
		push_error("sprite is not set")
		return false
	if timer == null:
		push_error("timer is not set")
		return false
	if game_controller == null:
		push_error("game_controller is not set")
		return false
	if player == null:
		push_error("player is not set")
		return false
	if group == null:
		push_error("group is not set")
		return false
	if hp_bar == null:
		push_error("hp_bar is not set")
		return false

	return true

## Situation when unit stops between cells
func has_wrong_pos() -> bool:
	return Vector2i(get_position()) != game_controller.game_map.convert_from_map_pos(unit_pos)


## Move to your cell and do not stay on borders
func adjust_pos(delta):
	move_to(unit_pos * align_size + game_controller.game_map.get_position(), delta)


func adjust_pos_instanly():
	position = game_controller.game_map.convert_from_map_pos(unit_pos)
	change_map_pos(unit_pos)


func handler_unit_started_idling() -> void:
	update_state(AcTypes.CombatUnitState.IDLE)


func handler_unit_stopped_idling():
	state = AcTypes.CombatUnitState.UNKNOWN


func handler_unit_started_moving(delta) -> void:
	update_state(AcTypes.CombatUnitState.WALK)


func handler_unit_stopped_moving():
	state = AcTypes.CombatUnitState.UNKNOWN


func handler_unit_started_attacking() -> void:
	update_state(AcTypes.CombatUnitState.ATTACK)


func handler_unit_stopped_attacking():
	state = AcTypes.CombatUnitState.UNKNOWN


func handler_unit_started_being_attacked():
	pass


func handler_unit_stopped_being_attacked():
	pass


func is_path_to_target_free(target_position) -> bool:
	var path: Array[Variant] = game_controller.game_map.find_map_path_full_scale(get_position(), target_position)
	if len(path) == 0:
		return false

	var dest_map_pos: Vector2i = game_controller.game_map.convert_to_map_pos(path[0])
	if game_controller.game_map.is_map_place_free(dest_map_pos) == false:
		return false

	return true


func update_state(new_state):
	if state == new_state:
		return
	
	match state:
		AcTypes.CombatUnitState.IDLE:
			unit_stopped_idling.emit()
		AcTypes.CombatUnitState.WALK:
			unit_stopped_moving.emit()
		AcTypes.CombatUnitState.ATTACK:
			unit_stopped_attacking.emit()

	state = new_state
	match state:
		AcTypes.CombatUnitState.IDLE:
			idle()
		AcTypes.CombatUnitState.WALK:
			walk()
		AcTypes.CombatUnitState.ATTACK:
			attack()


func handler_unit_selected():
	game_controller.selected_unit = self
	game_controller.combat_interface.show_unit_selection()
	game_controller.combat_interface.set_unit_selection_color(group.get_group_color())
	game_controller.combat_interface.set_unit_selection_pos(get_position())


func handler_unit_unselected():
	if game_controller.selected_unit == self:
		game_controller.unset_selected_unit()
		game_controller.combat_interface.hide_unit_selection()


func adjust_drop_coord(coord: float, align_sz: float) -> int:
	var res = coord / align_sz
	res = res * align_sz + align_sz / 2
	return res


func drop_unit():
	position.x = adjust_drop_coord(position.x, align_size.x)
	position.y = adjust_drop_coord(position.y, align_size.y)

	var new_pos: Vector2i = game_controller.game_map.convert_to_map_pos(get_position())
	if game_controller.game_map.is_map_place_free(new_pos):
		change_map_pos(new_pos)
		position = game_controller.game_map.convert_from_map_pos(new_pos)


func drop_unit_selection():
	var pos_aligned: Vector2 = get_position()
	pos_aligned.x = adjust_drop_coord(pos_aligned.x, align_size.x)
	pos_aligned.y = adjust_drop_coord(pos_aligned.y, align_size.y)

	pos_aligned = game_controller.game_map.convert_to_map_pos(pos_aligned)
	pos_aligned = game_controller.game_map.convert_from_map_pos(pos_aligned)
	game_controller.combat_interface.set_unit_selection_pos(pos_aligned)


func combat(delta):
	target_unit  = get_next_target()
	if target_unit != null:
		if can_attack_target(target_unit):
			unit_started_attacking.emit()
		else:
			move_to(target_unit.get_position(), delta)
	else:
		if has_wrong_pos():
			adjust_pos(delta)
		else:
			unit_started_idling.emit()


func preparation():
	if state != AcTypes.CombatUnitState.IDLE:
		unit_started_idling.emit()

	if is_selected:
		drop_unit_selection()

	if is_dragging:
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()

		# Keep unit inside the game board
		mouse_pos.x = clamp(
			mouse_pos.x,
			game_controller.game_map.position.x + 1,
			game_controller.game_map.position.x + game_controller.game_map.map_width * align_size.x - 1)
		
		mouse_pos.y = clamp(
			mouse_pos.y,
			game_controller.game_map.position.y + 1,
			game_controller.game_map.position.y + game_controller.game_map.map_height * align_size.y - 1)

		position = mouse_pos
	elif has_wrong_pos():
		adjust_pos_instanly()


func _process(delta):
	var game_state: String = game_controller.game_state

	if game_state == "combat":
		combat(delta)
	elif game_state == "preparation":
		preparation()


func _input(event) -> void:
	if game_controller.game_state == "combat":
		return
	
	if event.is_action_pressed("app_click"):
		var rect: Rect2 = Rect2(position - align_size / 2, align_size)
		if rect.has_point(event.position):
			if is_selected != true:
				is_selected = true
				unit_selected.emit()
			else:
				is_dragging = true
				unit_dragging.emit()
		else:
			if is_selected != false:
				is_selected = false
				unit_unselected.emit()
	
	if event.is_action_released("app_click"):
		if is_dragging:
			is_dragging = false
			drop_unit()
			unit_dropped.emit()
