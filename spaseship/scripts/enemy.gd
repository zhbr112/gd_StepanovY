extends Node2D

signal colided

var acceleration: Vector2 = Vector2(0, 0)
var orbit_radius: float = 180.0
var orbit_speed: float = 2.0
var orbit_angle: float = NAN
var velocity: Vector2 = Vector2(0, 0)
var max_force: float = 10
var max_speed: float = 3
var max_distance: int = 100
var min_distance: int = 100
@onready var window = self.get_parent().get_window()
@onready var size = $EnemyBoid.texture.get_size()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#apply_force(Vector2(100, 50))
	var vel_x = randi_range(-100, 100)
	var vel_y = randi_range(-100, 100)
	velocity.x = vel_x
	velocity.y = vel_y
	
	var x = randi_range(0 + size.x, window.size.x - size.x)
	var y = randi_range(0 + size.y, window.size.y  - size.y)
	self.position.x = x 
	self.position.y = y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity += acceleration * delta
	velocity = velocity.limit_length(max_speed)
	self.position += velocity
	acceleration *= 0
	self.rotation = velocity.angle()
		
	if self.position.x > window.size.x:
		self.position.x = 0
	elif self.position.x < 0:
		self.position.x = window.size.x
		
	if self.position.y > window.size.y:
		self.position.y = 0
	elif self.position.y < 0:
		self.position.y = window.size.y

func apply_force(force: Vector2):
	acceleration = force

func seek(target: Vector2):
	var direction = target - self.position
	var desired_velocity = direction.normalized() * max_speed
	#if direction.length() > max_distance:
		#return
	#if direction.length() <= min_distance:
		#velocity *= 0
		#return
	#var m = remap(direction.length(), \
					#min_distance, max_distance, 0, 1)
	var m = 1
	var steering = (desired_velocity - velocity) * m
	steering = steering.limit_length(max_force)
	apply_force(steering)
	
func flee(target: Vector2):
	var direction =  self.position - target
	#if direction.length() > max_distance / 2:
		#return
	var desired_velocity = direction.normalized() * max_speed
	var steering = (desired_velocity - velocity) 
	steering = steering.limit_length(max_force)
	apply_force(steering)

func pursue(target: Vector2, target_velocity: Vector2):
	var direction = target - self.position
	var speed: float = velocity.length()
	if speed == 0:
		speed = max_speed
	var ahead_time: float = direction.length() / speed
	var predict = target + target_velocity * ahead_time
	seek(predict)

func orbit(target: Vector2, delta: float) -> void:
	if is_nan(orbit_angle):
		var offset: Vector2 = self.position - target
		orbit_angle = offset.angle() if offset.length() > 1.0 else 0.0
	orbit_angle += orbit_speed * delta
	self.position = target + Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
	self.rotation = orbit_angle + PI / 2

func _on_enemy_area_area_entered(area: Area2D) -> void:
	if not area.is_in_group("player_hurtbox"):
		return
	colided.emit()

func separate(group: Node2D):
	var steering: Vector2 = Vector2.ZERO
	var count: int = 0
	for child in group.get_children():
		if self == child:
			continue
		var direction: Vector2 = child.position - self.position
		var distance: float = direction.length()
		if distance >= 0 and distance < max_distance:
			var away: Vector2 = -direction.normalized()
			away *= (1 / distance)
			steering += away
			count += 1
	if count > 0:
		steering /= count
		steering = steering.normalized() * max_speed
		steering -= velocity
		steering = steering.limit_length(max_force)
		apply_force(steering)

func cohesion(group: Node2D):
	var com: Vector2 = Vector2.ZERO
	var count: int = 0
	for child in group.get_children():
		if self == child:
			continue
		var direction: Vector2 = child.position - self.position
		var distance: float = direction.length()
		if distance >= 0 and distance < max_distance:
			com += child.position
			count += 1
	if count > 0:
		com /= count 
		seek(com)

func alignment(group: Node2D):
	var mean_velocity: Vector2 = Vector2.ZERO
	var count: int = 0
	for child in group.get_children():
		if self == child:
			continue
		var direction: Vector2 = child.position - self.position 
		var distance: float = direction.length()
		if distance >= 0  and distance < max_distance:
			mean_velocity += child.velocity
			count += 1
	if count > 0: 
		mean_velocity /= count 
		mean_velocity = mean_velocity.normalized() * max_speed
		mean_velocity -= velocity
		var steering = mean_velocity - velocity 
		apply_force(steering.limit_length(max_force))
