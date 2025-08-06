extends Resource

class_name Profile

@export var savename:String = "profile"
## Censors the name wherever it's brought up.
## [br]Mainly used for signifying "mysterious higherups"
@export var name_censored:bool = false
## Allows you to edit any observation, even if it's not your own
@export var admin_profile:bool = false
@export var undeletable:bool = false
@export var hidden:bool = false
