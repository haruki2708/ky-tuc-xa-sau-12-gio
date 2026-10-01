class_name TestCase
extends RefCounted
## Base class for tests. Put files named test_*.gd in res://tests/ (any depth),
## extend TestCase, and write methods named test_*(). Methods may use await.
## `tree` is the running SceneTree; add nodes to `tree.root` and free them.

var tree: SceneTree
var failures: PackedStringArray = []


func before_each() -> void:
	pass


func after_each() -> void:
	pass


func assert_true(condition: bool, message: String = "expected true") -> void:
	if not condition:
		failures.append(message)


func assert_false(condition: bool, message: String = "expected false") -> void:
	assert_true(not condition, message)


func assert_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	if actual != expected:
		failures.append("%s expected <%s> got <%s>" % [message, expected, actual])


func assert_not_null(value: Variant, message: String = "expected non-null") -> void:
	assert_true(value != null, message)


## Wait n process frames (lets _ready/_process/physics run).
func wait_frames(n: int = 1) -> void:
	for i in n:
		await tree.process_frame
