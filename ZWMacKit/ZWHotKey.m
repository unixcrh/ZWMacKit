#import "ZWHotKey.h"
#import "ZWHotKeyPrivate.h"
#import <Carbon/Carbon.h>

#pragma mark - Helpers

static inline unsigned int _translateModifierFlagsToCarbon(unsigned int modifierFlags) {
	unsigned int newFlags = 0;
	if((modifierFlags & NSControlKeyMask) > 0) { 
		newFlags |= controlKey;
	}
	if((modifierFlags & NSCommandKeyMask) > 0) { 
		newFlags |= cmdKey; 
	}
	if((modifierFlags & NSShiftKeyMask) > 0) { 
		newFlags |= shiftKey; 
	}
	if((modifierFlags & NSAlternateKeyMask) > 0) { 
		newFlags |= optionKey; 
	}
	return newFlags;
}
static inline unsigned int _translateModifierFlagsToCococa(unsigned int modifierFlags) {
	unsigned int newFlags = 0;
	if((modifierFlags & controlKey) > 0) { 
		newFlags |= NSControlKeyMask;
	}
	if((modifierFlags & cmdKey) > 0) { 
		newFlags |= NSCommandKeyMask; 
	}
	if((modifierFlags & shiftKey) > 0) { 
		newFlags |= NSShiftKeyMask; 
	}
	if((modifierFlags & optionKey) > 0) { 
		newFlags |= NSAlternateKeyMask; 
	}
	return newFlags;
}
static inline CFStringRef _hashForKeyCodeAndModifierFlags(int keyCode, unsigned int modifierFlags) {
	return (__bridge CFStringRef)[NSString stringWithFormat:@"%u%i", keyCode, modifierFlags];
}

#pragma mark - ZWHotKeyEvent

NSMapTable* ZWHotKeyEventMapTable(void) {
	static NSMapTable *_zwHotKeyEventMapTable = nil;
	static dispatch_once_t _zwHotKeyEventMapTableOnce;
	dispatch_once(&_zwHotKeyEventMapTableOnce, ^{
		_zwHotKeyEventMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory
													   valueOptions:NSMapTableObjectPointerPersonality];
	});
	return _zwHotKeyEventMapTable;
}
ZWHotKeyEventRef ZWHotKeyEventGetExistingForKeyCode(int keyCode, unsigned int modifierFlags) {
	ZWHotKeyEventRef r = NSMapGet(ZWHotKeyEventMapTable(), _hashForKeyCodeAndModifierFlags(keyCode, modifierFlags));
	if(r != nil) {
		return r;
	}
	return nil;
}

ZWHotKeyEventRef ZWHotKeyEventCreate(int keyCode, unsigned int modifierFlags) {
	static unsigned int _nextIdentifier = 0;
	EventHotKeyID eventHotKeyIdentifier;
	eventHotKeyIdentifier.signature = 'htk1';
	eventHotKeyIdentifier.id = _nextIdentifier++;
	EventHotKeyRef ref;
	OSStatus error = RegisterEventHotKey(keyCode,
										 _translateModifierFlagsToCarbon(modifierFlags),
										 eventHotKeyIdentifier,
										 GetEventDispatcherTarget(),
										 0,
										 &ref);
	if(error != 0) {
		fprintf(stderr, "ZWHotKeyEventCreate fatal error.");
		abort();
	}
	
	ZWHotKeyEventRef r = (ZWHotKeyEventRef)malloc(sizeof(ZWHotKeyEvent));
	r->keyCode = keyCode;
	r->modifierFlags = modifierFlags;
	r->hash = _hashForKeyCodeAndModifierFlags(keyCode, modifierFlags);
	r->identifier = eventHotKeyIdentifier.id;
	r->retainCount = 1;
	r->ref = ref;
	
	NSMapInsert(ZWHotKeyEventMapTable(), r->hash, r);
	
	return r;
};
ZWHotKeyEventRef ZWHotKeyEventRetain(ZWHotKeyEventRef hotKeyEvent) {
	if(hotKeyEvent != nil) {
		hotKeyEvent->retainCount++;
	}
	return hotKeyEvent;
};
void ZWHotKeyEventRelease(ZWHotKeyEventRef hotKeyEvent) {
	if(hotKeyEvent != nil) {
		hotKeyEvent->retainCount--;
		if(hotKeyEvent->retainCount <= 0) {
			UnregisterEventHotKey(hotKeyEvent->ref);
			NSMapRemove(ZWHotKeyEventMapTable(), hotKeyEvent->hash);
			free(hotKeyEvent);
		}
	}
};

@interface ZWHotKey() {
	unsigned int identifier;
	int keyCode;
	unsigned int modifierFlags;
	ZWHotKeyHandler handler;
}

#pragma mark - Properties

@property (assign) unsigned int identifier;
@property (readonly) NSString *hash;

@end

#pragma mark - Hot Key Monitor

