#import <Foundation/Foundation.h>

@interface ItemLocalizable : NSObject

@property (strong) NSString * key;
@property (strong) NSString * value;
@property (strong) NSString * comment;

-(id)initWithKey:(NSString *) key
        andValue:(NSString *) value
        andComment:(NSString *) comment;

@end
