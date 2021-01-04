extends "res://addons/gut/test.gd"


class TestLogicGridPuzzle:


	extends "res://addons/gut/test.gd"


	const GridCellState = preload("res://grid_cell_state.gd")
	
	var LogicGridPuzzle = load("res://logic_grid_puzzle.gd")
	var _cat_count: int = 0
	var _cat_size: int = 0
	var _lp: LogicGridPuzzle = null


	func test_string():
		_cat_count = 3
		_cat_size = 5
		_lp = LogicGridPuzzle.new(_cat_count, _cat_size)
		var cat1 := 2
		for elt1 in range(0,2):
			for cat2 in range(0,2):
				for elt2 in range(0,3):
					_lp.set_grid_cell(cat1, elt1, cat2, elt2, false)

		var lp_str: String = 	"------------\n" + \
								"|XXX??|XXX??\n" + \
								"|XXX??|XXX??\n" + \
								"|???XX|???XX\n" + \
								"|???XX|???XX\n" + \
								"|???XX|???XX\n" + \
								"------\n" + \
								"|???XX\n" + \
								"|???XX\n" + \
								"|???XX\n" + \
								"|XXX??\n" + \
								"|XXX??\n"
		assert_eq(str(_lp), lp_str)


	func test_implied_values():
		_cat_count = 3
		_cat_size = 5
		_lp = LogicGridPuzzle.new(_cat_count, _cat_size)
		var cat1 := 2
		for elt1 in range(0,2):
			for cat2 in range(0,2):
				for elt2 in range(0,3):
					_lp.set_grid_cell(cat1, elt1, cat2, elt2, false)
		# Implied grid should have cat1 = 1, cat2 = 0, and false values
		# for 12 cells.
		
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(1, 0, 0, 3))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(1, 0, 0, 4))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(1, 1, 0, 3))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(1, 1, 0, 4))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(1, 2, 0, 3))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(1, 2, 0, 4))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(1, 3, 0, 0))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(1, 3, 0, 1))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(1, 3, 0, 2))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(1, 4, 0, 0))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(1, 4, 0, 1))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(1, 4, 0, 2))
		


#	func test_random_puzzles():
#		var rng := RandomNumberGenerator.new()
#		rng.randomize()
#
#		var num_puzzles: int = 10
#		var cat_count_range: Array = range(3,7)
#		var cat_size_range: Array = range(3,6)


# TODO: Write some real lp tests:
# test set one: moves that should imply something about the puzzle.

# test set two: create a programmatic tester looking for failures to discover
# all implied information. Randomly generate puzzles with category count &
# size restrictions, and enter random legal moves. If the puzzle becomes
# unsolvable, then we missed some implied information. Record moves for analysis.
# bonus version: on finding an invalid puzzle, rerun the moves with elimination
# to find the minimum move set with the error.
