class_name AcTree
extends Node

var node_template: Dictionary = {
	"root": null, # Dictionary
	"data": null,
	"children": [], # List of Dictionaries
}

var node_root: Dictionary = node_template.duplicate()


# func is_root(node: Dictionary) -> bool:
# 	return node == node_root


# func add_node(data: Variant, parent: Dictionary = node_root) -> Dictionary:
# 	var new_node = node_template.duplicate()
# 	new_node["data"] = data
# 	new_node["root"] = parent
# 	parent["children"].append(new_node)
# 	return new_node


# func search_node(data: Variant, compare_func: FuncRef, parent: Dictionary = node_root) -> Dictionary:
# 	for child in parent["children"]:
# 		if compare_func.call_func(data, child["data"]):
# 			return child
# 		var result = search_node(data, compare_func, child)
# 		if result:
# 			return result
# 	return null

# func add_node(data: Dictionary, parent: Dictionary = node_root) -> Dictionary:
# 	var new_node = node_template.duplicate()
# 	new_node["data"] = data
# 	new_node["root"] = parent
# 	parent["children"].append(new_node)
# 	return new_node


# func search_node(data: Dictionary, parent: Dictionary = node_root) -> Dictionary:
# 	for child in parent["children"]:
# 		if child["data"] == data:
# 			return child
# 		var result = search_node(data, child)
# 		if result:
# 			return result
# 	return null


# func remove_node(node: Dictionary) -> void:
# 	if node == node_root:
# 		return
	
# 	var node = search_node(node["data"], node["root"])
# 	if node:
# 		# Remove all children
# 		for child in node["children"]:
# 			remove_node(child)
		
# 		# Remove from parent
# 		node["root"]["children"].erase(node["root"]["children"].find(node))

