class_name AcCombatUnit
extends Node2D


const NAME_SPRITE = "UnitAnisprite"
const NAME_AVATAR = "UnitAvatar"
const NAME_TIMER = "UnitTimer"
const NAME_HP_BAR = "UnitHpBar"

const ATTACK_SPEED_MAX = 2000


@export_group("General")
## (!) Owner of the unit (if null, then it's a neutral unit)
@export var player: AcGamePlayer = null
## (!) Game group unit is assigned to (if null, then it's a neutral unit)
@export var group: AcGameGroup = null
## Position on the game board
@export var unit_pos: Vector2 = Vector2(0, 0)

@export_group("Base stats")
@export var base_hp: int = 10
@export var base_damage: int = 1
## Attacks per minute
@export var base_attack_speed: int = 20
## Attack range in tiles
@export var base_attack_range: float = 1.5
@export var base_move_speed: int = 100
## Cost it will take to buy this unit
@export var base_cost = 1
## Here you can set a label for the unit
## Which can be used to identify type of the unit
@export var base_labels: Array[AcTypes.CombatUnitLabel] = []
@export var base_power: AcTypes.CombatUnitPower = AcTypes.CombatUnitPower.STANDARD

@export_group("Advanced")
@export var sprite: AnimatedSprite2D = null
@export var avatar: Sprite2D = null
@export var timer: Timer = null
@export var hp_bar: ProgressBar = null

@export_group("Unit state")
@export var state: AcTypes.CombatUnitState = AcTypes.CombatUnitState.IDLE


# signal unit_ready_to_attack


var hp: int = base_hp
var move_speed: int = base_move_speed
var damage: int = base_damage
var attack_speed: int = base_attack_speed
var attack_timer_max: float = 60.0 / base_attack_speed
var attack_range: float = base_attack_range
var game_controller: AcGameController = null
## Also known as game board
var align_size: Vector2 = Vector2(128, 128)
var target_unit: AcCombatUnit = null

var is_moving: bool = false
var is_attacking: bool = false
var is_idling: bool = false
var move_path: Array = []

var enemy_groups = []


func check_sprite():
	var sframes = sprite.sprite_frames
	if sframes == null:
		push_error("sprite_frames is not set")
		return false
	else:
		var aninames = sframes.get_animation_names()
		if len(aninames) < 3:
			push_error("sprite_frames should have at least 3 animation names: idle, walk, attack")
		
		var need_names = ["idle", "walk", "attack"]
		for need_name in need_names:
			if not aninames.has(need_name):
				push_error("sprite_frames should have animation name: " + need_name)
				return false
	
	return true


func instantiate():
	var unit = duplicate(0xf)
	unit.hp = base_hp
	unit.move_speed = base_move_speed
	unit.attack_speed = base_attack_speed
	unit.attack_timer_max = 60.0 / unit.attack_speed
	unit.attack_range = base_attack_range
	unit.state = AcTypes.CombatUnitState.IDLE

	return unit


func destroy():
	game_controller.game_map.free_map_place(unit_pos)
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
	update_attack_timer(60.0 / attack_speed)


func change_group(group_to):
	group = group_to
	setup_enemy_groups()


func get_enemy_groups():
	return game_controller.get_enemy_groups(group)


func get_next_target():
	# Get the nearest CombatUnit of enemy_group
	# var target: AcCombatUnit = null
	# for egroup in enemy_groups:
	# 	var egroup_name = egroup.get_group_name()
	# 	var all_egroup_nodes = get_tree().get_nodes_in_group(egroup_name)

	# 	# Find nearest node
	# 	var min_distance = 1000000.0
	# 	for node in all_egroup_nodes:
	# 		if node is AcCombatUnit:
	# 			var distance = (node.unit_pos - unit_pos).length()
	# 			if distance < min_distance:
	# 				min_distance = distance
	# 				target = node

	# return target

	# Do not find min distance for each group
	# Just find which is in attack range
	# If there is no one in attack range
	# Then find the nearest one
	var target: AcCombatUnit = null
	var min_distance = 1000000.0
	for egroup in enemy_groups:
		var egroup_name = egroup.get_group_name()
		var all_egroup_nodes = get_tree().get_nodes_in_group(egroup_name)

		for node in all_egroup_nodes:
			if node is AcCombatUnit:
				var distance = (node.unit_pos - unit_pos).length()
				if distance <= attack_range:
					return node
				elif distance < min_distance:
					min_distance = distance
					target = node

	return target


