include theos/makefiles/common.mk

TWEAK_NAME = CalendarActivatorAction
CalendarActivatorAction_FILES = Tweak.xm
CalendarActivatorAction_FRAMEWORKS = UIKit
CalendarActivatorAction_LDFLAGS = -lactivator

include $(THEOS_MAKE_PATH)/tweak.mk
