#import <UIKit/UIKit.h>
#import <QMUIKit/QMUIKit.h>

// Mimic FlutterSecureTextInputView's UITextField identity without its storage.
@interface MasqueradingInputView : UIView
@property(nonatomic) NSUInteger textContainerReads;
@end

@implementation MasqueradingInputView
- (BOOL)isKindOfClass:(Class)aClass {
    return aClass == UITextField.class || [super isKindOfClass:aClass];
}
- (BOOL)qmui_themePropertiesShouldBeCalled { return YES; }
- (id)valueForKey:(NSString *)key {
    if ([key isEqualToString:@"textContainer"]) {
        self.textContainerReads++;
        [NSException raise:NSUndefinedKeyException format:@"Unexpected textContainer access"];
    }
    return [super valueForKey:key];
}
@end

@interface SupportedInputView : MasqueradingInputView
@end

@implementation SupportedInputView
- (NSTextContainer *)textContainer {
    self.textContainerReads++;
    return [[NSTextContainer alloc] initWithSize:CGSizeMake(100, 100)];
}
- (id)valueForKey:(NSString *)key {
    return [key isEqualToString:@"textContainer"] ? self.textContainer : [super valueForKey:key];
}
@end

int main(void) {
    @autoreleasepool {
        MasqueradingInputView *unsupported = [MasqueradingInputView new];
        NSCAssert([unsupported isKindOfClass:UITextField.class], @"Must exercise UITextField branch");
        NSCAssert(![unsupported qmui_canGetValueForKey:@"textContainer"], @"Missing property");
        [unsupported qmui_themeDidChangeByManager:nil identifier:nil theme:nil];
        NSCAssert(unsupported.textContainerReads == 0, @"Must not read missing property");

        SupportedInputView *supported = [SupportedInputView new];
        NSCAssert([supported qmui_canGetValueForKey:@"textContainer"], @"Readable property");
        [supported qmui_themeDidChangeByManager:nil identifier:nil theme:nil];
        NSCAssert(supported.textContainerReads > 0, @"Keep existing TextKit refresh path");
        NSLog(@"PASS: missing KVC property skipped; supported property still refreshed");
    }
    return 0;
}
