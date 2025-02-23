extends GPUParticles3D

var lifeTime : float = 1

func _ready() -> void:
	emitting = true

func _process(delta: float) -> void:
	if lifeTime <= 0:
		queue_free()
	lifeTime = lifeTime - delta
