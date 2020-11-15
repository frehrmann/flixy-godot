# This shall be used to store the information from where a field was visited.

extends Node

var data
var width

# Initialize storage with size.x and size.y
func init(size):
	var array = []
	for _i in range(size.x * size.y):
		array.append(Vector2(-1, -1))
	data = PoolVector2Array(array)
	width = size.x

func set_from(x, y, from_pos):
	if data[y*width+x].x == -1:
		data[y*width+x] = from_pos

func set_fromv(pos, from_pos):
	set_from(pos.x, pos.y, from_pos)

func get_from(x, y):
	return data[y*width+x]

func get_fromv(pos):
	return get_from(pos.x, pos.y)
	
func get_path_to(pos):
	var array = []
	while pos.x != -1:
		var prev = get_fromv(pos)
		array.push_back(prev) 
		pos = prev
	array.pop_back() # remove start field
	array.pop_back() # remove start field again
	return array
