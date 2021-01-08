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


	func test_implied_values_cats3_size5_basic():
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


	func test_implied_values_cats3_size4():
		# All asserts in this test are checking that we have correctly
		# discovered implied information
		_cat_count = 3
		_cat_size = 4
		_lp = LogicGridPuzzle.new(_cat_count, _cat_size)
		_lp.set_grid_cell(2, 2, 1, 3, false)
		_lp.set_grid_cell(2, 0, 0, 0, false)
		_lp.set_grid_cell(2, 3, 0, 0, false)
		_lp.set_grid_cell(2, 1, 1, 3, false)

		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(1, 3, 0, 0))

		_lp.set_grid_cell(2, 2, 1, 0, false)
		_lp.set_grid_cell(1, 2, 0, 0, false)
		_lp.set_grid_cell(1, 1, 0, 0, false)

		assert_eq(GridCellState.TRUE, _lp.read_grid_cell(1, 0, 0, 0))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(1, 0, 0, 1))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(1, 0, 0, 2))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(1, 0, 0, 3))

		assert_eq(GridCellState.TRUE, _lp.read_grid_cell(2, 1, 0, 0))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(2, 1, 0, 1))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(2, 1, 0, 2))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(2, 1, 0, 3))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(2, 2, 0, 0))

		assert_eq(GridCellState.TRUE, _lp.read_grid_cell(2, 1, 1, 0))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(2, 0, 1, 0))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(2, 1, 1, 1))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(2, 1, 1, 2))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(2, 3, 1, 0))


	func test_implied_values_cats4_size3():
		# All asserts in this test are checking that we have correctly
		# discovered implied information
		_cat_count = 4
		_cat_size = 3
		_lp = LogicGridPuzzle.new(_cat_count, _cat_size)
		
		_lp.set_grid_cell(3, 1, 1, 1, false)
		_lp.set_grid_cell(2, 0, 0, 2, false)
		assert_eq(GridCellState.UNKNOWN, _lp.read_grid_cell(2, 1, 0, 1))
		_lp.set_grid_cell(2, 0, 0, 1, false)

		assert_eq(GridCellState.TRUE, _lp.read_grid_cell(2, 0, 0, 0))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(2, 1, 0, 0))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(2, 2, 0, 0))

		_lp.set_grid_cell(1, 0, 0, 2, false)
		_lp.set_grid_cell(3, 1, 0, 1, false)
		_lp.set_grid_cell(1, 0, 0, 0, false)

		assert_eq(GridCellState.TRUE, _lp.read_grid_cell(1, 0, 0, 1))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(1, 1, 0, 1))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(1, 2, 0, 1))

		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(3, 0, 1, 2))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(3, 1, 1, 0))
		assert_eq(GridCellState.TRUE, _lp.read_grid_cell(3, 1, 1, 2))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(3, 2, 1, 2))

		_lp.set_grid_cell(2, 0, 1, 2, false)

		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(3, 1, 2, 0))

		assert_eq(GridCellState.TRUE, _lp.read_grid_cell(2, 0, 1, 1))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(2, 1, 1, 1))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(2, 2, 1, 1))

		# The last move (2,1) != (1,2) correctly updates implied information
		# in grids (3,2) and (2,1), but misses a change to (3,0)
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(3, 0, 0, 2))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(3, 1, 0, 0))
		assert_eq(GridCellState.TRUE, _lp.read_grid_cell(3, 1, 0, 2))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(3, 2, 0, 2))

		_lp.set_grid_cell(3, 0, 0, 1, false)

		assert_eq(GridCellState.TRUE, _lp.read_grid_cell(3, 0, 0, 0))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(3, 2, 0, 0))
		assert_eq(GridCellState.TRUE, _lp.read_grid_cell(3, 2, 0, 1))

		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(3, 0, 1, 0))
		assert_eq(GridCellState.TRUE, _lp.read_grid_cell(3, 0, 1, 1))
		assert_eq(GridCellState.TRUE, _lp.read_grid_cell(3, 2, 1, 0))
		assert_eq(GridCellState.FALSE, _lp.read_grid_cell(3, 2, 1, 1))


	func test_implied_values_cats4_size3_v2():
		# All asserts in this test are checking that we have correctly
		# discovered implied information
		_cat_count = 4
		_cat_size = 3
		_lp = LogicGridPuzzle.new(_cat_count, _cat_size)
		_lp.set_grid_cell(3, 2, 2, 2, false)
		_lp.set_grid_cell(3, 2, 0, 1, false)
		_lp.set_grid_cell(3, 2, 1, 1, false)
		_lp.set_grid_cell(1, 1, 0, 1, false)
		_lp.set_grid_cell(2, 2, 0, 1, false)
		assert_eq(GridCellState.TRUE, _lp.read_grid_cell(2, 2, 1, 1))



	func test_implied_solved():
		# All asserts in this test are checking that we have correctly
		# discovered implied information
		_cat_count = 4
		_cat_size = 3
		_lp = LogicGridPuzzle.new(_cat_count, _cat_size)
		_lp.set_grid_cell(2, 0, 0, 0, false)
		_lp.set_grid_cell(3, 2, 1, 1, false)
		_lp.set_grid_cell(2, 2, 1, 2, false)
		_lp.set_grid_cell(1, 1, 0, 1, false)
		_lp.set_grid_cell(3, 2, 2, 2, false)
		_lp.set_grid_cell(3, 0, 0, 1, false)
		_lp.set_grid_cell(3, 0, 2, 2, false)
		_lp.set_grid_cell(2, 1, 1, 2, false)
		_lp.set_grid_cell(3, 2, 2, 0, false)
		assert_eq(_lp.is_solved(), true)

		

	func test_random_puzzles():
		_cat_count = 5
		_cat_size = 4
		var _minutes: int = 0
		var _start_time = OS.get_ticks_msec()
		var _tries: int = 0
		while (OS.get_ticks_msec() - _start_time) < 1000: #_minutes * 60000:
			_tries += 1
			_lp = LogicGridPuzzle.new(_cat_count, _cat_size)
			
			var _cat1: int
			var _row: int
			var _cat2: int
			var _col: int
			var _coords: Array
			var _grid: Grid
			var _counter: int = 0
			var _moves: String = ""
			while (_lp.is_solvable() and not _lp.is_solved()) and _counter <= _cat_size * _cat_size * _cat_count:
				_grid = _lp.get_random_unsolved_grid()
				_coords = _grid.get_random_unsolved_cell_coordinates()
				var move: Move = Move.new(_grid.cat1, _coords[0], _grid.cat2, _coords[1], false)
				_moves += str(move)
				_lp.apply_move(move)
				_counter += 1
			if not _lp.is_solved():
				pass
				_lp.print_times()
				print(_lp)
				print(_moves)
				
				break
		_lp.print_times()
		print("Num tries: " + str(_tries))
		
