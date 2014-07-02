#import <Cocoa/Cocoa.h>

@interface ExtractLocalizationWindowController : NSWindowController

@property (weak) IBOutlet NSTextField * txtKey;
@property (weak) IBOutlet NSTextField * txtValue;

-(IBAction)doClickOK:(id)sender;

@end
