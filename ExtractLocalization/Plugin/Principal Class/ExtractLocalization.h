#import <AppKit/AppKit.h>
#import "ExtractLocalizationWindowController.h"

@interface ExtractLocalization : NSObject

@property(strong) ExtractLocalizationWindowController * extractLocationWindowController;
@property(strong) NSArray * localizableFilePaths;

+(BOOL)isSwift;

@end