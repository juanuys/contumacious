extends ViewportCardFocus

# load the arena, and add it on top of the board
var arena_scene = preload("res://src/battle/Arena.tscn")

func _ready():
	
	# first, disable some things on the board_scene
	# (Whenever CGF upgrades, it's easier to run the quickstart again,
	# which breaks any changes I might have made, so rather make
	# changes externally like this.)
	$ViewportContainer/Viewport/Board/FancyMovementToggle.hide()
	$ViewportContainer/Viewport/Board/OvalHandToggle.hide()
	$ViewportContainer/Viewport/Board/ScalingFocusOptions.hide()
	$ViewportContainer/Viewport/Board/DeckBuilder.hide()
	$ViewportContainer/Viewport/Board/PlacementGridDemo.hide()
	$ViewportContainer/Viewport/Board/ModifiedLabelGrid.hide()
	$ViewportContainer/Viewport/Board/SeedLabel.hide()
	$ViewportContainer/Viewport/Board/EnableAttach.hide()
	$ViewportContainer/Viewport/Board/Debug.hide()
	$ViewportContainer/Viewport/Board/ReshuffleAllDeck.hide()
	$ViewportContainer/Viewport/Board/ReshuffleAllDiscard.hide()
	
	# add the arena scene on top of the board scene
	var Arena = arena_scene.instance()
	$ViewportContainer/Viewport.add_child(Arena)

	# initialise combatSystem (it starts/ends combat)
	# which in turn initialises:
	# - ActiveTurnQueue (contains list of battlers)
	# - UI (gets passed a list of battlers)
	
	print(Arena.get_children())
	
