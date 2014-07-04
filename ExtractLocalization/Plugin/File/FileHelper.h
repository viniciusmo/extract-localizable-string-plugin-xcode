#import <Foundation/Foundation.h>

@interface FileHelper : NSObject

+(NSArray *) recursivePathsForResourcesOfType: (NSString *)type
                                   inDirectory: (NSString *)directoryPath;

@end
