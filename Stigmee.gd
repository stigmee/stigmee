extends Spatial

func _ready():
	pass

# Enable the camera only
func _process(_delta):
	Global.enable_orbit_camera = not \
	($SceneManager/StrandScene/BrowserGUI/Interface.visible or \
	 $SceneManager/StrandScene/AutofillLinkPanel.visible or \
	 $SceneManager/StrandScene/BrowserGUI/RenameLinkPanel \
	)
	pass
