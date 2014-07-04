#import "EditorLocalizable.h"
#import "FileHelper.h"

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
    NSString * language = [NSString stringWithFormat:@"%@.lproj",[plistDict objectForKey:@"CFBundleDevelopmentRegion"]];
    NSString * typeOfDefaultFile = [NSString stringWithFormat:@"%@/Localizable.strings",language];
    NSArray * filesFounded = [FileHelper recursivePathsForResourcesOfType:typeOfDefaultFile inDirectory:workspacePath];
    NSString * defaultFileLocalization  = nil;
    if ([filesFounded count] > 0) {
        defaultFileLocalization = [filesFounded objectAtIndex:0];
        defaultFileLocalization = [defaultFileLocalization stringByReplacingOccurrencesOfString:language withString:[NSString stringWithFormat:@"/%@",language]];
        NSLog(@"DefaultFileLocalization %@",defaultFileLocalization);
    }
    return defaultFileLocalization;
}

+(void) saveItemLocalizable:(ItemLocalizable *)itemLocalizable
                     toPath:(NSString *) toPath{
    NSError * error = nil;
    NSString * keyAndValue = [NSString stringWithFormat:@"\n\"%@\" = \"%@\";\n",itemLocalizable.key,itemLocalizable.value];
    NSString *contents = [NSString stringWithContentsOfFile:toPath
                                                   encoding:NSUTF8StringEncoding
                                                      error:&error];
    contents = [contents stringByAppendingString:keyAndValue];
    [contents writeToFile:toPath atomically:YES encoding: NSUTF8StringEncoding error:&error];
    if(error) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Default Localizable.strings file not found."];
        [alert setInformativeText:@"The default localizable file not found.Please create your default localizable file."];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert runModal];
        NSLog(@"ERROR while loading from file: %@", error);
        [NSException raise:@"Save item localizable fail" format:@"Save item localizable fail %@", error];
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
