
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

UILabel* newLabel(CGRect frame, NSString *text, UIFont *font, UIColor *colour);
UITextField* newTextField(CGRect frame, NSString *ph, UIFont *font, UIColor *colour, UIKeyboardType kbType, id delegate);
UITextView* newTextView(CGRect frame, UIFont *font, UIColor *colour, UIKeyboardType kbType, id delegate);
UISegmentedControl* newSegmentedControl(CGRect frame, NSArray *items, UIColor *colour, int selectedIndex, BOOL momentary);
UISlider* newSlider(CGRect frame, float min, float max, float value);
UIView* newView(CGRect frame, UIColor *colour, UIColor *borderColor, float borderWidth, float cornerRadius);
UIScrollView* newScrollView(CGRect frame, UIColor *colour, UIColor *borderColor, float borderWidth, float cornerRadius);
UIButton* newButton(CGRect frame, NSString *text, UIFont *font, UIImage *normalImage, UIImage *pressedImage);
UIButton* newSingleImageButton(CGRect frame, NSString *text, UIFont *font, UIImage *image);
UIButton* newTransparentButton(CGRect frame, NSString *text, UIFont *font);
UIImageView* newImageView(NSString *imageName);
UISwitch* newSwitch(CGRect frame, UIColor *colour);
void showAlert(NSString *title, NSString *message, id delegate, NSString *cancelButton, NSString *otherButton1, NSString *otherButton2);
