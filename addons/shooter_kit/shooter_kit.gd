@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("ShooterKit3D", "Node3D",  preload("ShooterKit3D.gd"), preload("icons/ShooterKit3D.svg"))
		
func _exit_tree() -> void:
	remove_custom_type("ShooterKit3D")
