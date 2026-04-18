class_name EntityView extends Sprite3D
# Attached to a Creature to render its billboarded sprite.
# Currently creatures build their own Sprite3D; this is reserved for richer visuals.

var creature: Creature

func bind(c: Creature) -> void:
	creature = c
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	pixel_size = 0.02

func _process(_d: float) -> void:
	if creature and creature.alive:
		global_position = creature.global_position + Vector3.UP * 0.5
