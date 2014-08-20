export ARCHS = armv7 arm64 armv7s
export SOURCE = src
export THEOS = theos
export TARGET_IPHONEOS_DEPLOYMENT_VERSION = 5.0

export ADDITIONAL_OBJCFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DreamBoard
DreamBoard_FILES = $(SOURCE)/Tweak.xm
DreamBoard_FRAMEWORKS = Foundation UIKit CoreGraphics
DreamBoard_OBJC_FILES = $(SOURCE)/DBActionParser.m $(SOURCE)/DBAppIcon.m $(SOURCE)/DBAppSelectionTable.m $(SOURCE)/DBButton.m $(SOURCE)/DBGrid.m $(SOURCE)/DBLoadingView.m $(SOURCE)/DBLockView.m $(SOURCE)/DBScrollView.m $(SOURCE)/DBTheme.mm $(SOURCE)/DBWebView.mm $(SOURCE)/DreamBoard.m $(SOURCE)/ExposeSwitcher.m $(SOURCE)/ExposeSwitcherObject.m

include $(THEOS)/makefiles/tweak.mk