extends Node2D

@onready var player = self.get_node("Player")
@onready var asteroid = self.get_node("Obstacle")
@onready var enemy = $Enemy
@onready var enemies = $Enemies
@onready var enemy_scene = preload("res://scenes/enemy.tscn")
var count: int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	asteroid.colided.connect(player.damaged)
	enemy.colided.connect(player.damaged)
	for i in count:
		var enemy_instance = enemy_scene.instantiate()
		enemy_instance.scale = Vector2(0.5, 0.5)
		enemy_instance.colided.connect(player.damaged)
		enemies.add_child(enemy_instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	enemy.orbit(player.position, delta)
	for child in enemies.get_children():
		child.alignment(enemies)
