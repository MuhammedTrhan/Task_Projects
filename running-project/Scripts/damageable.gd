extends Area2D

# This area acts as a middleman. 
# It receives the hit, and tells the parent/owner to handle the math.
func take_damage(amount: float) -> void:
	if owner.has_method("take_damage"):
		owner.take_damage(amount)