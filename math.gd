class_name Math
extends Reference


const _factorials: Array = [1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800, 
39916800, 479001600, 6227020800, 87178291200, 1307674368000, 20922789888000, 
355687428096000, 6402373705728000, 121645100408832000, 2432902008176640000]


static func factorial(n: int) -> int:
	return _factorials[n]


static func get_mst_edges(node_count: int, sorted_edges: Array) -> Array:
	var node_to_tree := {}
	for i in range(node_count):
		node_to_tree[i] = i
	var mst_edges: Array = []
	for edge in sorted_edges:
		if node_to_tree[edge[0]] < node_to_tree[edge[1]]:
			mst_edges.append(edge)
			node_to_tree[edge[1]] = node_to_tree[edge[0]]
		elif node_to_tree[edge[1]] < node_to_tree[edge[0]]:
			mst_edges.append(edge)
			node_to_tree[edge[0]] = node_to_tree[edge[1]]
		if mst_edges.size() == node_count - 1:
			return mst_edges
	
	return mst_edges
