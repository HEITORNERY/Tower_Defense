extends Control

class_name Loser

func _ready() -> void:
	$AnimationPlayer.play("suspense")

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
