include $(THEOS)/makefiles/common.mk

ARCHS = arm64 armv7 arm64e
export TARGET = iphone:clang:10.3:7.0

BUNDLE_NAME = VolumeBrightnessPrefs

VolumeBrightnessPrefs_FILES = VBPRootListController.m
VolumeBrightnessPrefs_INSTALL_PATH = /Library/PreferenceBundles
VolumeBrightnessPrefs_FRAMEWORKS = UIKit
VolumeBrightnessPrefs_PRIVATE_FRAMEWORKS = Preferences
VolumeBrightnessPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/VolumeBrightnessPrefs.plist$(ECHO_END)
