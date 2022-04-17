extends Spatial

func _ready():
	pass

# Enable the camera only
func _process(delta):
	Global.enable_orbit_camera = not \
	($SceneManager/StrandScene/BrowserGUI.visible or \
	 $SceneManager/StrandScene/AutofillLinkPanel.visible)
	pass
