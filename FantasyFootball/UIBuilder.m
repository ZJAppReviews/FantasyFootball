
#import "UIBuilder.h"
#import "Util.h"

UILabel* newLabel(CGRect frame, NSString *text, UIFont *font, UIColor *colour) {
	UILabel *ui = [[UILabel alloc] initWithFrame:frame];
	ui.backgroundColor = [UIColor clearColor];
	ui.adjustsFontSizeToFitWidth = YES;
	if (font != nil)
		ui.font = font;
	if (colour != nil)
		ui.textColor = colour;
	if (text != nil)
		ui.text = text;
	return ui;
}

UITextField* newTextField(CGRect frame, NSString *ph, UIFont *font, UIColor *colour, UIKeyboardType kbType, id delegate) {
	UITextField *ui = [[UITextField alloc] initWithFrame:frame];
	ui.backgroundColor = [UIColor clearColor];
	if (font != nil)
		ui.font = font;
	if (colour != nil)
		ui.textColor = colour;
	ui.keyboardType = kbType;
	ui.returnKeyType = UIReturnKeyDone;
	if (ph != nil)
		ui.placeholder = ph;
	if (delegate != nil)
		ui.delegate = delegate;
	return ui;
}

UITextView* newTextView(CGRect frame, UIFont *font, UIColor *colour, UIKeyboardType kbType, id delegate) {
	UITextView *ui = [[UITextView alloc] initWithFrame:frame];
	ui.backgroundColor = [UIColor clearColor];
	if (font != nil)
		ui.font = font;
	if (colour != nil)
		ui.textColor = colour;
	ui.keyboardType = kbType;
	ui.returnKeyType = UIReturnKeyDone;
	if (delegate != nil)
		ui.delegate = delegate;
	return ui;
}

UISegmentedControl* newSegmentedControl(CGRect frame, NSArray *items, UIColor *colour, int selectedIndex, BOOL momentary) {
	UISegmentedControl *ui = [[UISegmentedControl alloc] initWithItems:items];
	ui.frame = frame;
    //ui.segmentedControlStyle = UISegmentedControlStyleBar;
	if (selectedIndex >= 0)
		ui.selectedSegmentIndex = selectedIndex;
	ui.tintColor = colour;
	ui.momentary = momentary;
	return ui;
}

UISlider* newSlider(CGRect frame, float min, float max, float value) {
	UISlider *ui = [[UISlider alloc] initWithFrame:frame];
	ui.backgroundColor = [UIColor clearColor];	
	ui.minimumValue = min;
	ui.maximumValue = max;
	ui.continuous = YES;
	ui.value = value;
	return ui;
}

UIButton* newButton(CGRect frame, NSString *text, UIFont *font, UIImage *normalImage, UIImage *pressedImage) {
	UIButton *ui = [[UIButton alloc] initWithFrame:frame];
	ui.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	ui.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	if (text != nil)
		[ui setTitle:text forState:UIControlStateNormal];
	if (font != nil)
		ui.titleLabel.font = font;
	if (normalImage != nil)
		[ui setBackgroundImage:[normalImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateNormal];
	if (pressedImage != nil)
		[ui setBackgroundImage:[pressedImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
	return  ui;
}

UIView* newView(CGRect frame, UIColor *colour, UIColor *borderColor, float borderWidth, float cornerRadius) {
	UIView *ui = [[UIView alloc] initWithFrame:frame];
	if (colour != nil)
		ui.backgroundColor = colour;
	ui.layer.cornerRadius = cornerRadius;
	if (borderColor != nil)
		ui.layer.borderColor = borderColor.CGColor;
	ui.layer.borderWidth = borderWidth;
	ui.layer.masksToBounds = YES;
	return ui;
}

UIScrollView* newScrollView(CGRect frame, UIColor *colour, UIColor *borderColor, float borderWidth, float cornerRadius) {
	UIScrollView *ui = [[UIScrollView alloc] initWithFrame:frame];
	if (colour != nil)
		ui.backgroundColor = colour;
	ui.layer.cornerRadius = cornerRadius;
	if (borderColor != nil)
		ui.layer.borderColor = borderColor.CGColor;
	ui.layer.borderWidth = borderWidth;
	ui.layer.masksToBounds = YES;
	ui.showsHorizontalScrollIndicator = NO;
	ui.showsVerticalScrollIndicator = NO;
	return ui;
}

UIImageView* newImageView(NSString *imageName) {
	return [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
}

UISwitch* newSwitch(CGRect frame, UIColor *colour) {
    UISwitch *ui = [[UISwitch alloc] initWithFrame:frame];
    if ([ui respondsToSelector:@selector(setOnTintColor:)]) {
        if (colour == nil)
            [ui performSelector:@selector(setOnTintColor:) withObject:[UIColor colorWithRed:104/255.0 green:75/255.0 blue:60/255.0 alpha:1.0]];
        else
            [ui performSelector:@selector(setOnTintColor:) withObject:colour];
    }
    return ui;
}

void showAlert(NSString *title, NSString *message, id delegate, NSString *cancelButton, NSString *otherButton1, NSString *otherButton2) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                     message:message
                                                    delegate:delegate
                                           cancelButtonTitle:cancelButton
                                           otherButtonTitles:otherButton1, otherButton2, nil];
    [alert show];
}
