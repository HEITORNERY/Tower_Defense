extends Control

class_name Credits

func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_page_pressed() -> void:
	OS.shell_open("https://heitornery.itch.io/")
