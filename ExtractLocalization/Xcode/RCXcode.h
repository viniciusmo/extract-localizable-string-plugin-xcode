#import <Cocoa/Cocoa.h>

@interface RCDVTTextDocumentLocation : NSObject
@property (readonly) NSRange characterRange;
@property (readonly) NSRange lineRange;
@end

@interface RCDVTTextPreferences : NSObject
+ (id)preferences;
@property BOOL trimWhitespaceOnlyLines;
@property BOOL trimTrailingWhitespace;
@property BOOL useSyntaxAwareIndenting;
@end

@interface RCDVTSourceTextStorage : NSTextStorage
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)string withUndoManager:(id)undoManager;
- (NSRange)lineRangeForCharacterRange:(NSRange)range;
- (NSRange)characterRangeForLineRange:(NSRange)range;
- (void)indentCharacterRange:(NSRange)range undoManager:(id)undoManager;
@end

@interface RCDVTFileDataType : NSObject
@property (readonly) NSString *identifier;
@end

@interface RCDVTFilePath : NSObject
@property (readonly) NSURL *fileURL;
@property (readonly) RCDVTFileDataType *fileDataTypePresumed;
@end

@interface RCIDEContainerItem : NSObject
@property (readonly) RCDVTFilePath *resolvedFilePath;
@end

@interface RCIDEGroup : RCIDEContainerItem

@end

@interface RCIDEFileReference : RCIDEContainerItem

@end

@interface RCIDENavigableItem : NSObject
@property (readonly) RCIDENavigableItem *parentItem;
@property (readonly) id representedObject;
@end

@interface RCIDEFileNavigableItem : RCIDENavigableItem
@property (readonly) RCDVTFileDataType *documentType;
@property (readonly) NSURL *fileURL;
@end

@interface RCIDEStructureNavigator : NSObject
@property (retain) NSArray *selectedObjects;
@end

@interface RCIDENavigableItemCoordinator : NSObject
- (id)structureNavigableItemForDocumentURL:(id)arg1 inWorkspace:(id)arg2 error:(id *)arg3;
@end

@interface RCIDENavigatorArea : NSObject
- (id)currentNavigator;
@end

@interface RCIDEWorkspaceTabController : NSObject
@property (readonly) RCIDENavigatorArea *navigatorArea;
@end

@interface RCIDEDocumentController : NSDocumentController
+ (id)editorDocumentForNavigableItem:(id)arg1;
+ (id)retainedEditorDocumentForNavigableItem:(id)arg1 error:(id *)arg2;
+ (void)releaseEditorDocument:(id)arg1;
@end

@interface RCIDESourceCodeDocument : NSDocument
- (RCDVTSourceTextStorage *)textStorage;
- (NSUndoManager *)undoManager;
@end

@interface RCIDESourceCodeComparisonEditor : NSObject
@property (readonly) NSTextView *keyTextView;
@property (retain) NSDocument *primaryDocument;
@end

@interface RCIDESourceCodeEditor : NSObject
@property (retain) NSTextView *textView;
- (RCIDESourceCodeDocument *)sourceCodeDocument;
@end

@interface RCIDEEditorContext : NSObject
- (id)editor;
@end

@interface RCIDEEditorArea : NSObject
- (RCIDEEditorContext *)lastActiveEditorContext;
@end

@interface RCIDEWorkspaceWindowController : NSObject
@property (readonly) RCIDEWorkspaceTabController *activeWorkspaceTabController;
- (RCIDEEditorArea *)editorArea;
@end

@interface RCIDEWorkspace : NSObject
@property (readonly) RCDVTFilePath *representingFilePath;
@end

@interface RCIDEWorkspaceDocument : NSDocument
@property (readonly) RCIDEWorkspace *workspace;
@end

@interface RCXcode : NSObject
+ (RCIDEWorkspaceDocument *)currentWorkspaceDocument;
+ (RCIDESourceCodeDocument *)currentSourceCodeDocument;
+ (NSTextView *)currentSourceCodeTextView;
+ (NSArray *)selectedObjCFileNavigableItems;
@end
