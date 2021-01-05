class_name GridSorter
extends Reference


static func sort_by_cardinality(grid1: Grid, grid2: Grid):
	if grid1.solutions_bitset.cardinality() < grid2.solutions_bitset.cardinality():
		return true
	return false
