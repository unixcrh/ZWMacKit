#import <Cocoa/Cocoa.h>
@class ZWHotKey;


typedef void (^ZWHotKeyHandler)(ZWHotKey *hotKey, NSEvent *event, BOOL *dequeue);

@interface ZWHotKey : NSObject {
}

#pragma mark - Properties

@property (nonatomic, readonly) int keyCode;
@property (nonatomic, readonly) unsigned int modifierFlags;
@property (nonatomic, copy) ZWHotKeyHandler handler;

#pragma mark - Initialization

+ (ZWHotKey *)hotKeyWithKeyCode:(int)pKeyCode modifierFlags:(unsigned int)pModifierFlags;
- (id)initWithKeyCode:(int)pKeyCode modifierFlags:(unsigned int)pModifierFlags;

#pragma mark - Actions

- (void)resumeMonitoring;
- (void)stopMonitoring;

@end
