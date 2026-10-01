extends Node
## Global signals shared across lanes. Emit/connect here instead of coupling
## systems directly. Owner: integrator — request new signals in your task card.

## Player focused (or stopped focusing) an interactable. prompt_key is a
## translation key, empty when nothing is focused.
signal interaction_focus_changed(prompt_key: String)

## Player used an interactable.
signal interacted(target: Node)

## Show a subtitle line. text_key is a translation key; duration in seconds.
signal subtitle_requested(text_key: String, duration: float)
