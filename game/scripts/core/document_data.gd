class_name DocumentData
extends Resource
## A readable paper, board or log (T-117). Lane A's readable object calls
## mark_rules_read() and emits EventBus.document_opened(id); lane D's close-up
## view renders it. Files live at res://data/documents/<id>.tres. Owner: integrator.

const DIRECTORY := "res://data/documents/"

@export var id: StringName
## Translation key of the heading.
@export var title_key: String
## How it looks: &"stamped" (typed, red stamp), &"photocopy", &"handwritten",
## &"notice" (printed sheet taped to a wall), &"log" (duty log pages).
@export var style: StringName = &"photocopy"
## D-110: what the object is, when it is not a plain sheet: &"photo", &"photo_family"
## (a printed photo; the text is its back) or &"card" (a student ID card). Empty: a sheet.
## The 3D paper and the close-up view both read it.
@export var look: StringName = &""
## Where the player reads it; recorded as the notebook source of each line.
@export var source: StringName
## Rule lines in print order, numbered 1..n; text from each RuleData.text_key.
@export var rule_ids: Array[StringName] = []
## Plain paragraphs after the rules (log entries, signatures...).
@export var text_keys: Array[String] = []


static func load_by_id(document_id: StringName) -> DocumentData:
	var path := DIRECTORY + String(document_id) + ".tres"
	if not ResourceLoader.exists(path):
		return null
	return load(path) as DocumentData


## Adds every rule line of this document to the notebook, with this source.
func mark_rules_read() -> void:
	for rule_id in rule_ids:
		RuleSystem.mark_read(rule_id, source)
