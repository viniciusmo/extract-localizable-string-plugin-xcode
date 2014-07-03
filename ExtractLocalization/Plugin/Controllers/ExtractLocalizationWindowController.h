#import <Cocoa/Cocoa.h>
#import "ItemLocalizable.h"

@interface ExtractLocalizationWindowController : NSWindowController

@property (weak) IBOutlet NSTextField * txtKey;
@property (weak) IBOutlet NSTextField * txtValue;
@property (copy) void (^extractLocalizationDidConfirm)(ItemLocalizable * item);

-(IBAction)doClickOK:(id)sender;

-(void)showWindow;

-(void)fillFieldValue:(NSString *) value;

@end
