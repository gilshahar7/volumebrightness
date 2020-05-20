ARCHS = armv7 arm64 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = VolumeBrightness

VolumeBrightness_FILES = Tweak.x
VolumeBrightness_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
