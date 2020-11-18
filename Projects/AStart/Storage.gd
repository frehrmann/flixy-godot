# This shall be used to store the information from where a field was visited.

extends Node

var from_data
var width
var travel_dist

# Initialize storage with size.x and size.y
func init(size):
	var array = []
	var dist_array = []
	for _i in range(size.x * size.y):
		array.append(Vector2(-1, -1))
		dist_array.append(-1)
	from_data = PoolVector2Array(array)
	travel_dist = PoolIntArray(dist_array)
	width = size.x

func set_from(x, y, from_pos):
	if from_data[y*width+x].x == -1:
		from_data[y*width+x] = from_pos

func set_fromv(pos, from_pos):
	set_from(pos.x, pos.y, from_pos)

func get_from(x, y):
	return from_data[y*width+x]

func get_fromv(pos):
	return get_from(pos.x, pos.y)

func get_dist(x, y):
	return travel_dist[y*width+x]

func get_distv(pos):
	return get_dist(pos.x, pos.y)

func set_dist(x, y, dist):
	var val = get_dist(x, y)
	if val == -1 or dist < val:
		travel_dist[y*width+x] = dist 

func set_distv(pos, dist):
	set_dist(pos.x, pos.y, dist)

func get_path_to(pos):
	var array = []
	while pos.x != -1:
		var prev = get_fromv(pos)
		array.push_back(prev) 
		pos = prev
	array.pop_back() # remove start field
	array.pop_back() # remove start field again
	return array

func get_path_to_2(pos):
	pass
