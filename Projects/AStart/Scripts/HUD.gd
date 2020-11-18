extends CanvasLayer

signal weiter

onready var TypeList = $Options/SearchTypes

var clear_map = true
var clear_ends = true

func _ready():
	$Button.hide()
	$Options/Label2.text = "Mix factor: %.2f" % $Options/Mix.value
	$Options/Label2.hide()
	$Options/Mix.hide()

func message(text):
	$Message.show()
	$Message.text = text

func hide_message():
	$Message.visible = false

func show_message():
	$Message.visible = true

func show_weiter():
	$Button.show()
	
func hide_weiter():
	$Button.hide()

func _on_Button_pressed():
	emit_signal("weiter")

func add_item_to_list(label):
	TypeList.add_item(label)
	if TypeList.get_item_count() == 1:
		TypeList.select(0)

func get_type():
	var sel = TypeList.get_selected_items()
	if len(sel) > 0:
		return sel[0]
	else:
		0

func get_factor():
	return $Options/Mix.value

func hide_options():
	$Options.hide()

func show_options():
	$Options.show()


func _on_Mix_value_changed(value):
	$Options/Label2.text = "Mix factor: %.2f" % value


func _on_SearchTypes_item_selected(index):
	if TypeList.get_item_text(index) == "Mix":
		$Options/Label2.show()
		$Options/Mix.show()
	else:
		$Options/Label2.hide()
		$Options/Mix.hide()

func get_clear_map():
	return clear_map
	
func get_clear_ends():
	return clear_ends


func _on_ClearMap_toggled(button_pressed):
	clear_map = button_pressed
	if clear_map:
		clear_ends = true
		$Options/ClearEndPoints.pressed = true
		$Options/ClearEndPoints.disabled = true
	else:
		$Options/ClearEndPoints.pressed = false
		$Options/ClearEndPoints.disabled = false


func _on_ClearEndPoints_toggled(button_pressed):
	clear_ends = button_pressed
