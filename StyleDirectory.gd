extends Node

var dir : Directory = Directory.new()

func open(path):
	print(dir.open(path))

func get_current_dir():
	return dir.get_current_dir()
