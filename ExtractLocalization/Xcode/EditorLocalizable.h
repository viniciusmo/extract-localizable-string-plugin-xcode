#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "ItemLocalizable.h"

@interface EditorLocalizable : NSObject

+(NSArray *) localizableFilePaths;

+(void) saveItemLocalizable:(ItemLocalizable *)itemLocalizable
                     toPath:(NSString *) toPath;

+(NSString *) chooseFileLocalizableString;

@end
