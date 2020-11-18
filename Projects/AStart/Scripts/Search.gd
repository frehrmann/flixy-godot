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
	$Storage.set_distv(start_pos, 0)
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
	
func cmp_traveld(elem, pos):
	var d_elem = $Storage.get_distv(elem)
	var d_pos = $Storage.get_distv(pos)
	if d_elem == -1 and d_pos == -1:
		return false
	elif d_elem == -1:
		return false
	elif d_pos == -1:
		return true
	else:
		return d_elem < d_pos

func get_idx(pos):
	if Type == DISTTYPE.AStarEukl:
		return blocks.bsearch_custom(pos, self, "cmp_dist2finish_eukl")
	elif Type == DISTTYPE.AStarDist:
		return blocks.bsearch_custom(pos, self, "cmp_dist2finish")
	else:
		return blocks.bsearch_custom(pos, self, "cmp_traveld")


func add_to_queue(pos):
	if !blocks.has(pos):
		blocks.insert(get_idx(pos), pos)


# current block is free
func freeblock():
	dirs.shuffle()
	for dir in dirs:
		var pos = current_block + dir
		var dist = $Storage.get_distv(current_block)
		if is_in(pos) and pos != start_pos:
			$Storage.set_fromv(pos, current_block)
			$Storage.set_distv(pos, dist+1)
			add_to_queue(pos)
	current_block = blocks.pop_front()

func current():
	return current_block

func get_path():
	return $Storage.get_path_to(finish)
