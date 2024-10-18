# Virtual base class for all states.
extends Node
class_name State
## Node that parents a [StateMachine]
##
## States are diffrent from sub-states ([member PlayerMovement.normal_actions]), and will run only 
## that nodes code if [member StateMachine.state] matches that node. [br]
## [br]
## Note: This should be used over [member PlayerMovement.normal_actions] for senarios when 
## you need to handle movement outside the scope of normal platforming, or need to isolate
## certain movement behaviors. [br]
## [member PlayerMovement.normal_actions] is for mostly cosmettic behaviors 
## (such as skidding), or additive to the normal movement logic (such as rolling).

## Reference to the state machine, to call its `transition_to()` method directly.
## That's one unorthodox detail of our state implementation, as it adds a dependency between the
## state and the state machine objects, but we found it to be most efficient for our needs.
## The state machine node will set it.
var state_machine = null


## Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent) -> void:
	pass


## Virtual function. Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


## Virtual function. Corresponds to the `_physics_process()` callback.
func physics_update(_delta: float) -> void:
	pass


## Virtual function. Called by the state machine upon changing the active state. The `msg` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	pass


## Virtual function. Called by the state machine before changing the active state. Use this function
## to clean up the state.
func exit() -> void:
	pass
