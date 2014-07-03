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
    workspacePath = [self removeStrings:workspacePath andArrayOfStringsToRemove:@[@".xcodeproj", @".xcworkspace"]];
    
    NSString * nameProjectWithExtenstion = [[workspacePath componentsSeparatedByString:@"/"] lastObject];
    NSString * nameProject = [self removeStrings:nameProjectWithExtenstion
                       andArrayOfStringsToRemove:@[@".xcodeproj", @".xcworkspace"]];
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
    if(error) {
        NSLog(@"ERROR while loading from file: %@", error);
    }
}

+(NSString * )removeStrings:(NSString *)string andArrayOfStringsToRemove:(NSArray *)stringsToRemove{
    for (NSString * toRemove  in stringsToRemove) {
        string = [string stringByReplacingOccurrencesOfString:toRemove
                                                   withString:@""];
    }
    return string;
}


@end
