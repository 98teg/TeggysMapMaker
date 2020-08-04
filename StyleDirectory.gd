extends Node

var dir : Directory = Directory.new()

func open(path):
	return dir.open(path)

func get_current_dir():
	print(dir)
	return dir.get_current_dir()
