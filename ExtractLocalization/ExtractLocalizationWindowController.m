#import "ExtractLocalizationWindowController.h"

@implementation ExtractLocalizationWindowController

-(IBAction)doClickOK:(id)sender{
    _extractLocalizationDidConfirm();
}

-(void)showWindow{
    [self showWindow:nil];
}

-(void)fillFieldsWith:(NSString *) value andKey:(NSString *) key{
    _txtKey.stringValue = key;
    _txtValue.stringValue = key;
}

@end
