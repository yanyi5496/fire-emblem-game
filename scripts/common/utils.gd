extends RefCounted

class_name Utils

static func clamp_int(value: int, min_val: int, max_val: int) -> int:
	return clampi(value, min_val, max_val)

static func lerp_ratio(from: float, to: float, weight: float) -> float:
	return lerpf(from, to, weight)

static func is_in_range(value: int, min_val: int, max_val: int) -> bool:
	return value >= min_val and value <= max_val

static func manhattan_distance(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)

static func format_hp(current: int, max_hp: int) -> String:
	return "%d/%d" % [current, max_hp]
