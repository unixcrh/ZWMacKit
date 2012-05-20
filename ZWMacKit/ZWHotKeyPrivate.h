#import "ZWHotKey.h"
#import <Carbon/Carbon.h>

typedef struct {
	unsigned int identifier;
	int keyCode;
	CFStringRef hash;
	unsigned int modifierFlags;
	EventHotKeyRef ref;
	int retainCount;
} ZWHotKeyEvent;
typedef ZWHotKeyEvent* ZWHotKeyEventRef;

NSMapTable* ZWHotKeyEventMapTable(void);
ZWHotKeyEventRef ZWHotKeyEventGetExistingForKeyCode(int keyCode, unsigned int modifierFlags);
ZWHotKeyEventRef ZWHotKeyEventCreate(int keyCode, unsigned int modifierFlags);
ZWHotKeyEventRef ZWHotKeyEventRetain(ZWHotKeyEventRef hotKeyEvent);
void ZWHotKeyEventRelease(ZWHotKeyEventRef hotKeyEvent);
NSMutableArray* ZWHotKeyMonitorArray(void);
void ZWHotKeyMonitorResume(ZWHotKey *hotKey);
void ZWHotKeyMonitorStop(ZWHotKey *hotKey);
OSStatus _ZWHotKeyApplicationHandler(EventHandlerCallRef eventHandlerCall, EventRef event, void* userInfo);