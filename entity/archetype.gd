class_name Archetype extends Resource
# Procedurally-generated creature template.

enum Family { HUMANOID, BEAST, UNDEAD, CONSTRUCT, ELEMENTAL, ABERRATION, FEY, DRACONIC }
enum Tier   { COMMON, UNCOMMON, RARE, ELITE, APEX, MYTHIC }
enum Role   { PREDATOR, PREY, TERRITORIAL, SCAVENGER, MODIFIER, APEX }

@export var id: StringName = &""
@export var family: Family = Family.BEAST
@export var tier: Tier = Tier.COMMON
@export var role: Role = Role.PREDATOR
@export var intelligence: int = 50
@export var aggression: int = 50
@export var ecology_weight: int = 50
@export var influence_radius: float = 6.0
@export var mutation_pool: Array[StringName] = []
