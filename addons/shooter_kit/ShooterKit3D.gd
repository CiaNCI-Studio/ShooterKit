extends Node3D
class_name ShooterKit3D

signal Hit(body : Node, point: Vector3)
signal Shoot

@export var Enabled : bool = true
@export_category("Inputs")
@export var FireInput : String = "action"
@export var AimInput : String = "aim"
@export_category("Fire")
@export var Automatic : bool = false
@export var FireCadence : float = 0.5
@export_category("Ray Trace")
@export var MaxDistance : float = 50
@export var ImpactEffectPath : String = "res://addons/shooter_kit/effects/ImpactEffect3D.tscn"
@export_category("Projectile")
@export var ProjectileSpawnMarker : Marker3D
@export var ProjectilePath : String = ""
@export var ProjectileSpeed : float = 25
@export var ProjectileCount : int = 1
@export var ProjectileSpreadAngle : float = 0
@export_category("Hud")
@export var HandleHud : bool = true
@export var CrossTexture : Texture2D
@export var AimTexture : Texture2D
@export_category("Camera")
@export var CameraReference : Camera3D
@export var FovLevelAim : float = 40

var hud : AimHud
var cadenceTimer : float = 0
var rayCast : RayCast3D
var fovLevelNormal : float = 2
var aiming : bool = false 
var defaultSpawnMarker : Marker3D

func _ready() -> void:
	if HandleHud:
		hud = load("res://addons/shooter_kit/AimHud.tscn").instantiate()
		if CrossTexture:
			hud.SetCross(CrossTexture)
		get_parent().add_child.call_deferred(hud)
	rayCast = RayCast3D.new()
	add_child.call_deferred(rayCast)
	rayCast.rotate_x(deg_to_rad(90))
	defaultSpawnMarker = Marker3D.new()
	rayCast.add_sibling.call_deferred(defaultSpawnMarker)
	defaultSpawnMarker.position.z = -1	
	if CameraReference:
		fovLevelNormal = CameraReference.fov
	
func _physics_process(delta: float) -> void:
	if not Enabled:
		return
		
	if cadenceTimer > 0:
		cadenceTimer = cadenceTimer - delta
	if rayCast.target_position.y != (-1 * MaxDistance):
		rayCast.target_position.y = (-1 * MaxDistance)
				
	if FireInput != "":
		if Automatic:
			if Input.is_action_pressed(FireInput):
				Fire()
		else:
			if Input.is_action_just_pressed(FireInput):
				Fire()
	if AimInput != "":
		if Input.is_action_pressed(AimInput):
			Aim(true)
		else:
			Aim(false)
	
func SetHudVisibility(visible :bool):
	hud.visible	= visible	
		
func Aim(active : bool):
	if not Enabled:
		return
	if not active:
		if CrossTexture:
			hud.SetCross(CrossTexture)
		if CameraReference:
			CameraReference.fov = lerpf(CameraReference.fov, fovLevelNormal, 0.1)
		aiming = true
	else:
		if AimTexture:
			hud.SetCross(AimTexture)
		if CameraReference:
			CameraReference.fov = lerpf(CameraReference.fov, FovLevelAim, 0.1)			
		aiming = false

func Fire():
	if not Enabled:
		return
	if cadenceTimer > 0:
		return
	cadenceTimer = FireCadence
	if ProjectilePath == "":
		__traceFire()
	else:
		__ProjectileFire()
	Shoot.emit()

func __ProjectileFire():
	var projectile = load(ProjectilePath).instantiate()
	get_tree().root.add_child(projectile)
	if projectile is RigidBody3D:
		if ProjectileSpawnMarker:
			projectile.transform = ProjectileSpawnMarker.global_transform	
			(projectile as RigidBody3D).linear_velocity = ProjectileSpawnMarker.global_transform.basis.z * -1 * ProjectileSpeed
		else:
			projectile.transform = defaultSpawnMarker.global_transform	
			(projectile as RigidBody3D).linear_velocity = defaultSpawnMarker.global_transform.basis.z * -1 * ProjectileSpeed

func __traceFire():	
	if rayCast.is_colliding():
		var colider = rayCast.get_collider()
		var colisionPosition = rayCast.get_collision_point()
		if colider:		
			__impactEffect(colisionPosition)
			Hit.emit(colider, colisionPosition)

func __impactEffect(position : Vector3):
	if ImpactEffectPath == "":
		return
	var impact = load(ImpactEffectPath).instantiate() as Node3D
	get_tree().root.add_child.call_deferred(impact)
	impact.global_position = position
