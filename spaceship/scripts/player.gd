extends Node2D

var speed: float = 0
var max_speed: float = 420
var velocity: Vector2 = Vector2(0,0)
var survival_time: float = 0.0
@onready var speed_label: Label = self.get_node("Speedometer")
@onready var survival_label: Label = self.get_node("SurvivalTimer")
@onready var shield: Sprite2D = self.get_node("ShipSprite/ShieldSprite")
@onready var window = self.get_parent().get_window()
var shield_restoration: float = 1
const SHIP_MARGIN: float = 24.0
const DAMAGE_COOLDOWN: float = 0.35
var _damage_cooldown_left: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		speed += 100 * delta
		if speed > max_speed:
			speed = max_speed
	if Input.is_action_pressed("ui_down"):
		speed -= 100 * delta
		if speed < 0:
			speed = 0
	if Input.is_action_pressed("ui_left"):
		self.rotation -= 5.0 * delta
	if Input.is_action_pressed("ui_right"):
		self.rotation += 5.0 * delta
	
	var forward := Vector2(-sin(rotation), cos(rotation))
	velocity = forward * speed
	position += velocity * delta
	_bounce_off_walls()
	speed = velocity.length()
	if speed > 0.001:
		rotation = velocity.angle() - PI / 2
	speed_label.text = "%d" % speed

	survival_time += delta
	survival_label.text = "%.1f" % survival_time

	if _damage_cooldown_left > 0.0:
		_damage_cooldown_left -= delta

	if shield_restoration > 0:
		shield_restoration -= delta
	if shield_restoration <= 0:
		shield.visible = true
	
func _bounce_off_walls() -> void:
	var max_x: float = window.size.x - SHIP_MARGIN
	var max_y: float = window.size.y - SHIP_MARGIN
	if position.x > max_x:
		position.x = max_x
		if velocity.x > 0.0:
			velocity.x = -velocity.x
	if position.x < SHIP_MARGIN:
		position.x = SHIP_MARGIN
		if velocity.x < 0.0:
			velocity.x = -velocity.x
	if position.y > max_y:
		position.y = max_y
		if velocity.y > 0.0:
			velocity.y = -velocity.y
	if position.y < SHIP_MARGIN:
		position.y = SHIP_MARGIN
		if velocity.y < 0.0:
			velocity.y = -velocity.y

func damaged():
	if _damage_cooldown_left > 0.0:
		return
	_damage_cooldown_left = DAMAGE_COOLDOWN
	if shield.visible:
		shield.visible = false
		shield_restoration = 1.0
		return
	survival_time = 0.0
	shield.visible = false
	shield_restoration = 1.0
