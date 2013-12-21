export TARGET=iphone:7.0
export ARCHS=armv7 armv7s

include $(THEOS)/makefiles/common.mk

export SOURCE=source

TWEAK_NAME = DreamBoard
DreamBoard_FILES = $(SOURCE)/Tweak.xm
DreamBoard_FRAMEWORKS = Foundation UIKit CoreGraphics QuartzCore
DreamBoard_OBJC_FILES = $(SOURCE)/DBActionParser.m $(SOURCE)/DBAppIcon.m $(SOURCE)/DBAppSelectionTable.m $(SOURCE)/DBButton.m $(SOURCE)/DBGrid.m $(SOURCE)/DBLoadingView.m $(SOURCE)/DBLockView.m $(SOURCE)/DBScrollView.m $(SOURCE)/DBTheme.mm $(SOURCE)/DBWebView.mm $(SOURCE)/DreamBoard.m $(SOURCE)/ExposeSwitcher.m $(SOURCE)/ExposeSwitcherObject.m

include $(THEOS)/makefiles/tweak.mk