#import <Cocoa/Cocoa.h>

@interface ExtractLocalizationWindowController : NSWindowController

@property (weak) IBOutlet NSTextField * txtKey;
@property (weak) IBOutlet NSTextField * txtValue;
@property (copy) void (^extractLocalizationDidConfirm)();

-(IBAction)doClickOK:(id)sender;

-(void)showWindow;

-(void)fillFieldsWith:(NSString *) value
               andKey:(NSString *) key;

@end
