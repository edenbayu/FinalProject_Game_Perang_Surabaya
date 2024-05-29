extends Resource
class_name  UnitData

@export_category("Unit Stats")
@export var unit_name: String
@export var unit_health: int
@export var move_speed: int
@export var move_range: int
@export var attack_range: int

@export_category("Unit UI Elements")
@export var skin: Texture2D
@export var icon: Texture2D
@export var inactive_icon: Texture2D
@export var unit_role: String
