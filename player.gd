extends CharacterBody2D
@onready var player2d = $Sprite2D
@onready var animator=$AnimatedSprite2D
@onready var anim_player=$AnimationPlayer
enum state {IDLE, RIGHT_WALK, JUMP}
var animation_state=state.IDLE



const SPEED = 100
const jump_power = -700
const SPRINT_VELOCITY = 100
#const JUMP_VELOCITY = 1
const acc = 50 
const friction = 70


const gravity = 74

const wall_jump_pushback = 100 

const wall_slide_gravity = 100
var is_wall_sliding = false


func animation_update(direction):
	if direction<0:
		animator.flip_h=true
	elif direction>0:
		animator.flip_h=false
	match animation_state:
		state.IDLE:
			anim_player.play("Idle")
		state.RIGHT_WALK:
			anim_player.play("right walk")
		state.JUMP:
			anim_player.play("Jump")
			
func update_state():
	if animation_state==state.IDLE:
		return
	if is_on_floor():
		if velocity==Vector2.ZERO:
			animation_state=state.IDLE
		elif velocity.x!=0:
			animation_state=state.RIGHT_WALK
	else:
		if velocity.y<0:
			animation_state=state.JUMP
			 
			
			
			
func _physics_process(delta):
	
	if is_on_floor():
		if velocity==Vector2.ZERO:
			animation_state=state.IDLE
		elif velocity.x!=0:
			animation_state=state.RIGHT_WALK
	else:
		if velocity.y<0:
			animation_state=state.JUMP
	
	#velocity.y += gravity * delta
	
	
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
		
		
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED 
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	var input_dir: Vector2 = input()


	
	if input_dir != Vector2.ZERO: 
		accelerate(input_dir) 
	else: 
		add_friction()
		
	update_state()
	animation_update(direction)
	jump()
	wall_slide(delta)
	player_movement()

func player_movement():
	move_and_slide()

func accelerate(direction):
	velocity = velocity.move_toward(SPEED * direction, acc)
func add_friction():
	velocity = velocity.move_toward(Vector2.ZERO, friction)

func input() -> Vector2:
	var input_dir = Vector2.ZERO
	
	input_dir.x = Input.get_axis("left", "right")
	input_dir = input_dir.normalized()
	return input_dir

func jump():
	velocity.y += gravity
	if Input.is_action_just_pressed("jump"):
		
		
		
		if is_on_floor():
			animation_state=state.JUMP
			
			velocity.y = jump_power
		if is_on_wall() and Input.is_action_pressed("right"):
			velocity.y = jump_power 
			velocity.x = -wall_jump_pushback
		if is_on_wall() and Input.is_action_pressed("left"):
			velocity.y = jump_power 
			velocity.x = wall_jump_pushback
		elif is_on_floor():
			animation_state=state.IDLE
			
	
func wall_slide(delta):
	if is_on_wall() and !is_on_floor():
		if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			is_wall_sliding = true


		else:
			is_wall_sliding = false 
	else:
		is_wall_sliding = false 
	
	if is_wall_sliding:
		velocity.y += (wall_slide_gravity * delta)
		velocity.y = min(velocity.y, wall_slide_gravity)
			  
		#check if sprinting
		if Input.is_action_pressed("run"):

			#we are sprinting
			velocity.y *= SPRINT_VELOCITY
	
	
func die():
	queue_free()


func _unhandled_input(event):
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()


func _on_button_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")


func _on_collision_shape_2d_child_entered_tree(node: Node) -> void:
	get_tree().change_scene_to_file("res://win.tscn")
