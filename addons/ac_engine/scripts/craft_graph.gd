class_name AcCraftGraph
extends Node
## An abstract class that provides a graph data structure for crafting recipes
## AcCraftSystem must has a reference to this class to work properly 


var node_template: Dictionary = {
	"data": null,
	"parents": [], # List of Dictionaries
	"children": [], # List of Dictionaries
}

## Nodes that have no parents
var root_nodes: Array[Dictionary] = []


func add_node(data: Variant, parents: Array[Variant] = []) -> Dictionary:
	var node = node_template.duplicate(true)
	node["data"] = data

	if parents == []:
		if root_nodes.has(node) == false:
			root_nodes.append(node)
	else:
		for parent in parents:
			var parent_node = search_node(parent)
			if parent_node["children"].has(node) == false:
				parent_node["children"].append(node)
			
			if node["parents"].has(parent_node) == false:
				node["parents"].append(parent_node)

	return node


func search_node_children(node: Dictionary, data: Variant) -> Dictionary:
	if node["children"] == []:
		return {}
	
	for child in node["children"]:
		if child["data"] == data:
			return child
		
		if child["children"]:
			var result = search_node_children(child, data)
			if result:
				return result

	return {}


func search_node(data: Variant) -> Dictionary:
	for node in root_nodes:
		if node["data"] == data:
			return node
		
		var result = search_node_children(node, data)
		if result:
			return result
	
	return {}


func remove_node(data: Variant) -> void:
	var node = search_node(data)
	if node:
		for parent in node["parents"]:
			parent["children"].erase(node)
		
		for child in node["children"]:
			child["parents"].erase(node)
		
		if root_nodes.find(node) != -1:
			root_nodes.erase(node)


func print_node(node: Dictionary, level: int) -> void:
	var tabs = ""
	for i in range(level):
		tabs += "\t"
	
	print(tabs + str(node["data"]))

	for child in node["children"]:
		print_node(child, level + 1)


func print_graph() -> void:
	print("ROOT NODE COUNT: ", root_nodes.size())
	for node in root_nodes:
		print("ROOT: ")
		print_node(node, 0)


func to_json_children(node: Dictionary) -> String:
	var json = "["

	for i in range(node["children"].size()):
		json += "{\"data\": " + JSON.stringify(node["children"][i]["data"]) + ", \"children\": " + to_json_children(node["children"][i]) + "}"
		if i < node["children"].size() - 1:
			json += ", "
	
	json += "]"
	return json


func to_json() -> String:
	var json = "["

	for i in range(root_nodes.size()):
		json += "{\"data\": " + JSON.stringify(root_nodes[i]["data"]) + ", \"children\": " + to_json_children(root_nodes[i]) + "}"
		if i < root_nodes.size() - 1:
			json += ", "
	
	json += "]"
	return json


func from_json_children(node: Dictionary, children: Array) -> void:
	for child in children:
		var new_node = add_node(child["data"], [node["data"]])
		if node["children"].has(new_node) == false:
			node["children"].append(new_node)
		from_json_children(new_node, child["children"])


func from_json(json: String) -> void:
	var json_parser = JSON.new()
	var result = json_parser.parse(json)
	if result != OK:
		print("cannot parse JSON")
		return
	
	for node in json_parser.data:
		var new_node = add_node(node["data"])
		from_json_children(new_node, node["children"])
