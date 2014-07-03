#import "ItemLocalizable.h"

@implementation ItemLocalizable

-(id)initWithKey:(NSString *) key
        andValue:(NSString *) value{
    self = [super init];
    if (self) {
        self.value = value;
        self.key = key;
    }
    return self;
}

@end
