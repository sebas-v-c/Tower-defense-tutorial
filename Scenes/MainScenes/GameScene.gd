extends Node2D


var map_node

var build_mode = false
var build_valid = false
var build_location
var build_type
var build_tile

func _ready():
	# Turn this into variable based on selected map
	map_node = get_node("Map 1") 
	
	# We get all the node the build buttons group and connected to a function
	for node in get_tree().get_nodes_in_group("build_buttons"):
		node.connect("pressed", self, "initiate_build_mode", [node.get_name()])
	pass


func _process(delta):
	if build_mode:
		update_tower_preview()


func _unhandled_input(event):
	if event.is_action_released("ui_cancel") and build_mode:
		cancel_build_mode()
	if event.is_action_released("ui_accept") and build_mode:
		verify_and_build()
		cancel_build_mode()
	


func initiate_build_mode(tower_type):
	if build_mode:
		cancel_build_mode()
	
	build_type = tower_type + "T1"
	build_mode = true
	get_node("UI").set_tower_preview(build_type, get_global_mouse_position())


func update_tower_preview():
	var mouse_position = get_global_mouse_position()
	# IMPORTANT: With this lines of code 
	# The first returns the coordinates of a tile where the mouse posittion is
	# The second returns the top left corner position of the tile
	var current_tile = map_node.get_node("TowerExclusion").world_to_map(mouse_position)
	var tile_position = map_node.get_node("TowerExclusion").map_to_world(current_tile)
	
	# Here we check if the tile where we currently are (returned by world_to_map
	# and checked with get_cellv) is empty == -1
	if map_node.get_node("TowerExclusion").get_cellv(current_tile) == -1:
		get_node("UI").update_tower_preview(tile_position, "ad54ff3c")
		build_valid = true
		build_location = tile_position
		build_tile = current_tile
		
	else:
		get_node("UI").update_tower_preview(tile_position, "adff4545")
		build_valid = false


func cancel_build_mode():
	build_mode = false
	build_valid = false
	# We use free instead of queue_free because free doesn't query the node to 
	# the next frame, with free the node gets inmediatly deleted.
	# We are deleting an user interface that doesnt get affected by the physisc
	# So everything is OK with free
	get_node("UI/TowerPreview").free()


func verify_and_build():
	if build_valid:
		## Test to verify player has enough cash
		# If nothing happens verify that control node is not filering the mouse
		var new_tower = load("res://Scenes/Turrets/" + build_type + ".tscn").instance()
		new_tower.position = build_location
		map_node.get_node("Turrets").add_child(new_tower, true)
		map_node.get_node("TowerExclusion").set_cellv(build_tile, 5)
