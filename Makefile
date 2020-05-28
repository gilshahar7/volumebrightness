ARCHS = arm64 armv7 arm64e
export TARGET = iphone:clang:10.3:7.0

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = VolumeBrightness

VolumeBrightness_FILES = Tweak.x
VolumeBrightness_CFLAGS = -fobjc-arc
VolumeBrightness_FRAMEWORKS = CoreTelephony AudioToolbox

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += volumebrightnessprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
