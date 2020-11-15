extends Node

var blocks
var finish
var current_block
var start_pos
var size
var dirs = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]

func start(start, target, max_tile_idx):
	blocks = []
	finish = target
	current_block = start
	start_pos = start
	size = max_tile_idx
	$Storage.init(size)
	freeblock()

func is_done():
	return current_block == finish

# current block is visited
func visited():
	current_block = blocks.pop_front()
	
# current block is blocked
func blocked():
	current_block = blocks.pop_front()

func is_in(pos):
	return pos.x >= 0 and pos.y >= 0 and pos.x < size.x and pos.y < size.y 

# current block is free
func freeblock():
	dirs.shuffle()
	for dir in dirs:
		var pos = current_block + dir
		if is_in(pos) and pos != start_pos:
			$Storage.set_fromv(pos, current_block)
			blocks.append(pos)
	current_block = blocks.pop_front()

func current():
	return current_block

func get_path():
	return $Storage.get_path_to(finish)
