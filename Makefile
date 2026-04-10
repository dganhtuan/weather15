THEOS_PACKAGE_SCHEME = rootless
TARGET := iphone:clang:14.5:15.0
ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = weather15
weather15_FILES = $(shell find Sources/weather15 -name '*.swift') $(shell find Sources/weather15C -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
weather15_SWIFTFLAGS = -ISources/weather15C/include
weather15_CFLAGS = -fobjc-arc -ISources/weather15C/include
weather15_LIBRARIES = pddokdo

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += weather15prefs
include $(THEOS_MAKE_PATH)/aggregate.mk