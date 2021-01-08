class_name PermutationTools
extends Reference


static func get_perm_rank_matrix(size_of_array: int) -> Array:
	var number_of_permutations: int = Math.factorial(size_of_array)
	var perm: Permutation = Permutation.new(size_of_array)
	var perm_rank_matrix: Array = []
	perm_rank_matrix.resize(number_of_permutations)
	for row_rank in range(number_of_permutations):
		perm_rank_matrix[row_rank] = []
		perm_rank_matrix[row_rank].resize(number_of_permutations)
		for col_rank in range(number_of_permutations):
			perm.set_rank(row_rank)
			perm.permute_by_rank(col_rank)
			perm_rank_matrix[row_rank][col_rank] = perm.rank
	return perm_rank_matrix


static func get_inverse_rank_array(size_of_array: int) -> Array:
	var number_of_permutations: int = Math.factorial(size_of_array)
	var perm: Permutation = Permutation.new(size_of_array)
	var inverse_rank_array: Array = []
	inverse_rank_array.resize(number_of_permutations)
	for i in range(number_of_permutations):
		perm.set_rank(i)
		perm.invert()
		inverse_rank_array[i] = perm.rank
	return inverse_rank_array
