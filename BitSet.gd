extends Node

class_name BitSet

var _num_words: int = 0
var _num_bits: int = 0
var _words = []
const _BITS_PER_WORD: int = 63
const _ALL_SET_BITS: int = (1 << 63) - 1
var _has_cardinality_changed: bool = true
var _cardinality: int = 0

# Called when the node enters the scene tree for the first time.
#func _ready():#
#	pass # Replace with function body.

func _init(my_num_bits: int):
	_num_bits = my_num_bits
	_num_words = (_num_bits - 1) / _BITS_PER_WORD + 1
	for _i in range(_num_words):
		_words.append(0)

func to_string() -> String:
	return str((_words[0]))

func _get_word_id(index: int) -> int:
	return index / _BITS_PER_WORD

func _get_bit_id(index: int) -> int:
	return index % _BITS_PER_WORD

func set_at_index(index: int, val: bool):
	_has_cardinality_changed = true
	if val == true:
		_words[_get_word_id(index)] |= (1 << _get_bit_id(index))
	else:
		_words[_get_word_id(index)] &= (_ALL_SET_BITS ^ (1 << _get_bit_id(index)))

func set_in_range(from_index: int, to_index: int, val: bool):
	_has_cardinality_changed = true
	var from_word_id: int = _get_word_id(from_index)
	var to_word_id: int = _get_word_id(to_index)
	var from_bit_id: int = 0
	var to_bit_id: int = 0
	var bitmask: int = 0
	for id in range(from_word_id, to_word_id + 1):
		from_bit_id = _get_bit_id(from_index) if id == from_word_id else 0
		to_bit_id = _get_bit_id(to_index) if id == to_word_id else 62
		bitmask = ((1 << (to_bit_id - from_bit_id + 1)) - 1) << (from_bit_id - 1)
		if val == true:
			_words[id] |= bitmask
		else:
			_words[id] &= (_ALL_SET_BITS ^ bitmask)

func bitwise_and(other_bit_set):
	_has_cardinality_changed = true
	for i in range(_num_words):
		_words[i] &= other_bit_set._words[i]

func bitwise_and_not(other_bit_set):
	_has_cardinality_changed = true
	for i in range(_num_words):
		_words[i] &= (~other_bit_set._words[i])

func bitwise_intersects(other_bit_set) -> bool:
	for i in range(_num_words):
		if _words[i] & other_bit_set._words[i]:
			return true
	return false
#
func next_set_bit(index: int) -> int:
	var word_id: int = _get_word_id(index)
	var bit_id: int = _get_bit_id(index)
	if _words[word_id] & (_ALL_SET_BITS << bit_id):
		return _next_set_bit_in_word(_words[word_id], bit_id) + _BITS_PER_WORD * word_id
	elif word_id == _num_words - 1:
		return -1
	else:
		for id in range(word_id + 1, _num_words):
			if _words[word_id]:
				return _next_set_bit_in_word(_words[word_id], 0) + _BITS_PER_WORD * id
	return -1
	
func _next_set_bit_in_word(word: int, start_id: int) -> int:
	for i in range(start_id, _BITS_PER_WORD):
		if (1 << i) & word:
			return i
	return -1

func get_at_index(index: int) -> bool:
	return _words[_get_word_id(index)] & (1 << _get_bit_id(index))

func clear():
	_cardinality = 0
	_has_cardinality_changed = false
	for i in range(_num_words):
		_words[i] = 0

# Return the number of bits set to true
func cardinality() -> int:
	if _has_cardinality_changed:
		var ans: int = 0
		var index: int = next_set_bit(0)
		while index != -1:
			index  = next_set_bit(index + 1)
			ans += 1
		_cardinality = ans
		_has_cardinality_changed = false
		return ans
	else:
		return _cardinality
