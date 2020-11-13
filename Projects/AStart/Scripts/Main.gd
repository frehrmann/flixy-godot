extends Node2D

enum { TILE_BLOCKED, TILE_VISITED, TILE_START, TILE_TARGET, TILE_CURRENT }
enum { NOSTATE, STATE_START, STATE_DRAW, STATE_SETSTART, STATE_SETTARGET, STATE_SEARCH }

var current_state = STATE_START
var new_state = NOSTATE

var draw = false
var last_block_pos
var start_tile
var end_tile

func start_search():
	var size = get_viewport().size
	$Search.start(start_tile, end_tile, $TileMap.world_to_map(size))

func check_block():
	var tile_pos = $Search.current()
	var tileid = $TileMap.get_cellv(tile_pos)
	if tileid == TILE_BLOCKED:
		$Search.blocked()
	elif tileid == TILE_VISITED or tileid == TILE_START:
		$Search.visited()
	elif tileid == TILE_TARGET:
		new_state = STATE_START
	else:
		$TileMap.set_cellv(tile_pos, TILE_VISITED)
		$Search.freeblock()
	

func on_exit():
	if current_state == STATE_DRAW:
		$HUD.hide_weiter()
	elif current_state == STATE_SEARCH:
		$HUD.show_message()
		$HUD.message("Fertig!")

func on_enter():
	if current_state == STATE_DRAW:
		$TileMap.clear()
		$HUD.message("Zeichen die Wände")
		$HUD.show_weiter()
	elif current_state == STATE_SETSTART:
		$HUD.message("Wo ist der Start?")
	elif current_state == STATE_SETTARGET:
		$HUD.message("Wo ist das Ende?")
	elif current_state == STATE_SEARCH:
		$HUD.hide_message()
		start_search()

func transition():
	if new_state != NOSTATE and new_state != current_state:
		on_exit()
		current_state = new_state
		on_enter()

func _ready():
	$HUD.message("Tip to start!")

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE:
			get_tree().quit(0)
	if event is InputEventMouseButton and !event.pressed:
		if current_state == STATE_START:
			new_state = STATE_DRAW
		elif current_state == STATE_SETSTART:
			start_tile = set_block(TILE_START)
			new_state = STATE_SETTARGET
		elif current_state == STATE_SETTARGET:
			end_tile = set_block(TILE_TARGET)
			new_state = STATE_SEARCH

func _unhandled_input(event):
	if current_state == STATE_DRAW:
			if event is InputEventMouseButton:
				if event.pressed:
					$HUD.hide_weiter()
					last_block_pos = get_global_mouse_position()
					draw = true
				else:
					$HUD.show_weiter()
					draw = false

func _physics_process(delta):
	transition()
	if current_state == STATE_DRAW:
		state_draw_process(delta)
	elif current_state == STATE_SEARCH:
		for _i in range(4):
			check_block()

func state_draw_process(_delta):
	if draw:
		var pos = get_global_mouse_position()
		block_line(last_block_pos, pos)
		last_block_pos = pos
 
func block_line(start_pos, end_pos):
	var starti = $TileMap.world_to_map(start_pos)
	var endi = $TileMap.world_to_map(end_pos)
	var n = floor(starti.distance_to(endi) + 1)
	$TileMap.set_cellv(starti, TILE_BLOCKED)
	for _i in range(n):
		starti = starti.move_toward(endi, 1.0)
		$TileMap.set_cellv(starti, TILE_BLOCKED)

func set_block(block_id):
	var map_mouse_pos = $TileMap.world_to_map(get_global_mouse_position())
	$TileMap.set_cellv(map_mouse_pos, block_id)
	return map_mouse_pos

func _on_HUD_weiter():
	new_state = STATE_SETSTART