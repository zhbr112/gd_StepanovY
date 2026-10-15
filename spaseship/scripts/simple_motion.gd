extends Node2D

signal colided 

var velocity: Vector2 = Vector2(0, 0)
var angular_speed: float = 0.1
@onready var window = self.get_parent().get_window()
@onready var size = self.get_node("AsteroidSprite").texture.get_size()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = Vector2(randi_range(-100, 100), \
						randi_range(-100,100))
	angular_speed = randf_range(0.1, 0.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta
	rotation += angular_speed * delta
	
	if self.position.x > window.size.x - size.x / 2:
		velocity.x = -velocity.x
	elif self.position.y > window.size.y - size.y / 2:
		velocity.y = -velocity.y
	elif self.position.x < size.x / 2:
		velocity.x = -velocity.x
	elif self.position.y < size.y / 2:
		velocity.y = -velocity.y


func _on_asteriod_area_area_entered(area: Area2D) -> void:
	if not area.is_in_group("player_hurtbox"):
		return
	colided.emit()
