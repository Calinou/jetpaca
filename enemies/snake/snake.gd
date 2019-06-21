# This file is part of the Jetpaca game
# Copyright (c) 2009-2016 Juan Linietsky, Ariel Manzur
# Distributed under the terms of the MIT license (cf. LICENSE.md file)

extends "res://enemies/enemy.gd"

const ROLE_HEAD = 0
const ROLE_MIDDLE = 1
const ROLE_TAIL = 2
const DIR_CHANGE_TIMEOUT = 3.0
const TARGET_SPEED = 80.0
const TURN_SPEED = 80.0
const ATTACK_DISTANCE = 800.0
export(int, "Head", "Middle", "Tail") var role = 0

var target_a = randf()*PI*2.0

var timeout = 4.0

func _on_enter_screen():
	set_sleeping(false)

func _on_exit_screen():
	set_sleeping(true)

func _integrate_forces(state):
	var lv= state.get_linear_velocity()
	var av = state.get_angular_velocity()

	if role == ROLE_HEAD:
		var s = TARGET_SPEED
		var t = state.get_transform()
		var ta = target_a
		var cc = get_closest_character()

		if cc:
			var cpos = cc.get_global_position()
			var cposd = cpos.distance_to(t.get_origin())

			if cposd < ATTACK_DISTANCE:
				ta = Vector2(0, 1).angle_to(t.get_origin() - cpos)

		var a = fmod(t.get_rotation() + PI*3.0, 2*PI)
		var rdist
		if ta > a:
			rdist = ta - a
		else:
			rdist = 2.0*PI + ta -a

		if rdist < 0.1 or rdist > 2*PI - 0.1:
			av = 0
		elif rdist > PI:
			av = -state.get_step()*TURN_SPEED
		else:
			av = state.get_step()*TURN_SPEED

		lv = -t[1]*s

		timeout -= state.get_step()
		if timeout < 0:
			target_a = randf()*PI*2.0
			timeout = DIR_CHANGE_TIMEOUT

	else:
		var d = lv.normalized()
		var s = lv.length()

		s -= 500.0 * state.get_step()
		if s < 0:
			s = 0
		lv = d*s
		av = 0

	state.set_linear_velocity(lv)
	state.set_angular_velocity(av)

func _init():
	set_sleeping(true)

func _ready():
	set_use_custom_integrator(true)

