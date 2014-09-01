#import <AppKit/AppKit.h>
#import "ExtractLocalizationWindowController.h"

@interface ExtractLocalization : NSObject

@property(strong) ExtractLocalizationWindowController * extractLocationWindowController;
@property(strong) NSString * defaultLocalizableFilePath;

+(BOOL)isSwift;

@end