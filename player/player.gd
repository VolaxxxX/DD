class_name Player extends Node3D
# Local player. Isometric move + proximity-trigger events.

const MOVE_SPEED := 6.0
const INTERACT_RADIUS := 2.5

var id: int = 1
var stat: int = 10
var view: Sprite3D
var resolver: EventResolver

func setup(_id: int, _resolver: EventResolver) -> void:
	id = _id
	resolver = _resolver
	_build_view()

func _build_view() -> void:
	view = Sprite3D.new()
	var img := Image.create(18, 28, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.9, 0.95, 1.0, 1.0))
	view.texture = ImageTexture.create_from_image(img)
	view.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	view.pixel_size = 0.025
	view.modulate = Color(0.7, 0.9, 1.0)
	view.position = Vector3(0, 0.6, 0)
	add_child(view)

func _physics_process(delta: float) -> void:
	var input := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	if input.length() > 1.0: input = input.normalized()
	position.x += input.x * MOVE_SPEED * delta
	position.z += input.y * MOVE_SPEED * delta
	Bus.player_moved.emit(id, position)
	if Input.is_action_just_pressed("action_primary"):
		_interact()

func _interact() -> void:
	var parent := get_parent()
	if not parent or not parent.has_method("get_active_ecosystem"): return
	var eco: Ecosystem = parent.get_active_ecosystem()
	if not eco: return
	var target: Creature = eco.nearest_to(position, INTERACT_RADIUS)
	if not target: return
	var kind := EventResolver.Kind.COMBAT
	if target.archetype.intelligence > 70 and target.fsm.state != AIFSM.S.HUNT:
		kind = EventResolver.Kind.DIALOGUE
	var difficulty := 10 + target.archetype.aggression / 10
	var r := resolver.resolve(kind, stat, difficulty, 0, 0, [target.id])
	if r.outcome >= FateEngine.Outcome.SUCCESS and kind == EventResolver.Kind.COMBAT:
		target.kill()
	elif r.outcome == FateEngine.Outcome.CRIT_FAIL:
		stat = maxi(1, stat - 1)
