TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = weather15prefs

weather15prefs_FILES = TuanRootListController.m
weather15prefs_FRAMEWORKS = UIKit
weather15prefs_PRIVATE_FRAMEWORKS = Preferences
weather15prefs_INSTALL_PATH = /Library/PreferenceBundles
weather15prefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
