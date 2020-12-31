extends Node

class_name Math

# Declare member variables here. Examples:
var factorials = [1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800, 
39916800, 479001600, 6227020800, 87178291200, 1307674368000, 20922789888000, 
355687428096000, 6402373705728000, 121645100408832000, 2432902008176640000]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func factorial(n):
	return factorials[n]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
