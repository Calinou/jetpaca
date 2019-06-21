# This file is part of the Jetpaca game
# Copyright (c) 2009-2016 Juan Linietsky, Ariel Manzur
# Distributed under the terms of the MIT license (cf. LICENSE.md file)

extends Node2D

export var max_distance = 600.0
var active = false

func get_closest_character_position():
	var clist = get_tree().get_nodes_in_group("character")
	var d = 1.0e10
	var retp

	for c in clist:
		var cp = c.get_global_position()
		var ld = (get_global_position() - cp).length()
		if ld < d:
			retp = cp
			d = ld

	return retp

func _process(delta):
	var p = get_node("platform")
	if get_closest_character_position().distance_to(p.get_global_position()) > max_distance:
		_reset()
	else:
		get_tree().call_group("_fire_triggers", "set_on_fire", get_node("platform/trigger").get_global_position())

func _reset():
	set_process(false)
	var p = get_node("platform")
	p.set_mode(RigidBody2D.MODE_STATIC)
	p.set_global_transform(get_global_transform())
	p.set_linear_velocity(Vector2())
	p.set_angular_velocity(0)
	active = false

func _ready():
	_reset()

func _on_enter_screen():
	get_node("platform/fire").set_emitting(true)

func _on_exit_screen():
	get_node("platform/fire").set_emitting(false)

func _on_body_enter(body):
	if active:
		return
	if body is preload("res://player/alpaca.gd"):
		get_node("platform").set_deferred("mode", RigidBody2D.MODE_RIGID)
		get_node("platform").set_sleeping(false) # suspend
		active = true
		set_process(true)

