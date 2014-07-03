#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "ItemLocalizable.h"

@interface EditorLocalizable : NSObject

+(NSString *) defaultPathLocalizablePath;

+(void) saveItemLocalizable:(ItemLocalizable *)itemLocalizable
                     toPath:(NSString *) toPath;

@end
