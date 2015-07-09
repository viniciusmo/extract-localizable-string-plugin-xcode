#import "EditorLocalizable.h"
#import "FileHelper.h"
#import "Logger.h"
#import "ExtractLocalization.h"

static NSString *kKeysArray = @"keys";
static NSString *kValuesArray = @"values";
const static NSString * kEditorLocalizableFilePathLocalizable = @"kEditorLocalizableFilePathLocalizable";



@implementation EditorLocalizable

+(NSArray *) localizableFilePaths{
    NSString * defaultNameOfFileLocalizable = @"Localizable.strings";
    return [self findValidLocalizableFilesMatchingPath:defaultNameOfFileLocalizable];
}

+ (NSArray *)findValidLocalizableFilesMatchingPath:(NSString *)path {
    NSArray * localizableFilesFounded = [FileHelper recursivePathsForResourcesOfType:path
                                                                         inDirectory:[self getRootProjectPath]];
    
    NSMutableArray *projectLocalizableFiles = [NSMutableArray new];
    
    NSString *workspaceFilePath = [self getWorkSpacePathProject];
    
    for (NSString *localizableFilePath in localizableFilesFounded) {
        if (![localizableFilePath containsString:@".bundle"] && [localizableFilePath containsString:workspaceFilePath]) {
            [projectLocalizableFiles addObject:localizableFilePath];
        }
    }
    return projectLocalizableFiles;
}

+(NSString *) getWorkSpacePathProject{
    NSArray *workspaceWindowControllers = [NSClassFromString(@"IDEWorkspaceWindowController") valueForKey:@"workspaceWindowControllers"];
    id workSpace;
    for (id controller in workspaceWindowControllers) {
        //if ([[controller valueForKey:@"window"] isEqual:[NSApp keyWindow]]) {
            workSpace = [controller valueForKey:@"_workspace"];
        //}
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

+(NSString *) getDefaultLocalizableFilePath {
    NSString *defaultLanguageLocalizableFileName = [NSString stringWithFormat:@"%@/Localizable.strings",[self getDefaultLanguage]];
    NSArray *defaultLanguageLocalizableFilePaths = [self findValidLocalizableFilesMatchingPath:defaultLanguageLocalizableFileName];
    if (defaultLanguageLocalizableFilePaths.count > 0) {
        return [defaultLanguageLocalizableFilePaths objectAtIndex:0];
    }
    
    
    NSString *baseLanguageLocalizableFileName = @"Base.lproj/Localizable.strings";
    NSArray *baseLanguageLocalizableFilePaths = [self findValidLocalizableFilesMatchingPath:baseLanguageLocalizableFileName];
    if (baseLanguageLocalizableFilePaths.count > 0) {
        return [baseLanguageLocalizableFilePaths objectAtIndex:0];
    }
    
    NSArray *allLocalizableFilePaths = [self localizableFilePaths];
    if (allLocalizableFilePaths.count > 0) {
        return [allLocalizableFilePaths objectAtIndex:0];
    }
    
    return nil;
}

+(NSString *) getDefaultLanguage{
    NSString *workspacePath = [self getWorkSpacePathProject];
    NSString * nameProject = [self getCurrentNameProject];
    NSString * plistNameFile = nil;
    
    plistNameFile = [NSString stringWithFormat:@"%@/%@-Info.plist",workspacePath,nameProject];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistNameFile]) {
        plistNameFile = [NSString stringWithFormat:@"%@/Info.plist",workspacePath];
    }
    
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistNameFile];
    
    if (plistDict && [plistDict objectForKey:@"CFBundleDevelopmentRegion"]) {
        NSString * language = [NSString stringWithFormat:@"%@.lproj",[plistDict objectForKey:@"CFBundleDevelopmentRegion"]];
        [Logger info:@"Language %@",language];
        return language?:@"";
    }
    return @"";
}

+(NSString *) getCurrentNameProject{
    NSString * nameProjectWithExtenstion = [[[self getWorkSpacePathProject]
                                             componentsSeparatedByString:@"/"] lastObject];
    NSString * nameProject = [self removeStrings:nameProjectWithExtenstion
                       andArrayOfStringsToRemove:@[@".xcodeproj", @".xcworkspace"]];
    [Logger info:@"Name project %@",nameProject];
    return nameProject;
}

