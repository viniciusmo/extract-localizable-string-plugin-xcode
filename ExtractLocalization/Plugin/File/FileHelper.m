#import "FileHelper.h"

@implementation FileHelper

+ (NSArray *) recursivePathsForResourcesOfType: (NSString *)type inDirectory: (NSString *)directoryPath{
    NSMutableArray *filePaths = [[NSMutableArray alloc] init];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:directoryPath] ;
    NSString *filePath;
    while ( (filePath = [enumerator nextObject] ) != nil ){
        if( [filePath rangeOfString:type].location != NSNotFound ){
            [filePaths addObject:[directoryPath stringByAppendingString: filePath]];
        }
    }
    return filePaths;
}

@end
