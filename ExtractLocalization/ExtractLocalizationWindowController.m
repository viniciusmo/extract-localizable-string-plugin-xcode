#import "ExtractLocalizationWindowController.h"

@implementation ExtractLocalizationWindowController

-(IBAction)doClickOK:(id)sender{
    _extractLocalizationDidConfirm(_txtKey.stringValue);
    [[self window ]orderOut:self];
}

-(void)showWindow{
    [self showWindow:nil];
}

-(void)fillFieldValue:(NSString *) value{
    value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    value = [value stringByReplacingOccurrencesOfString:@"@" withString:@""];
    _txtValue.stringValue = value;
}

@end
