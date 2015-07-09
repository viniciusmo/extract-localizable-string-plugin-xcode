#import "ItemLocalizable.h"

@implementation ItemLocalizable

-(id)initWithKey:(NSString *) key
        andValue:(NSString *) value
      andComment:(NSString *) comment{
    self = [super init];
    if (self) {
        self.value = value;
        self.key = key;
        self.comment = comment;
    }
    return self;
}

@end
