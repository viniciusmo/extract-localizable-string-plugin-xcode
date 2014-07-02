#import <Cocoa/Cocoa.h>

@interface ExtractLocalizationWindowController : NSWindowController

@property (weak) IBOutlet NSTextField * txtKey;
@property (weak) IBOutlet NSTextField * txtValue;
@property (copy) void (^extractLocalizationDidConfirm)(NSString * key);

-(IBAction)doClickOK:(id)sender;

-(void)showWindow;

-(void)fillFieldValue:(NSString *) value;

@end
