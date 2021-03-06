extends Node2D

var enemy_array = []
var built = false
var enemy
var type
var ready = true


func _ready():
	if built:
		self.get_node("Range/CollisionShape2D").get_shape().radius = 0.5 * GameData.tower_data[type]["Range"]


func _physics_process(delta):
	if enemy_array.size() != 0 and built:
		select_enemy()
		turn()
		if ready:
			fire()
	else:
		enemy = null


func turn():
	get_node("Turret").look_at(enemy.position)


func select_enemy():
	var enemy_progress_array = []
	for i in enemy_array:
		enemy_progress_array.append(i.offset)
	var max_offset = enemy_progress_array.max()
	var enemy_index = enemy_progress_array.find(max_offset)
	enemy = enemy_array[enemy_index]


func fire():
	ready = false
	enemy.on_hit(GameData.tower_data[type]["Damage"])
	yield(get_tree().create_timer(GameData.tower_data[type]["ROF"]), "timeout")
	ready = true



func _on_Range_body_entered(body):
	# We add the parent, not the body. Because the kinematic body of the tank is
	# detected, and we need the true tank. so we need to detec te parent of the node 
	enemy_array.append(body.get_parent())
	print(enemy_array)


func _on_Range_body_exited(body):
	enemy_array.erase(body.get_parent())
