extends Button

signal save_link

func _ready():
	get_parent().get_node("RenameLinkPanel").visible = false

func _on_Button_pressed():
	var name = get_parent().get_node("RenameLinkPanel/VBoxContainer/NewNameInput").text
	if name.length() == 0:
		return
	emit_signal("save_link", name)
	get_parent().get_node("RenameLinkPanel").visible = false

func _on_SaveLinkBtn_pressed():
	get_parent().get_node("RenameLinkPanel/VBoxContainer/NewNameInput").text = ""
	get_parent().get_node("RenameLinkPanel").visible = true
