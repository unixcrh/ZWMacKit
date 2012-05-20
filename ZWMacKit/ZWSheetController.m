#import "ZWSheetController.h"
#import "ZWSheet.h"

@interface ZWSheetInfo : NSObject

@property (assign) NSWindow *sheet;
@property (copy) void (^completionHandler)(NSInteger result);

+ (id)sheetInfoWithSheet:(NSWindow *)pSheet completionHandler:(void (^)(NSInteger result))pCompletionHandler;
- (id)initWithSheet:(NSWindow *)pSheet completionHandler:(void (^)(NSInteger result))pCompletionHandler;

@end
@implementation ZWSheetInfo

@synthesize sheet;
@synthesize completionHandler;

+ (id)sheetInfoWithSheet:(NSWindow *)pSheet completionHandler:(void (^)(NSInteger result))pCompletionHandler {
	return [[self alloc] initWithSheet:pSheet completionHandler:pCompletionHandler];
}
- (id)initWithSheet:(NSWindow *)pSheet completionHandler:(void (^)(NSInteger result))pCompletionHandler {
	if((self = [super init])) {
		self.sheet = pSheet;
		self.completionHandler = pCompletionHandler;
	}
	return self;
}

@end


@interface ZWSheetController() {
}

@property (assign) NSWindow *window;
@property (assign) dispatch_queue_t queue;
@property (assign) NSMapTable *sheets;

+ (NSMapTable *)controllers;
+ (ZWSheetController *)controllerForWindow:(NSWindow *)pWindow;
- (id)initWithWindow:(NSWindow *)pWindow;
- (void)windowWillClose:(NSNotification *)pNotification;
- (void)sheetDidEnd:(id)pSheet returnCode:(NSInteger)pReturnCode contextInfo:(void *)pContextInfo;

@end
@implementation ZWSheetController

#pragma mark - Properties

@synthesize window;
@synthesize queue;
@synthesize sheets;

+ (NSMapTable *)controllers {
	static dispatch_once_t controllersOnce;
	static NSMapTable *controllers = nil;
	dispatch_once(&controllersOnce, ^{
		controllers = [NSMapTable mapTableWithStrongToStrongObjects];
	});
	return controllers;
}
+ (ZWSheetController *)controllerForWindow:(NSWindow *)pWindow {
	if(pWindow == nil) {
		return nil;
	}
	ZWSheetController *controller = [[self controllers] objectForKey:pWindow];
	if(controller == nil) {
		controller = [[self alloc] initWithWindow:pWindow];
		[[self controllers] setObject:controller forKey:pWindow];
	}
	return controller;
}
- (id)initWithWindow:(NSWindow *)pWindow {
	if((self = [super init])) {
		self.window = pWindow;
		self.queue = dispatch_queue_create(nil, nil);
		self.sheets = [NSMapTable mapTableWithStrongToStrongObjects];
		
		// close
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:self.window];
	}
	return self;
}
- (void)windowWillClose:(NSNotification *)pNotification {
	[[ZWSheetController controllers] removeObjectForKey:self.window];
}
- (void)sheetDidEnd:(id)pSheet returnCode:(NSInteger)pReturnCode contextInfo:(void *)pContextInfo {
	if(pContextInfo != nil) {
		ZWSheetInfo *sheetInfo = (__bridge ZWSheetInfo *)pContextInfo;
		if(sheetInfo.completionHandler != nil) {
			dispatch_async(dispatch_get_main_queue(), ^{
				sheetInfo.completionHandler(pReturnCode);
			});
		}
	}
	[self.sheets removeObjectForKey:pSheet];
}

#pragma mark - Actions

+ (void)queueSheet:(id)pSheet modalForWindow:(NSWindow *)pWindow completionHandler:(void (^)(NSInteger result))pCompletionHandler {
	if(pSheet == nil || pWindow == nil) {
		return;
	}
	ZWSheetInfo *sheetInfo = [ZWSheetInfo sheetInfoWithSheet:pSheet completionHandler:pCompletionHandler];
	ZWSheetController *controller = [self controllerForWindow:pWindow];
	[controller.sheets setObject:sheetInfo forKey:pSheet];
	
	SEL didEndSelector = @selector(sheetDidEnd:returnCode:contextInfo:);
	void *contextInfo = (__bridge void *)sheetInfo;
	
	// NSAlert
	if([pSheet isKindOfClass:[NSAlert class]]) {
		NSAlert *alert = pSheet;
		[alert beginSheetModalForWindow:controller.window modalDelegate:controller didEndSelector:didEndSelector contextInfo:contextInfo];
	}
	// ZWSheet
	else if([pSheet isKindOfClass:[ZWSheet class]]) {
		ZWSheet *sheet = pSheet;
		[NSApp beginSheet:[sheet window] modalForWindow:controller.window modalDelegate:controller didEndSelector:didEndSelector contextInfo:contextInfo];
	}
	// NSPanel
	else if([pSheet isKindOfClass:[NSPanel class]] && [pSheet respondsToSelector:@selector(beginSheetModalForWindow:completionHandler:)]) {
		[(id)pSheet beginSheetModalForWindow:pWindow completionHandler:^(NSInteger result) {
			[controller sheetDidEnd:pSheet returnCode:result contextInfo:contextInfo];
		}];
	}
	// NSWindow
	else if([pSheet isKindOfClass:[NSWindow class]]) {
		[NSApp beginSheet:pSheet modalForWindow:controller.window modalDelegate:controller didEndSelector:didEndSelector contextInfo:contextInfo];
	}
}

#pragma mark - Finalize

- (void)dealloc {
	window = nil;
	if(self.queue != nil) {
		dispatch_release(self.queue);
		self.queue = nil;
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
