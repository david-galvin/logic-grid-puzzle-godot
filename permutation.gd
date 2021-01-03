extends Reference


class_name Permutation


var perm_int_arr: Array = []
var rank: int

var _copy_of_perm_int_arr: Array = []
var _inverse_of_perm_int_arr: Array = []


func _init(length: int) -> void:
	perm_int_arr.resize(length)
	_copy_of_perm_int_arr.resize(length)
	_inverse_of_perm_int_arr.resize(length)
	rank = -1


func invert_perm() -> void:
	for i in range(perm_int_arr.size()):
		_inverse_of_perm_int_arr[perm_int_arr[i]] = i
	for i in range(perm_int_arr.size()):
		perm_int_arr[i] = _inverse_of_perm_int_arr[i]
	_update_rank()


func permute_by_rank(my_rank: int) -> void:
	_set_rank_iterative(my_rank)
	_update_rank()


func set_rank(new_rank: int) -> void:
	if rank != new_rank:
		_set_perm_to_identity()
		_set_rank_iterative(new_rank)
		rank = new_rank


func _update_rank() -> void:
	_update_auxilliary_perms()
	rank = _update_rank_recursive(perm_int_arr.size())


func _to_string() -> String:
	var mystr: String = str(rank) + ":"
	for i in range(perm_int_arr.size()):
		mystr += " " + str(perm_int_arr[i])
	return mystr


func _set_rank_iterative(my_rank: int) -> void:
	for i in range(perm_int_arr.size(), 0, -1):
		_swap(perm_int_arr, i-1, my_rank % i)
		my_rank /= i


func _set_perm_to_identity() -> void:
	for i in range(perm_int_arr.size()):
		perm_int_arr[i] = i


func _update_auxilliary_perms() -> void:
	if perm_int_arr.size() != _inverse_of_perm_int_arr.size():
		_inverse_of_perm_int_arr = []
		_inverse_of_perm_int_arr.resize(perm_int_arr.size())
	if perm_int_arr.size() != _copy_of_perm_int_arr.size():
		_copy_of_perm_int_arr = []
		_copy_of_perm_int_arr.resize(perm_int_arr.size())
	for i in range(perm_int_arr.size()):
		_inverse_of_perm_int_arr[perm_int_arr[i]] = i
		_copy_of_perm_int_arr[i] = perm_int_arr[i]


func _update_rank_recursive(index: int) -> int:
	if index == 1:
		return 0
	var s: int = _copy_of_perm_int_arr[index - 1]
	_swap(_copy_of_perm_int_arr, index - 1, _inverse_of_perm_int_arr[index - 1])
	_swap(_inverse_of_perm_int_arr, s, index - 1)
	return s + index * _update_rank_recursive(index - 1)


func _swap(arr, index1: int, index2: int) -> void:
	if index1 == index2:
		return
	arr[index1] ^= arr[index2]
	arr[index2] ^= arr[index1]
	arr[index1] ^= arr[index2]