func can_attack_target(target: AcCombatUnit):
	if has_wrong_pos():
		return false
	var distance = unit_pos.distance_to(target.unit_pos)
	if distance <= attack_range and target.is_moving == false:
		return true


func sprite_animation_finished():
	if state == AcTypes.CombatUnitState.ATTACK:
		is_attacking = false
		idle()


func idle():
	state = AcTypes.CombatUnitState.IDLE
	sprite.play(AcTypes.CombatUnitStateNames[state])
	timer.stop()
	timer.set_paused(true)


func walk():
	state = AcTypes.CombatUnitState.WALK
	sprite.play(AcTypes.CombatUnitStateNames[state])


func attack():
	state = AcTypes.CombatUnitState.ATTACK
	sprite.play(AcTypes.CombatUnitStateNames[state])
	if target_unit != null:
		target_unit.deal_damage(damage)


func adjust_sprite_direction(direction):
	if direction.x > 0:
		sprite.flip_h = false
	elif direction.x < 0:
		sprite.flip_h = true


func attack_unit(unit: AcCombatUnit):
	adjust_sprite_direction(get_position().direction_to(unit.position))
	target_unit = unit
	timer.wait_time = attack_timer_max
	timer.set_paused(false)
	timer.stop()
	timer.start()


func change_map_pos(new_pos):
	game_controller.game_map.move_map_place(unit_pos, new_pos)
	unit_pos = new_pos


## Start moving to target_position
## Returns true if unit can move to target_position
func move_to(target_position, delta):
	if is_moving == false:
		move_path = game_controller.game_map.find_map_path_full_scale(get_position(), target_position)
		if len(move_path) == 0:
			return false

		var dest_map_pos = game_controller.game_map.convert_to_map_pos(move_path[0])
		if game_controller.game_map.is_map_place_free(dest_map_pos) == false:
			return false

		change_map_pos(dest_map_pos)
		is_moving = true
		walk()

	var dest_pos = Vector2(move_path[0])
	var direction = dest_pos - position
	var velocity = move_speed * delta
	adjust_sprite_direction(direction)
	position = position.move_toward(dest_pos, velocity)

	if position == dest_pos:
		is_moving = false
	
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
	var real_pos = unit_pos * align_size + game_controller.game_map.get_position()
	set_position(real_pos)
	game_controller.game_map.take_map_place(unit_pos)


func setup_attack_timer():
	timer.wait_time = attack_timer_max
	timer.set_paused(true)
	timer.connect("timeout", attack)


func setup_group():
	if group == null:
		group = game_controller.group_manager.get_group_by_type(
			AcPctrl.AcGameGroup.neutral)

	#! Change color according to group unit is assigned to
	var group_color = group.get_group_color()
	set_modulate(group_color)


func setup_enemy_groups():
	enemy_groups = get_enemy_groups()


func update_attack_timer(attack_time):
	attack_timer_max = attack_time
	timer.wait_time = attack_timer_max
	timer.stop()
	timer.start()


func get_anisprite_size():
	var res_size = Vector2(0, 0)
	var sframes = sprite.sprite_frames
	var aninames = sframes.get_animation_names()
	if len(aninames) > 0:
		for aniname in aninames:
			var frame_count = sframes.get_frame_count(aniname)
			if frame_count > 0:
				var texture = sframes.get_frame_texture(aniname, 0)
				res_size = Vector2(texture.get_size().x, texture.get_size().y)
				
				return res_size
	
	return res_size	


