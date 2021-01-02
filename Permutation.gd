extends Reference

class_name Permutation

# Declare member variables here. Examples:
var permutation_int_arr = []
var _copy_of_permutation_int_arr = []
var _inverse_ofPermutation_int_arr = []
var rank: int

func _init(length: int):
	permutation_int_arr.resize(length)
	_copy_of_permutation_int_arr.resize(length)
	_inverse_ofPermutation_int_arr.resize(length)
	rank = -1

func _to_string() -> String:
	var mystr: String = str(rank) + ":"
	for i in range(permutation_int_arr.size()):
		mystr += " " + str(permutation_int_arr[i])
	return mystr

func invert_permutation():
	for i in range(permutation_int_arr.size()):
		_inverse_ofPermutation_int_arr[permutation_int_arr[i]] = i
	for i in range(permutation_int_arr.size()):
		permutation_int_arr[i] = _inverse_ofPermutation_int_arr[i]
	update_rank()

func permute_by_rank(my_rank: int):
	_set_rank_iterative(my_rank)
	update_rank()

func set_rank(new_rank: int):
	if rank != new_rank:
		_set_permutation_to_identity()
		_set_rank_iterative(new_rank)
		rank = new_rank

func _set_rank_iterative(my_rank: int):
	for i in range(permutation_int_arr.size(), 0, -1):
		_swap(permutation_int_arr, i-1, my_rank % i)
		my_rank /= i

func _set_permutation_to_identity():
	for i in range(permutation_int_arr.size()):
		permutation_int_arr[i] = i

func update_rank():
	_update_auxilliary_permutations()
	rank = _update_rank_recursive(permutation_int_arr.size())

func _update_auxilliary_permutations():
	if (permutation_int_arr.size() != _inverse_ofPermutation_int_arr.size()):
		_inverse_ofPermutation_int_arr = []
		_inverse_ofPermutation_int_arr.resize(permutation_int_arr.size())
	if (permutation_int_arr.size() != _copy_of_permutation_int_arr.size()):
		_copy_of_permutation_int_arr = []
		_copy_of_permutation_int_arr.resize(permutation_int_arr.size())
	for i in range(permutation_int_arr.size()):
		_inverse_ofPermutation_int_arr[permutation_int_arr[i]] = i
		_copy_of_permutation_int_arr[i] = permutation_int_arr[i]

func _update_rank_recursive(index: int) -> int:
	if index == 1:
		return 0
	var s: int = _copy_of_permutation_int_arr[index - 1]
	_swap(_copy_of_permutation_int_arr, index - 1, _inverse_ofPermutation_int_arr[index - 1])
	_swap(_inverse_ofPermutation_int_arr, s, index - 1)
	return s + index * _update_rank_recursive(index - 1)

func _swap(arr, index1: int, index2: int):
	if index1 == index2:
		return
	arr[index1] ^= arr[index2]
	arr[index2] ^= arr[index1]
	arr[index1] ^= arr[index2]
