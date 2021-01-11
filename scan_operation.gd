class_name ScanOperation
extends Reference


# operation: [grid_to_set, needs_inversion? grid_to_permute_by, needs_inversion? implied_grid]
var row_grid_id: int
var invert_row_perm: bool
var col_grid_id: int
var invert_col_perm: bool
var implied_grid_id: int


func _init(my_row_grid_id: int, my_invert_row_perm: bool, my_col_grid_id: int, \
		my_invert_col_perm: bool, my_implied_grid_id: int):
	row_grid_id = my_row_grid_id
	invert_row_perm = my_invert_row_perm 
	col_grid_id = my_col_grid_id
	invert_col_perm = my_invert_col_perm
	implied_grid_id = my_implied_grid_id
