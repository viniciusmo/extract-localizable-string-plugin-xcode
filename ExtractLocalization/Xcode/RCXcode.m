#import "RCXcode.h"

@implementation RCXcode {}

#pragma mark - Helpers

+ (id)currentEditor {
    NSWindowController *currentWindowController = [[NSApp keyWindow] windowController];
    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        RCIDEWorkspaceWindowController *workspaceController = (RCIDEWorkspaceWindowController *)currentWindowController;
        RCIDEEditorArea *editorArea = [workspaceController editorArea];
        RCIDEEditorContext *editorContext = [editorArea lastActiveEditorContext];
        return [editorContext editor];
    }
    return nil;
}

+ (RCIDEWorkspaceDocument *)currentWorkspaceDocument {
    NSWindowController *currentWindowController = [[NSApp keyWindow] windowController];
    id document = [currentWindowController document];
    if (currentWindowController && [document isKindOfClass:NSClassFromString(@"IDEWorkspaceDocument")]) {
        return (RCIDEWorkspaceDocument *)document;
    }
    return nil;
}

+ (RCIDESourceCodeDocument *)currentSourceCodeDocument {
    if ([[RCXcode currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
        RCIDESourceCodeEditor *editor = [RCXcode currentEditor];
        return editor.sourceCodeDocument;
    }
    
    if ([[RCXcode currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeComparisonEditor")]) {
        RCIDESourceCodeComparisonEditor *editor = [RCXcode currentEditor];
        if ([[editor primaryDocument] isKindOfClass:NSClassFromString(@"IDESourceCodeDocument")]) {
            RCIDESourceCodeDocument *document = (RCIDESourceCodeDocument *)editor.primaryDocument;
            return document;
        }
    }
    
    return nil;
}

+ (NSTextView *)currentSourceCodeTextView {
    if ([[RCXcode currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
        RCIDESourceCodeEditor *editor = [RCXcode currentEditor];
        return editor.textView;
    }
    
    if ([[RCXcode currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeComparisonEditor")]) {
        RCIDESourceCodeComparisonEditor *editor = [RCXcode currentEditor];
        return editor.keyTextView;
    }
    
    return nil;
}

+ (NSArray *)selectedObjCFileNavigableItems {
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    id currentWindowController = [[NSApp keyWindow] windowController];
    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        RCIDEWorkspaceWindowController *workspaceController = currentWindowController;
        RCIDEWorkspaceTabController *workspaceTabController = [workspaceController activeWorkspaceTabController];
        RCIDENavigatorArea *navigatorArea = [workspaceTabController navigatorArea];
        id currentNavigator = [navigatorArea currentNavigator];
        
        if ([currentNavigator isKindOfClass:NSClassFromString(@"IDEStructureNavigator")]) {
            RCIDEStructureNavigator *structureNavigator = currentNavigator;
            for (id selectedObject in structureNavigator.selectedObjects) {
                if ([selectedObject isKindOfClass:NSClassFromString(@"IDEFileNavigableItem")]) {
                    RCIDEFileNavigableItem *fileNavigableItem = selectedObject;
                    NSString *uti = fileNavigableItem.documentType.identifier;
                    if ([uti isEqualToString:(NSString *)kUTTypeObjectiveCSource] || [uti isEqualToString:(NSString *)kUTTypeCHeader]) {
                        [mutableArray addObject:fileNavigableItem];
                    }
                }
            }
        }
    }
    
    if (mutableArray.count) {
        return [NSArray arrayWithArray:mutableArray];
    }
    return nil;
}

+ (NSArray *)containerFolderURLsForNavigableItem:(RCIDENavigableItem *)navigableItem {
    NSMutableArray *mArray = [NSMutableArray array];
    
    do {
        NSURL *folderURL = nil;
        id representedObject = navigableItem.representedObject;
        if ([navigableItem isKindOfClass:NSClassFromString(@"IDEGroupNavigableItem")]) {
            // IDE-GROUP (a folder in the navigator)
            RCIDEGroup *group = (RCIDEGroup *)representedObject;
            folderURL = group.resolvedFilePath.fileURL;
        } else if ([navigableItem isKindOfClass:NSClassFromString(@"IDEContainerFileReferenceNavigableItem")]) {
            // CONTAINER (an Xcode project)
            RCIDEFileReference *fileReference = representedObject;
            folderURL = [fileReference.resolvedFilePath.fileURL URLByDeletingLastPathComponent];
        } else if ([navigableItem isKindOfClass:NSClassFromString(@"IDEKeyDrivenNavigableItem")]) {
            RCIDEWorkspace *workspace = representedObject;
            folderURL = [workspace.representingFilePath.fileURL URLByDeletingLastPathComponent];
        }
        if (folderURL && ![mArray containsObject:folderURL]) [mArray addObject:folderURL];
        navigableItem = [navigableItem parentItem];
    } while (navigableItem != nil);
    
    if (mArray.count > 0) return [NSArray arrayWithArray:mArray];
    return nil;
}

@end
