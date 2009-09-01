#import "CandWord.h"
#import "UIAccelerometer+Private.h"
#import "UIActionSheet+Private.h"
#import "UIAlertView+Private.h"
#import "UIApplication+Private.h"
#import "UICalloutBar.h"
#import "UICalloutBarButton.h"
#import "UIDevice+Private.h"
#import "UIEvent+Private.h"
#import "UIFieldEditor.h"
#import "UIHardware.h"
#import "UIKeyboard.h"
#import "UIKeyboardEmojiPage.h"
#import "UIKeyboardImpl.h"
#import "UIKeyboardInput.h"
#import "UIKeyboardInputManager.h"
#import "UIKeyboardLayout.h"
#import "UIKeyboardLayoutRoman.h"
#import "UIKeyDefinition.h"
#import "UINavigationItemView.h"
#import "UINavigationItemButtonView.h"
#import "UIPickerView+Private.h"
#import "UIPickerTable.h"
#import "UIResponder+Private.h"
#import "UIScroller.h"
#import "UITable.h"
#import "UITableCell.h"
#import "UITextField+Private.h"
#import "UITextView+Private.h"
#import "UITextViewLegacy.h"
#import "UIThreadSafeNode.h"
#import "UITransitionView.h"
#import "UIWebDocumentView.h"
#import "UIWindow+Private.h"

#define TouchesGetLocationInView(touches, view) [(UITouch *)[touches anyObject] locationInView:view]
#define TouchesPointInView()	TouchesGetLocationInView(touches, self)
#define TouchesPointInWindow()	TouchesGetLocationInView(touches, [self window])


// 3.0

#import "UIKBKey.h"
#import "UIKBShape.h"
#import "UIKeyboardLayoutStar.h"
#import "UIMenuController.h"
#import "UITextEffectsWindow.h"
#import "UIPasteboard.h"