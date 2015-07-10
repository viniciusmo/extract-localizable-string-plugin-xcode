#import "ExtractLocalizationWindowController.h"

@implementation ExtractLocalizationWindowController

-(IBAction)doClickOK:(id)sender{
    ItemLocalizable * item = [[ItemLocalizable alloc]
                              initWithKey:_txtKey.stringValue
                              andValue:_txtValue.stringValue andComment:_txtComment.stringValue];
    _extractLocalizationDidConfirm(item);    
}

-(void)showWindow{
    [_txtKey setTarget:self];
    [_txtKey setAction:@selector(doClickOK:)];
    [self showWindow:nil];
}

-(void)fillFieldValue:(NSString *) value{
    value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    value = [value stringByReplacingOccurrencesOfString:@"@" withString:@""];
    _txtValue.stringValue = value;
}

- (BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector
{
    BOOL result = NO;
    
    if (commandSelector == @selector(insertNewline:))
    {
        [self doClickOK:textView];
        return YES;
    }
    else if (commandSelector == @selector(insertTab:))
    {
        NSLog(@"%ld", (long)textView.tag);
        NSView *view = [self.window.contentView viewWithTag:(textView.tag + 1)];
        [view becomeFirstResponder];
    }
    
    return result;
}

@end
