extends Node2D

enum { TILE_BLOCKED, TILE_VISITED, TILE_START, TILE_TARGET, TILE_PATH }
enum { NOSTATE, STATE_START, STATE_DRAW, STATE_SETSTART, STATE_SETTARGET,
	   STATE_SEARCH, STATE_NOTFOUND, STATE_GO, STATE_FINISHED }

var StateNames = {
	NOSTATE : "NOSTATE",
	STATE_START : "START",
	STATE_DRAW : "DRAW",
	STATE_SETSTART : "SET START",
	STATE_SETTARGET : "SET FINISH",
	STATE_SEARCH : "SEARCH",
	STATE_NOTFOUND : "NOT FOUND",
	STATE_GO : "GO",
	STATE_FINISHED : "FINISHED",
}

var current_state = STATE_START
var new_state = NOSTATE

var draw = false
var last_block_pos
var start_tile
var end_tile
var path = []
var set_ends = true

export var StepsPerCylce = 4
export(bool) var Debug = false

func _ready():
	for t in $Search.DISTTYPE.keys():
		$HUD.add_item_to_list(t)
	on_enter()

func start_search():
	var size = $TileMap.world_to_map(get_viewport().size) + Vector2(1,1)
	$Search.Type = $HUD.get_type()
	$Search.MixFactor = $HUD.get_factor()
	$Search.start(start_tile, end_tile, size)

func check_block():
	var tile_pos = $Search.current()
	if tile_pos == null:
		new_state = STATE_NOTFOUND
		return
	var tileid = $TileMap.get_cellv(tile_pos)
	if tileid == TILE_BLOCKED:
		$Search.blocked()
	elif tileid == TILE_VISITED or tileid == TILE_START:
		$Search.visited()
	elif tileid == TILE_TARGET:
		new_state = STATE_GO
		path = $Search.get_path()
	else:
		$TileMap.set_cellv(tile_pos, TILE_VISITED)
		$Search.freeblock()
	

func on_exit():
	if current_state == STATE_START:
		$HUD.hide_options()
	elif current_state == STATE_DRAW:
		$HUD.hide_weiter()


func on_enter():
	if current_state == STATE_START:
		$HUD.message("Tip to start!")
		$HUD.show_options()
	elif current_state == STATE_DRAW:
		clear_map()
		$HUD.message("Zeichne die Wände!")
		$HUD.show_weiter()
	elif current_state == STATE_SETSTART:
		$HUD.message("Wo ist der Start?")
	elif current_state == STATE_SETTARGET:
		$HUD.message("Wo ist das Ende?")
	elif current_state == STATE_SEARCH:
		$HUD.hide_message()
		start_search()
	elif current_state == STATE_NOTFOUND:
		$HUD.message("Kann das Ziel nicht erreichen!")
	elif current_state == STATE_FINISHED:
		$HUD.message("Fertig!")

func transition():
	if new_state != NOSTATE and new_state != current_state:
		if Debug: print("transition: %s -> %s " % [StateNames[current_state], StateNames[new_state]])
		on_exit()
		current_state = new_state
		on_enter()

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE:
			get_tree().quit(0)
	if event is InputEventMouseButton and !event.pressed:
		if current_state == STATE_SETSTART:
			start_tile = set_block(TILE_START)
			new_state = STATE_SETTARGET
		elif current_state == STATE_SETTARGET:
			end_tile = set_block(TILE_TARGET)
			new_state = STATE_SEARCH
			set_ends = false
		elif current_state == STATE_NOTFOUND:
			new_state = STATE_START
		elif current_state == STATE_FINISHED:
			new_state = STATE_START

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
	if event is InputEventMouseButton and !event.pressed:
		if current_state == STATE_START:
			new_state = STATE_DRAW

func _physics_process(delta):
	transition()
	if current_state == STATE_DRAW:
		state_draw_process(delta)
	elif current_state == STATE_SEARCH:
		for _i in range(max(1, StepsPerCylce)):
			check_block()
	elif current_state == STATE_GO:
		if path.empty():
			new_state = STATE_FINISHED
		else:
			var pos = path.pop_back()
			$TileMap.set_cellv(pos, TILE_PATH)

func clear_map():
	if $HUD.get_clear_map():
		$TileMap.clear()
		set_ends = true
	else:
		var size = $TileMap.world_to_map(get_viewport().size) + Vector2(1,1)
		for i in range(size.x):
			for j in range(size.y):
				var tile = $TileMap.get_cell(i, j)
				if tile == TILE_VISITED or tile == TILE_PATH:
					$TileMap.set_cell(i, j, -1)
				elif (tile == TILE_START or tile == TILE_TARGET) and $HUD.get_clear_ends():
					$TileMap.set_cell(i, j, -1)
					set_ends = true

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
	if set_ends:
		new_state = STATE_SETSTART
	else:
		new_state = STATE_SEARCH
