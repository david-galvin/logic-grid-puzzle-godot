extends "res://addons/gut/test.gd"


class TestLogicGridPuzzle:


	extends "res://addons/gut/test.gd"


	var LogicGridPuzzle = load("res://logic_grid_puzzle.gd")
	var _category_count: int = 0
	var _category_size: int = 0
	var _lp = null
	var _time_before = null
	var _times_arr = []


	func before_each():
		_category_count = 3
		_category_size = 5
		_lp = LogicGridPuzzle.new(_category_count, _category_size)


	func test_eliminate_possible_solutions():
		_lp.eliminate_possible_solutions(2, 0, 0, 0, true)
		_lp.eliminate_possible_solutions(2, 0, 0, 1, true)
		_lp.eliminate_possible_solutions(2, 0, 0, 2, true)
		_lp.eliminate_possible_solutions(2, 0, 1, 0, true)
		#_lp.eliminate_possible_solutions(2, 0, 1, 1, true)
		#_lp.eliminate_possible_solutions(2, 0, 1, 2, true)
		_lp.eliminate_possible_solutions(2, 1, 0, 0, true)
		_lp.eliminate_possible_solutions(2, 1, 0, 1, true)
		_lp.eliminate_possible_solutions(2, 1, 0, 2, true)
		_lp.eliminate_possible_solutions(2, 1, 1, 0, true)
		#_lp.eliminate_possible_solutions(2, 1, 1, 1, true)
		#_lp.eliminate_possible_solutions(2, 1, 1, 2, true)
#		_lp.eliminate_possible_solutions(1, 3, 0, 0, true)

		print(_lp)
# TODO: Write some real lp tests:
# test set one: moves that should imply something about the puzzle.

# test set two: create a programmatic tester looking for failures to discover
# all implied information. Randomly generate puzzles with category count &
# size restrictions, and enter random legal moves. If the puzzle becomes
# unsolvable, then we missed some implied information. Record moves for analysis.
# bonus version: on finding an invalid puzzle, rerun the moves with elimination
# to find the minimum move set with the error.
