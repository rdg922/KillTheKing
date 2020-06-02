extends Node

const player_path = "res://objects/player.tscn";
#var state_materials = {move = preload("res://scripts/regularShaderMat.tres"), roll = preload("res://scripts/dashShaderMat.tres"), post_roll = preload("res://scripts/postRollShaderMat.tres"), hit = preload("res://scripts/hitShaderMat.tres")}
var state_materials = {};



onready var levels = {"test": preload("res://levels/test.tscn")}; 
var camera;

func _ready():
	state_materials["move"] = preload("res://materials/regularShaderMat.tres")
	state_materials["roll"] = preload("res://materials/dashShaderMat.tres")
	state_materials["post_roll"] = state_materials["move"]
	state_materials["hit"] = preload("res://materials/hitShaderMat.tres")
	state_materials["hookshot"] = state_materials["move"]
	state_materials["fell"] = state_materials["move"]
	pass

sync func shake() -> void:
	camera.shake(0.2, 30, 10)
	pass

sync func shakeHeavy() -> void:
	camera.shake(0.35, 40, 18)
	pass
