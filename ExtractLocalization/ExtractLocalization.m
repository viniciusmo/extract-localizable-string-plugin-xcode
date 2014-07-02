#import "ExtractLocalization.h"
#import "RCXcode.h"
#import "ExtractLocalizationWindowController.h"

static NSString *localizeRegexs[] = {
    @"NSLocalizedString\\s*\\(\\s*@\"(.*)\"\\s*,\\s*(.*)\\s*\\)",
    @"localizedStringForKey:\\s*@\"(.*)\"\\s*value:\\s*(.*)\\s*table:\\s*(.*)",
    @"NSLocalizedStringFromTable\\s*\\(\\s*@\"(.*)\"\\s*,\\s*(.*)\\s*,\\s*(.*)\\s*\\)",
    @"NSLocalizedStringFromTableInBundle\\s*\\(\\s*@\"(.*)\"\\s*,\\s*(.*)\\s*,\\s*(.*)\\s*,\\s*(.*)\\s*\\)",
    @"NSLocalizedStringWithDefaultValue\\s*\\(\\s*@\"(.*)\"\\s*,\\s*(.*)\\s*,\\s*(.*)\\s*,\\s*(.*)\\s*,\\s*(.*)\\s*\\)"
};

static NSString *stringRegexs = @"@\"[^\"]*\"";


@implementation ExtractLocalization

static id sharedPlugin = nil;

+(void)pluginDidLoad:(NSBundle *)plugin {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlugin = [[self alloc]initWithBundle:plugin];
    });
}

-(id)initWithBundle:(NSBundle *)bundle{
    if (self = [super init]) {
        NSMenuItem *editMenu = [[NSApp mainMenu] itemWithTitle:NSLocalizedString(@"Edit", @"Edit")];
        if (editMenu) {
            NSMenuItem *refactorMenu = [[editMenu submenu] itemWithTitle:NSLocalizedString(@"Refactor", @"Refactor")];
            NSMenuItem *extractLocalizationStringMenu = [[NSMenuItem alloc] initWithTitle:@"Extract Localization String" action:@selector(extractLocalization) keyEquivalent:@"e"];
            [extractLocalizationStringMenu setKeyEquivalentModifierMask:NSShiftKeyMask | NSAlternateKeyMask];
            [extractLocalizationStringMenu setTarget:self];
            [[refactorMenu submenu]addItem:extractLocalizationStringMenu];
        }
    }
    return self;
}

// Sample Action, for menu item:
- (void)extractLocalization {
    IDESourceCodeDocument *document = [RCXcode currentSourceCodeDocument];
    NSTextView *textView = [RCXcode currentSourceCodeTextView];
    if (!document || !textView) {
        return;
    }
    
    NSArray *selectedRanges = [textView selectedRanges];
    if ([selectedRanges count] > 0) {
        NSRange range = [[selectedRanges objectAtIndex:0] rangeValue];
        NSRange lineRange = [textView.textStorage.string lineRangeForRange:range];
        NSString *line = [textView.textStorage.string substringWithRange:lineRange];
        
        NSRegularExpression *localizedRex = [[NSRegularExpression alloc] initWithPattern:localizeRegexs[0] options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *localizedMatches = [localizedRex matchesInString:line options:0 range:NSMakeRange(0, [line length])];
        
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:stringRegexs options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matches = [regex matchesInString:line options:0 range:NSMakeRange(0, [line length])];
        NSUInteger addedLength = 0;
        for (int i = 0; i < [matches count]; i++) {
            NSTextCheckingResult *result = [matches objectAtIndex:i];
            NSRange matchedRangeInLine = result.range;
            NSRange matchedRangeInDocument = NSMakeRange(lineRange.location + matchedRangeInLine.location + addedLength, matchedRangeInLine.length);
            if ([self isRange:matchedRangeInLine inSkipedRanges:localizedMatches]) {
                continue;
            }
            NSString *string = [line substringWithRange:matchedRangeInLine];
            NSString *outputString = [NSString stringWithFormat:@"NSLocalizedString(%@, %@)", string, string];
            addedLength = addedLength + outputString.length - string.length;
            if ([textView shouldChangeTextInRange:matchedRangeInDocument replacementString:outputString]) {
                [textView.textStorage replaceCharactersInRange:matchedRangeInDocument
                                          withAttributedString:[[NSAttributedString alloc] initWithString:outputString]];
                [textView didChangeText];
            }
        }
    }
    _extractLocationWindowController =  [[ExtractLocalizationWindowController alloc]initWithWindowNibName:@"ExtractLocalizationWindowController"];
    [_extractLocationWindowController showWindow:nil];
}

- (BOOL)isRange:(NSRange)range inSkipedRanges:(NSArray *)ranges {
    for (int i = 0; i < [ranges count]; i++) {
        NSTextCheckingResult *result = [ranges objectAtIndex:i];
        NSRange skippedRange = result.range;
        if (skippedRange.location <= range.location && skippedRange.location + skippedRange.length > range.location + range.length) {
            return YES;
        }
    }
    return NO;
}

@end
