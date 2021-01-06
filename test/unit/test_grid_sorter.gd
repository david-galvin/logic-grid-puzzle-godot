extends "res://addons/gut/test.gd"


class TestGridSorter:


	extends "res://addons/gut/test.gd"
	
	
	var Grid = load("res://grid.gd")
	var GridSorter = load("res://grid_sorter.gd")
	
	func test_sorter():
		var fully_unknown_grid: Grid = Grid.new(5, BitMask.new(5))
		
		var fully_known_grid: Grid = Grid.new(5, BitMask.new(5))
		fully_known_grid.set_cell(0,0,true)
		fully_known_grid.set_cell(1,1,true)
		fully_known_grid.set_cell(2,2,true)
		fully_known_grid.set_cell(3,3,true)
		
		var low_information_grid: Grid = Grid.new(5, BitMask.new(5))
		low_information_grid.set_cell(0,0,false)
		
		var high_information_grid: Grid = Grid.new(5, BitMask.new(5))
		high_information_grid.set_cell(0,0,false)
		high_information_grid.set_cell(0,1,false)
		
		var grids: Array = []
		grids.append(high_information_grid)
		grids.append(fully_known_grid)
		grids.append(fully_unknown_grid)
		grids.append(low_information_grid)
		grids.sort_custom(GridSorter, "sort_by_cardinality")
		
		assert_true(grids[0].solutions_bitset.cardinality() <= grids[1].solutions_bitset.cardinality())
