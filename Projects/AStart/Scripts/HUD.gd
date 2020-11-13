extends CanvasLayer

signal weiter

func _ready():
	$Button.hide()


func message(text):
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