NSMutableArray* ZWHotKeyMonitorArray(void) {
	static NSMutableArray *_zwHotKeyMonitorArray = nil;
	static dispatch_once_t _zwHotKeyMonitorArrayOnce;
	dispatch_once(&_zwHotKeyMonitorArrayOnce, ^{
		_zwHotKeyMonitorArray = [NSMutableArray array];
	});
	return _zwHotKeyMonitorArray;
}
void ZWHotKeyMonitorResume(ZWHotKey *hotKey) {
	if(![ZWHotKeyMonitorArray() containsObject:hotKey]) {
		[ZWHotKeyMonitorArray() addObject:hotKey];
		ZWHotKeyEventRef hotKeyEvent = ZWHotKeyEventRetain(ZWHotKeyEventGetExistingForKeyCode(hotKey.keyCode, hotKey.modifierFlags));
		if(hotKeyEvent == nil) {
			hotKeyEvent = ZWHotKeyEventCreate(hotKey.keyCode, hotKey.modifierFlags);
		}
		hotKey.identifier = hotKeyEvent->identifier;
	}
}
void ZWHotKeyMonitorStop(ZWHotKey *hotKey) {
	if([ZWHotKeyMonitorArray() containsObject:hotKey]) {
		ZWHotKeyEventRelease(ZWHotKeyEventGetExistingForKeyCode(hotKey.keyCode, hotKey.modifierFlags));
		hotKey.identifier = INT_MAX;
		[ZWHotKeyMonitorArray() removeObject:hotKey];
	}
}

#pragma mark - Application Handler

OSStatus _ZWHotKeyApplicationHandler(EventHandlerCallRef eventHandlerCall, EventRef event, void* userInfo) {
	@autoreleasepool {
	
		EventHotKeyID eventHotKeyIdentifier;
		GetEventParameter(event, kEventParamDirectObject, typeEventHotKeyID, nil, sizeof(eventHotKeyIdentifier), nil, &eventHotKeyIdentifier);
		NSArray *hotKeys = [[ZWHotKeyMonitorArray() copy] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL (id object, NSDictionary *bindings) {
			if([object isKindOfClass:[ZWHotKey class]]) {
				ZWHotKey *hotKey = object;
				return (hotKey.identifier == eventHotKeyIdentifier.id);
			}
			return NO;
		}]];
		
		// lets handle the event if we have hot keys
		if([hotKeys count] > 0) {
			// setup some vars
			BOOL dequeue = NO;
			ZWHotKey *hotKey = [hotKeys objectAtIndex:0];
			
			// convert EventRef -> NSEvent
			NSEvent *handleEvent = [NSEvent eventWithEventRef:event];
			handleEvent = [NSEvent keyEventWithType:NSKeyDown
										   location:[handleEvent locationInWindow]
									  modifierFlags:[handleEvent modifierFlags]
										  timestamp:[handleEvent timestamp]
									   windowNumber:-1
											context:nil
										 characters:@""
						charactersIgnoringModifiers:@""
										  isARepeat:NO
											keyCode:[hotKey keyCode]];
			
			// enumerate hot keys
			for(hotKey in hotKeys) {
				if(hotKey.handler != nil) {
					hotKey.handler(hotKey, handleEvent, &dequeue);
					
					// do we dequeue
					if(dequeue) {
						break;
					}
				}
			}
		}
		
		return noErr;
	}
}

@implementation ZWHotKey

#pragma mark - Properties

@synthesize identifier;
@synthesize keyCode;
@synthesize modifierFlags;
@synthesize handler;
@dynamic hash;

- (NSString *)hash {
	return [NSString stringWithFormat:@"%u %i", self.keyCode, self.modifierFlags];
}

#pragma mark - Initialization

+ (ZWHotKey *)hotKeyWithKeyCode:(int)pKeyCode modifierFlags:(unsigned int)pModifierFlags {
	return [[self alloc] initWithKeyCode:pKeyCode modifierFlags:pModifierFlags];
}
- (id)initWithKeyCode:(int)pKeyCode modifierFlags:(unsigned int)pModifierFlags {
	if((self = [super init])) {
		identifier = INT_MAX;
		keyCode = pKeyCode;
		modifierFlags = pModifierFlags;
		
		// install application handler and create monitored hot keys set
		static dispatch_once_t once;
		dispatch_once(&once, ^{
			EventTypeSpec eventSpec;
			eventSpec.eventClass = kEventClassKeyboard;
			eventSpec.eventKind = kEventHotKeyReleased;
			InstallApplicationEventHandler(&_ZWHotKeyApplicationHandler, 1, &eventSpec, NULL, NULL);
		});
	}
	return self;
}

#pragma mark - Actions

- (void)resumeMonitoring {
	ZWHotKeyMonitorResume(self);
}
- (void)stopMonitoring {
	ZWHotKeyMonitorStop(self);
}

@end
