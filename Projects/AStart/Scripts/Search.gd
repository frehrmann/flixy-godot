extends Node

var blocks
var finish
var current_block
var start_pos
var size
var dirs = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]

enum DISTTYPE { BreadthFirst, AStarEukl, AStarDist }
export(DISTTYPE) var Type = DISTTYPE.BreadthFirst

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

func cmp_dist2finish_eukl(elem, pos):
	return elem.distance_to(finish) < pos.distance_to(finish)

func dist2finish(pos):
	return abs(pos.x - finish.x) + abs(pos.y - finish.y)

func cmp_dist2finish(elem, pos):
	return dist2finish(elem) < dist2finish(pos) 

func add_to_queue(pos):
	if !blocks.has(pos):
		if Type == DISTTYPE.AStarEukl:
			var idx = blocks.bsearch_custom(pos, self, "cmp_dist2finish_eukl")
			blocks.insert(idx, pos)
		elif Type == DISTTYPE.AStarDist:
			var idx = blocks.bsearch_custom(pos, self, "cmp_dist2finish")
			blocks.insert(idx, pos)
		else:
			blocks.push_back(pos)

# current block is free
func freeblock():
	dirs.shuffle()
	for dir in dirs:
		var pos = current_block + dir
		if is_in(pos) and pos != start_pos:
			$Storage.set_fromv(pos, current_block)
			add_to_queue(pos)
	current_block = blocks.pop_front()

func current():
	return current_block

func get_path():
	return $Storage.get_path_to(finish)
