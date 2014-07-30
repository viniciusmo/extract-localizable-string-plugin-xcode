#import "EditorLocalizable.h"
#import "FileHelper.h"
#import "Logger.h"

@implementation EditorLocalizable

+(NSString *) defaultPathLocalizablePath{
    NSString * defaultNameOfFileLocalizable = [self getCurrentDefaultNameOfFileLocalizable];
    NSArray * filesFounded = [FileHelper recursivePathsForResourcesOfType:defaultNameOfFileLocalizable
                                                              inDirectory:[self getRootProjectPath]];
    NSString * language = [self getDefaultLanguage];
    NSString * defaultFileLocalization  = nil;
    if ([filesFounded count] > 0) {
        defaultFileLocalization = [filesFounded objectAtIndex:0];
        defaultFileLocalization = [defaultFileLocalization
                                   stringByReplacingOccurrencesOfString:language
                                   withString:[NSString stringWithFormat:@"/%@",language]];
    }
    [Logger info:@"Default localizable path %@",defaultFileLocalization];
    return defaultFileLocalization;
}

+(NSString *) getWorkSpacePathProject{
    NSArray *workspaceWindowControllers = [NSClassFromString(@"IDEWorkspaceWindowController") valueForKey:@"workspaceWindowControllers"];
    id workSpace;
    for (id controller in workspaceWindowControllers) {
        if ([[controller valueForKey:@"window"] isEqual:[NSApp keyWindow]]) {
            workSpace = [controller valueForKey:@"_workspace"];
        }
    }
    NSString *workspacePath = [[workSpace valueForKey:@"representingFilePath"] valueForKey:@"_pathString"];
    workspacePath = [self removeStrings:workspacePath andArrayOfStringsToRemove:@[@".xcodeproj", @".xcworkspace"]];
    [Logger info:@"Workspace path %@",workspacePath];
    return workspacePath;
}

+(NSString *) getRootProjectPath{
    NSString * workSpace = [self getWorkSpacePathProject];
    NSArray * workSpaceSplit = [workSpace componentsSeparatedByString:@"/"];
    NSMutableString * rootProjectPath = [[NSMutableString alloc] init];
    for (int i = 0; i < [workSpaceSplit count] -1; i++) {
        [rootProjectPath appendFormat:@"%@/",[workSpaceSplit objectAtIndex:i]];
    }
    [Logger info:@"Root project path %@",rootProjectPath];
    return rootProjectPath;
}

+(NSString *) getCurrentDefaultNameOfFileLocalizable{
    return [NSString stringWithFormat:@"%@/Localizable.strings",[self getDefaultLanguage]];
}

+(NSString *) getDefaultLanguage{
    NSString *workspacePath = [self getWorkSpacePathProject];
    NSString * nameProject = [self getCurrentNameProject];
    NSString * plistNameFile = [NSString stringWithFormat:@"%@/%@-Info.plist",workspacePath,nameProject];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistNameFile];
    NSString * language = [NSString stringWithFormat:@"%@.lproj",[plistDict objectForKey:@"CFBundleDevelopmentRegion"]];
    [Logger info:@"Language %@",language];
    return language;
}

+(NSString *) getCurrentNameProject{
    NSString * nameProjectWithExtenstion = [[[self getWorkSpacePathProject]
                                             componentsSeparatedByString:@"/"] lastObject];
    NSString * nameProject = [self removeStrings:nameProjectWithExtenstion
                       andArrayOfStringsToRemove:@[@".xcodeproj", @".xcworkspace"]];
    [Logger info:@"Name project %@",nameProject];
    return nameProject;
}

+(void) saveItemLocalizable:(ItemLocalizable *)itemLocalizable
                     toPath:(NSString *) toPath{
    NSError * error = nil;
    NSString * keyAndValue = [NSString stringWithFormat:@"\n\"%@\" = \"%@\";",itemLocalizable.key,itemLocalizable.value];
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