+ (void)doTreatmentError:(NSError *)error itemLocalizable:(ItemLocalizable *)itemLocalizable{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Default Localizable.strings file not found."];
    [alert setInformativeText:@"The default localizable file not found.Please create your default localizable file or choose"];
    [alert addButtonWithTitle:@"Choose localizable file"];
    [alert setAlertStyle:NSCriticalAlertStyle];
    NSInteger result =  [alert runModal];
    if (result == NSAlertSecondButtonReturn ) {
        NSString * file =  [self chooseFileLocalizableString];
        if (file != nil) {
            [self saveItemLocalizable:itemLocalizable toPath:file];
        }else{
            [NSException raise:@"Save item localizable fail" format:@"Save item localizable fail %@", error];
        }
    }
    if (result == NSAlertFirstButtonReturn ){
        [NSException raise:@"Save item localizable fail" format:@"Save item localizable fail %@", error];
    }
}

+(void) saveItemLocalizable:(ItemLocalizable *)itemLocalizable
                     toPath:(NSString *) toPath{
    NSError * error = nil;
    NSString * keyAndValue = [NSString stringWithFormat:@"\n\"%@\" = \"%@\"; // %@",itemLocalizable.key,itemLocalizable.value, itemLocalizable.comment];
    NSString *contents = [NSString stringWithContentsOfFile:toPath
                                                   encoding:NSUTF8StringEncoding
                                                      error:&error];
    contents = [contents stringByAppendingString:keyAndValue];
    [contents writeToFile:toPath atomically:YES encoding: NSUTF8StringEncoding error:&error];
    if(error) {
        [self doTreatmentError:error itemLocalizable:itemLocalizable];
    }
}


+(NSString *) chooseFileLocalizableString{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO]; // yes if more than one dir is allowed
    [panel setAllowedFileTypes:@[@"strings"]];
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        if ([[panel URLs] count] > 0) {
            NSURL * path  = [[panel URLs] objectAtIndex:0];
            NSString * filePath  = [[[path  filePathURL] description] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:filePath forKey:[kEditorLocalizableFilePathLocalizable copy]];
            [defaults synchronize];
            return filePath;
        }
    }
    return nil;
}

+(NSString * )removeStrings:(NSString *)string andArrayOfStringsToRemove:(NSArray *)stringsToRemove{
    for (NSString * toRemove  in stringsToRemove) {
        string = [string stringByReplacingOccurrencesOfString:toRemove
                                                   withString:@""];
    }
    return string;
}

+ (NSString *)getKeyForValue:(NSString *)value {
    NSString *localizableFilePath = [self getDefaultLocalizableFilePath];
    
    NSArray *keysArray = [[self getLocalizableKeyValueArraysFromFile:localizableFilePath] valueForKey:kKeysArray];
    NSArray *valuesArray = [[self getLocalizableKeyValueArraysFromFile:localizableFilePath] valueForKey:kValuesArray];
    
    return [keysArray objectAtIndex:[valuesArray indexOfObject:value]];
}

+ (BOOL)checkIfKeyExists:(NSString *)key {
    NSString *localizableFilePath = [self getDefaultLocalizableFilePath];
    
    NSArray *keysArray = [[self getLocalizableKeyValueArraysFromFile:localizableFilePath] valueForKey:kKeysArray];
    
    return [keysArray containsObject:key];
}

+ (BOOL)checkIfValueExists:(NSString *)value {
    NSString *localizableFilePath = [self getDefaultLocalizableFilePath];
    
    NSArray *valuesArray = [[self getLocalizableKeyValueArraysFromFile:localizableFilePath] valueForKey:kValuesArray];
    
    return [valuesArray containsObject:value];
}

+ (NSDictionary *)getLocalizableKeyValueArraysFromFile:(NSString *)localizableFilePath {
    NSString* localizableFileContent =[NSString stringWithContentsOfFile:localizableFilePath encoding:NSUTF8StringEncoding error:nil];
    NSString *localizableStringPattern = @"\"(.*)\"[ ]*=[ ]*\"(.*)\";";
    NSRegularExpression *localizableRegularExpression = [NSRegularExpression regularExpressionWithPattern:localizableStringPattern options:0 error:nil];
    
    NSMutableArray *localizableKeys = [NSMutableArray new];
    NSMutableArray *localizableValues = [NSMutableArray new];
    
    [localizableFileContent enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        NSRange matchRange = NSMakeRange(0, line.length);
        NSTextCheckingResult *match = [localizableRegularExpression firstMatchInString:line options:0 range:matchRange];
        
        NSString *key = [line substringWithRange:[match rangeAtIndex:1]];
        NSString *value = [line substringWithRange:[match rangeAtIndex:2]];
        
        if (key != nil && ![key isEqualToString:@""] && value != nil) {
            [localizableKeys addObject:key];
            [localizableValues addObject:value];
        }
    }];
    
    return @{kKeysArray:localizableKeys, kValuesArray:localizableValues};
}

@end
