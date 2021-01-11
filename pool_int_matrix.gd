class_name PoolIntMatrix
extends Reference


var matrix: PoolIntArray = PoolIntArray([0, 0])


func _init(rows: int, cols: int, vals: Array = []) -> void:
	if not [0, rows * cols].has(vals.size()):
		push_error("Size of passed values doesn't match size of matrix")
	matrix.resize(2 + rows * cols)
	matrix[0] = rows
	matrix[1] = cols
	

func get_index(row: int, col: int) -> int:
	return 2 + row * matrix[1] + col


func read_cell(row: int, col: int) -> int:
	return matrix[get_index(row, col)]


func write_cell(row: int, col: int, val: int) -> void:
	matrix[get_index(row, col)] = val
