extends Control

class_name Menu

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_credits_pressed() -> void:
	pass # Replace with function body.
