#import "ExtractLocalizationWindowController.h"

@implementation ExtractLocalizationWindowController

-(IBAction)doClickOK:(id)sender{
    ItemLocalizable * item = [[ItemLocalizable alloc]
                              initWithKey:_txtKey.stringValue
                              andValue:_txtValue.stringValue];
    _extractLocalizationDidConfirm(item);
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
