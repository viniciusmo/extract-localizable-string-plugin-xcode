#import "EditorLocalizable.h"

@implementation EditorLocalizable

+(NSString *) defaultPathLocalizablePath{
    NSArray *workspaceWindowControllers = [NSClassFromString(@"IDEWorkspaceWindowController") valueForKey:@"workspaceWindowControllers"];
    id workSpace;
    for (id controller in workspaceWindowControllers) {
        if ([[controller valueForKey:@"window"] isEqual:[NSApp keyWindow]]) {
            workSpace = [controller valueForKey:@"_workspace"];
        }
    }
    NSString *workspacePath = [[workSpace valueForKey:@"representingFilePath"] valueForKey:@"_pathString"];
    workspacePath = [workspacePath stringByReplacingOccurrencesOfString:@".xcworkspace"
                                                             withString:@""];
    NSString * nameProjectWithExtenstion = [[workspacePath componentsSeparatedByString:@"/"] lastObject];
    NSString * nameProject = [nameProjectWithExtenstion stringByReplacingOccurrencesOfString:@".xcworkspace"
                                                                                  withString:@""];
    NSString * plistNameFile = [NSString stringWithFormat:@"%@/%@-Info.plist",workspacePath,nameProject];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistNameFile];
    NSString * language = [plistDict objectForKey:@"CFBundleDevelopmentRegion"];
    NSString * defaultFileLocalization = [NSString stringWithFormat:@"%@/%@.lproj/Localizable.strings",workspacePath,language];
    return defaultFileLocalization;
}

+(void) saveItemLocalizable:(ItemLocalizable *)itemLocalizable
                     toPath:(NSString *) toPath{
    NSError * error = nil;
    NSString * keyAndValue = [NSString stringWithFormat:@"\"%@\" = \"%@\";\n",itemLocalizable.key,itemLocalizable.value];
    NSString *contents = [NSString stringWithContentsOfFile:toPath
                                                   encoding:NSUTF8StringEncoding
                                                      error:&error];
    contents = [contents stringByAppendingString:keyAndValue];
    [contents writeToFile:toPath atomically:YES encoding: NSUTF8StringEncoding error:&error];
    if(error) { // If error object was instantiated, handle it.
        NSLog(@"ERROR while loading from file: %@", error);
    }
}

@end
