extends CharacterBody2D

# emmited when this player wins the round
signal round_win

@export var speed = 300.0
@export var jump_velocity = -400.0

@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var sword = $SwordHitbox

@onready var player_number = 1 if name == "Player1" else 2
@onready var move_left_action = "move_left_p%d" % player_number
@onready var move_right_action = "move_right_p%d" % player_number
@onready var move_up_action = "move_up_p%d" % player_number
@onready var move_down_action = "move_down_p%d" % player_number
@onready var action_attack_action = "action_attack_p%d" % player_number
@onready var action_guard_action = "action_guard_p%d" % player_number

var opponent : CharacterBody2D
var opponent_sword : CollisionPolygon2D
var opponent_hitbox : CollisionShape2D


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# var last_direction = -1

func _ready():
	var parent = get_parent()
	var children = parent.get_children()
	
	for child in children:
		if child.is_class("CharacterBody2D") and child.get_rid() != get_rid():
			opponent = child
			break
	
	opponent_sword = opponent.get_node("SwordHitbox")
	opponent_hitbox = opponent.get_node("PlayerHitbox")
	sword.set_deferred("disabled", true)

func _physics_process(delta):
	velocity.y += delta * gravity

	# TODO: correctly handle input
	# see https://docs.godotengine.org/en/stable/tutorials/inputs/controllers_gamepads_joysticks.html

	var direction = 0
	
	if Input.is_action_pressed(move_left_action):
		direction -= 1
		
	if Input.is_action_pressed(move_right_action):
		direction += 1
	
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# process actions
	if Input.is_action_pressed(action_attack_action):
		velocity.x = 0
		animation_player.play("attack_mid")

	# elif Input.is_action_pressed("action_guard"):
	# 	velocity.x = 0
		
	
	if speed > 0:
		move_and_slide()
	else:
		var collision = move_and_collide(delta * velocity)
		if collision != null and collision.get_local_shape() == sword:
			if collision.get_collider_shape() == opponent_sword:
				var normal = collision.get_normal()
				normal.y = 0
				velocity = velocity.bounce(normal.normalized())
				sword.set_deferred("disabled", true)
				opponent_sword.set_deferred("disabled", true)
				move_and_slide()
			elif collision.get_collider_shape() == opponent_hitbox: # hit the body
				round_win.emit()

