class_name BitSet
extends Reference


const _BITS_PER_WORD: int = 63
const _ALL_SET_BITS: int = (1 << _BITS_PER_WORD) - 1

var _num_words: int = 0
var _num_bits: int = 0
var _words: Array = []
var _have_bits_changed: bool = true
var _cardinality: int = 0
var _print_str: String = ""
var _set_bits: Dictionary = {}


func _init(my_num_bits: int) -> void:
	_num_bits = my_num_bits
	_num_words = (_num_bits - 1) / _BITS_PER_WORD + 1
	_words.resize(_num_words)
	for i in range(_num_words):
		_words[i] = 0


func validate_index(index: int) -> void:
	if index >= _num_bits:
		push_error("Index exceeds size of BitSet")
	if index < 0:
		push_error("Index can't be negative")


func set_at_index(index: int, val: bool) -> void:
	validate_index(index)
	_have_bits_changed = true
	if val == true:
		_words[_get_word_id(index)] |= (1 << _get_bit_id(index))
	else:
		_words[_get_word_id(index)] &= (_ALL_SET_BITS ^ (1 << _get_bit_id(index)))


func get_at_index(index: int) -> bool:
	validate_index(index)
	return (_words[_get_word_id(index)] & (1 << _get_bit_id(index))) > 0


func set_in_range(start: int, stop: int, val: bool) -> void:
	validate_index(start)
	validate_index(stop - 1)
	if start > stop:
		push_error("start must be <= stop")
	_have_bits_changed = true
	var first_word_id: int = _get_word_id(start)
	var last_word_id: int = _get_word_id(stop - 1)
	var start_bit_id: int = 0
	var stop_bit_id: int = 0
	var bitmask: int = 0
	for word_id in range(first_word_id, last_word_id + 1):
		start_bit_id = _get_bit_id(start) if word_id == first_word_id else 0
		stop_bit_id = _get_bit_id(stop) if word_id == last_word_id else _BITS_PER_WORD
		bitmask = ((1 << (stop_bit_id - start_bit_id)) - 1) << (start_bit_id)
		if val == true:
			_words[word_id] |= bitmask
		else:
			_words[word_id] &= (_ALL_SET_BITS ^ bitmask)


func bitwise_and(other_bit_set: BitSet) -> void:
	_have_bits_changed = true
	for i in range(_num_words):
		_words[i] &= other_bit_set._words[i]


func bitwise_xor(other_bit_set: BitSet) -> void:
	_have_bits_changed = true
	for i in range(_num_words):
		_words[i] ^= (other_bit_set._words[i])


# Clears all bits in this bitset which are set in the other bitset
func bitwise_and_not(other_bit_set: BitSet) -> void:
	_have_bits_changed = true
	for i in range(_num_words):
		_words[i] &= (~other_bit_set._words[i])


func bitwise_intersects(other_bit_set: BitSet) -> bool:
	for i in range(_num_words):
		if _words[i] & other_bit_set._words[i]:
			return true
	return false


func next_set_bit(index: int) -> int:
	var word_id: int = _get_word_id(index)
	var bit_id: int = _get_bit_id(index)
	if (_words[word_id] & (_ALL_SET_BITS << bit_id)) > 0:
		return _next_set_bit_in_word(_words[word_id], bit_id) + _BITS_PER_WORD * word_id
	elif word_id == _num_words - 1:
		return -1
	else:
		for id in range(word_id + 1, _num_words):
			if (_words[id] > 0):
				return _next_set_bit_in_word(_words[id], 0) + _BITS_PER_WORD * id
	return -1


func clear() -> void:
	_have_bits_changed = true
	for i in range(_num_words):
		_words[i] = 0


# Return the number of bits set to true
func cardinality() -> int:
	if _have_bits_changed:
		_update_for_changed_bits()
	return _cardinality


func _update_for_changed_bits():
	_update_print_str_for_changed_bits()
	_update_cardinality_for_changed_bits()
	_have_bits_changed = false


func _update_print_str_for_changed_bits():
	var print_str: String = ""
	var padding: int
	for i in range(_num_words):
		padding = [_BITS_PER_WORD, _num_bits - i * _BITS_PER_WORD].min()
		print_str = _word_to_string(_words[i], padding) + print_str
	_print_str = print_str


func _update_cardinality_for_changed_bits():
	var ans: int = 0
	var index: int = next_set_bit(0)
	while index != -1 && index < _num_bits:
		index  = next_set_bit(index + 1)
		ans += 1
	_cardinality = ans


func _to_string() -> String:
	if _have_bits_changed:
		_update_for_changed_bits()
	return _print_str


func _word_to_string(word: int, num_bits: int) -> String:
	var word_str: String = ""
	var bit_mask: int
	for bit in range(num_bits):
		bit_mask = 1 << bit
		if word & bit_mask > 0:
			word_str = "1" + word_str
		else:
			word_str = "0" + word_str
	return word_str


func _get_word_id(index: int) -> int:
	return index / _BITS_PER_WORD


func _get_bit_id(index: int) -> int:
	return index % _BITS_PER_WORD
	

func _next_set_bit_in_word(word: int, start_id: int) -> int:
	for i in range(start_id, _BITS_PER_WORD):
		if (1 << i) & word:
			return i
	return -1