## Returns `ImageTexture` for combat shop
## `scale_to_size` is Vector2i with required size of image
func get_image_for_shop(scale_to_size):
	var sframes = sprite.sprite_frames
	var aninames = sframes.get_animation_names()
	if len(aninames) > 0:
		for aniname in aninames:
			var frame_count = sframes.get_frame_count(aniname)
			if frame_count > 0:
				var texture = sframes.get_frame_texture(aniname, 0)
				var texture_size = texture.get_size()
				var scale_to = Vector2(scale_to_size.x / texture_size.x, scale_to_size.y / texture_size.y)
				var extracted_image = texture.get_image()
				extracted_image.resize(texture_size.x * scale_to.x, texture_size.y * scale_to.y)
				
				# Convert `Image` to `ImageTexture`
				return ImageTexture.create_from_image(extracted_image)
	

	return null


func setup_sprite():
	if check_sprite() == false:
		return
	
	scale = align_size / get_anisprite_size()
	sprite.offset = get_anisprite_size() / 2
	sprite.play("idle")
	sprite.connect("animation_finished", sprite_animation_finished)


func auto_setup():
	if is_inside_tree():
		game_controller = AcPctrl.get_game_controller(get_tree())
	else:
		push_error("not inside tree")
	
	var children = get_children()
	for child in children:
		if child.name == NAME_SPRITE:
			sprite = child
		elif child.name == NAME_AVATAR:
			avatar = child
		elif child.name == NAME_TIMER:
			timer = child
		elif child.name == NAME_HP_BAR:
			hp_bar = child


func check_setup():
	if sprite == null:
		push_error("sprite is not set")
		return false
	if avatar == null:
		push_error("avatar is not set")
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
func has_wrong_pos():
	return get_position() != unit_pos * align_size + game_controller.game_map.get_position()


## Move to your cell and do not stay on borders
func adjust_pos(delta):
	move_to(unit_pos * align_size + game_controller.game_map.get_position(), delta)


func combat(delta):
	var current_target = get_next_target()
	if current_target != null:
		is_idling = false

		if can_attack_target(current_target):
			if is_attacking == false:
				is_attacking = true
				attack_unit(current_target)
		else:
			var can_move = move_to(current_target.get_position(), delta)
			if not can_move:
				idle()
				is_idling = true
	elif has_wrong_pos():
		adjust_pos(delta)
	else:
		if is_idling == false:
			idle()
			is_idling = true


	# 	if not can_attack_target(current_target):
	# 		move_to(current_target.get_position(), delta)
	# 		return
		
	# 	# Distance between current_target.unit_pos and unit_pos
	# 	var map_distance = unit_pos.distance_to(current_target.unit_pos)
	# 	if map_distance <= attack_range + 1 and is_moving == false:
	# 		if is_attacking == false:
	# 			is_attacking = true
	# 			attack_unit(current_target)
	# 	else:
	# 		move_to(current_target.get_position(), delta)
	
	# elif get_position() != unit_pos * align_size + game_controller.game_map.get_position():
	# 	# If we stopped at the wrong position (between tiles for example)
	# 	move_to(unit_pos * align_size + game_controller.game_map.get_position(), delta)
	# else:
	# 	if is_idling == false:
	# 		idle()
	# 		is_idling = true


func preparation():
	pass


func _ready():
	auto_setup()
	setup_position()
	setup_sprite()
	setup_group()
	setup_enemy_groups()
	setup_attack_timer()
	if not check_setup():
		push_error("setup is not complete")

	update_hp_bar()


func _process(delta):
	var game_state = game_controller.get_game_state()
	
	if game_state == "combat":
		combat(delta)
	elif game_state == "preparation":
		preparation()