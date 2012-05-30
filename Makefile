GO_EASY_ON_ME=1
include theos/makefiles/common.mk

TWEAK_NAME = CalendarActivatorAction
CalendarActivatorAction_FILES = Tweak.xm
CalendarActivatorAction_FRAMEWORKS = UIKit CoreGraphics
CalendarActivatorAction_LDFLAGS = -lactivator

include $(THEOS_MAKE_PATH)/tweak.mk
