extends Resource
class_name Player

var name: String

func to_dict() -> Dictionary:
	return {
		"name": name,
	}

func from_dict(data: Dictionary) -> void:
	name = data.get("name", "")
