extends ViewportCardFocus

func _ready():
	._ready()
	
	# initialise combatSystem (it starts/ends combat)
	# which in turn initialises:
	# - ActiveTurnQueue (contains list of battlers)
	# - UI (gets passed a list of battlers)
	# 
