extends Node

var blocks
var target
var current
var size
var dirs = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]

func start(start, target, max_tile_idx):
	blocks = []
	target = target
	current = start
	size = max_tile_idx
	freeblock()

func is_done():
	current == target

# current block is visited
func visited():
	current = blocks.pop_front()
	
# current block is blocked
func blocked():
	current = blocks.pop_front()

func is_in(pos):
	return pos.x >= 0 and pos.y >= 0 and pos.x < size.x and pos.y < size.y 

# current block is free
func freeblock():
	dirs.shuffle()
	for dir in dirs:
		var pos = current + dir
		if is_in(pos):
			blocks.append(pos)
	current = blocks.pop_front()

func current():
	return current
