GO_EASY_ON_ME=1
FINAL_PACKAGE=1
DEBUG=0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = DragspringPrefs
DragspringPrefs_FILES = *.m
DragspringPrefs_INSTALL_PATH = /Library/PreferenceBundles
DragspringPrefs_FRAMEWORKS = UIKit
DragspringPrefs_PRIVATE_FRAMEWORKS = Preferences
DragspringPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs
DragspringPrefs_LIBRARIES = colorpicker
ARCHS = arm64 arm64e

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/DragspringPrefs.plist$(ECHO_END)
