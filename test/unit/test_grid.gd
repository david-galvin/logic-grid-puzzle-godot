extends "res://addons/gut/test.gd"


class TestGrid:


	extends "res://addons/gut/test.gd"


	const GridCellState = preload("res://grid_cell_state.gd")

	var Grid = load("res://grid.gd")
	var BitMask = load("res://bit_mask.gd")
	var _grid: Grid = null
	var _bit_mask: BitMask = null
	var _category_size: int = 0
	

	func before_each():
		_category_size = 3
		_bit_mask = BitMask.new(_category_size)
		_grid = Grid.new(_category_size, _bit_mask)


	func test_set_cell_true():
		_grid.set_cell(0, 1, true)
		assert_eq("\n" + str(_grid), "\nXOX\n-X-\n-X-\n")


	func test_set_cell_false():
		_grid.set_cell(0, 1, false)
		assert_eq("\n" + str(_grid), "\n-X-\n---\n---\n")
		
		_grid.set_cell(0, 2, false)
		assert_eq("\n" + str(_grid), "\nOXX\nX--\nX--\n")
		
		assert_eq(_grid.read_cell(0, 0), GridCellState.TRUE)
	
	
	func test_is_solved():
		assert_eq(_grid.is_solved(), false)
		_grid.set_cell(0, 0, true)
		assert_eq(_grid.is_solved(), false)
		_grid.set_cell(1, 1, true)
		assert_eq(_grid.is_solved(), true)
	
	
	func test_is_solvable():
		assert_eq(_grid.is_solvable(), true)
		_grid.set_cell(0, 0, false)
		assert_eq(_grid.is_solvable(), true)
		_grid.set_cell(0, 1, false)
		assert_eq(_grid.is_solvable(), true)
		_grid.set_cell(0, 2, false)
		assert_eq(_grid.is_solvable(), false)
