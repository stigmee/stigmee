extends Button

signal save_link

var rename_link_panel
var new_name_input

func _ready():
	var interface = find_parent("Interface")
	rename_link_panel = interface.get_node("RenameLinkPanel")
	new_name_input = interface.get_node("RenameLinkPanel/VBoxContainer/NewNameInput")
	
	rename_link_panel.visible = false

func _on_Button_pressed():
	var name = new_name_input.text
	if name.length() == 0:
		return
	emit_signal("save_link", name)
	rename_link_panel.visible = false

func _on_SaveLinkBtn_pressed():
	new_name_input.text = ""
	rename_link_panel.visible = true
