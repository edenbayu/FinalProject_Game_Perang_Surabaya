class_name FiniteStateMachine
extends Node

@export var state: State

func _ready():
	print("state: ", state)

func change_state(new_state: State) -> void:
	if state is State:
		state._exit_state()
	new_state._enter_state()
	state = new_state

func initiate_fsm() -> void:
	change_state(state)
