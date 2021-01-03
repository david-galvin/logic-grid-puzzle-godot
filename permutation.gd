extends Reference


class_name Permutation


var perm_ints: Array = []
var rank: int

var _copy_of_perm_ints: Array = []
var _inverse_of_perm_ints: Array = []


func _init(length: int) -> void:
	perm_ints.resize(length)
	_copy_of_perm_ints.resize(length)
	_inverse_of_perm_ints.resize(length)
	rank = -1


func invert_perm() -> void:
	for i in range(perm_ints.size()):
		_inverse_of_perm_ints[perm_ints[i]] = i
	for i in range(perm_ints.size()):
		perm_ints[i] = _inverse_of_perm_ints[i]
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
	rank = _update_rank_recursive(perm_ints.size())


func _to_string() -> String:
	var mystr: String = str(rank) + ":"
	for i in range(perm_ints.size()):
		mystr += " " + str(perm_ints[i])
	return mystr


func _set_rank_iterative(my_rank: int) -> void:
	for i in range(perm_ints.size(), 0, -1):
		_swap(perm_ints, i-1, my_rank % i)
		my_rank /= i


func _set_perm_to_identity() -> void:
	for i in range(perm_ints.size()):
		perm_ints[i] = i


func _update_auxilliary_perms() -> void:
	if perm_ints.size() != _inverse_of_perm_ints.size():
		_inverse_of_perm_ints = []
		_inverse_of_perm_ints.resize(perm_ints.size())
	if perm_ints.size() != _copy_of_perm_ints.size():
		_copy_of_perm_ints = []
		_copy_of_perm_ints.resize(perm_ints.size())
	for i in range(perm_ints.size()):
		_inverse_of_perm_ints[perm_ints[i]] = i
		_copy_of_perm_ints[i] = perm_ints[i]


func _update_rank_recursive(index: int) -> int:
	if index == 1:
		return 0
	var s: int = _copy_of_perm_ints[index - 1]
	_swap(_copy_of_perm_ints, index - 1, _inverse_of_perm_ints[index - 1])
	_swap(_inverse_of_perm_ints, s, index - 1)
	return s + index * _update_rank_recursive(index - 1)


func _swap(arr, index1: int, index2: int) -> void:
	if index1 == index2:
		return
	arr[index1] ^= arr[index2]
	arr[index2] ^= arr[index1]
	arr[index1] ^= arr[index2]
