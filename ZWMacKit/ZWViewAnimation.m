#import "ZWViewAnimation.h"
#import <ZWCoreKit/ZWEasingEquations.h>

static NSString *ZWViewAnimationRunLoopMode = @"ZWViewAnimationRunLoopMode";

@interface ZWViewAnimationObject : NSObject {
@public
	NSView *view;
	NSRect startFrame;
	NSRect endFrame;
	NSRect deltaFrame;
}
+ (id)animationObjectWithViewAnimationDictionary:(NSDictionary *)pDictionary;
- (id)initWithViewAnimationDictionary:(NSDictionary *)pDictionary;
@end
@implementation ZWViewAnimationObject
+ (id)animationObjectWithViewAnimationDictionary:(NSDictionary *)pDictionary {
	return [[self alloc] initWithViewAnimationDictionary:pDictionary];
}
- (id)initWithViewAnimationDictionary:(NSDictionary *)pDictionary {
	if((self = [super init])) {
		view = [pDictionary objectForKey:NSViewAnimationTargetKey];
		NSValue *startFrameValue = [pDictionary objectForKey:NSViewAnimationStartFrameKey];
		if(startFrameValue != nil) {
			startFrame = [startFrameValue rectValue];
		} else {
			startFrame = [view frame];
		}
		NSValue *endFrameValue = [pDictionary objectForKey:NSViewAnimationEndFrameKey];
		if(endFrameValue != nil) {
			endFrame = [endFrameValue rectValue];
		} else {
			endFrame = startFrame;
		}
		deltaFrame.origin.x = endFrame.origin.x - startFrame.origin.x;
		deltaFrame.origin.y = endFrame.origin.y - startFrame.origin.y;
		deltaFrame.size.width = endFrame.size.width - startFrame.size.width;
		deltaFrame.size.height = endFrame.size.height - startFrame.size.height;
	}
	return self;
}
@end

@interface ZWViewAnimation() {
	NSTimeInterval duration;
	NSTimeInterval startTime;
	BOOL animating;
	NSArray *animationObjects;
}

@property (assign) NSTimer *timer;

- (void)setCurrentProgressAndEndIfNeeded:(NSAnimationProgress)pProgress;
- (void)timer:(NSTimer *)pTimer;

@end
@implementation ZWViewAnimation

#pragma mark - Properties

@synthesize timer;

#pragma mark - Initialization

+ (id)animationWithViewAnimations:(NSArray *)pViewAnimations {
	return [[self alloc] initWithViewAnimations:pViewAnimations];
}
- (id)initWithViewAnimations:(NSArray *)pViewAnimations {
	if((self = [super init])) {
		NSMutableArray *tempAnimationObjects = [NSMutableArray array];
		for(NSDictionary *viewAnimation in pViewAnimations) {
			[tempAnimationObjects addObject:[ZWViewAnimationObject animationObjectWithViewAnimationDictionary:viewAnimation]];
		}
		animationObjects = tempAnimationObjects;
		[self setDuration:0.25];
		[self setFrameRate:60.0];
	}
	return self;
}

#pragma mark - NSAnimation

- (void)startAnimation {
	if(!animating) {
		if([self animationBlockingMode] == NSAnimationBlocking) {
			if([[self delegate] respondsToSelector:@selector(animationShouldStart:)]) {
				if(![[self delegate] animationShouldStart:self]) {
					return;
				}
			}
			animating = YES;
			startTime = [NSDate timeIntervalSinceReferenceDate];
			duration = [self duration];
			self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / [self frameRate]
														  target:self
														selector:@selector(timer:)
														userInfo:nil
														 repeats:YES];
			[[NSRunLoop currentRunLoop] addTimer:self.timer forMode:ZWViewAnimationRunLoopMode];
			while(animating) {
				[[NSRunLoop currentRunLoop] runMode:ZWViewAnimationRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:duration]];
			}
			[self setCurrentProgressAndEndIfNeeded:1.0];
		} else {
			[super startAnimation];
		}
	}
}
- (void)stopAnimation {
	if([self animationBlockingMode] == NSAnimationBlocking) {
		animating = NO;
		[self.timer invalidate];
		self.timer = nil;
	} else {
		[super startAnimation];
	}
}
- (void)setCurrentProgress:(NSAnimationProgress)pProgress {
	NSMutableSet *displayViews = [NSMutableSet set];
	for(ZWViewAnimationObject *animationObject in animationObjects) {
		NSRect r = animationObject->startFrame;
		if(pProgress < 1.0) {
			NSRect d = animationObject->deltaFrame;
			r.origin.x += d.origin.x * pProgress;
			r.origin.y += d.origin.y * pProgress;
			r.size.width += d.size.width * pProgress;
			r.size.height += d.size.height * pProgress;
		} else {
			r = animationObject->endFrame;
		}
		animationObject->view.frame = r;
		if([animationObject->view superview] != nil) {
			[displayViews addObject:[animationObject->view superview]];
		} else {
			[displayViews addObject:animationObject->view];
		}
	}
	[displayViews makeObjectsPerformSelector:@selector(display)];
	[super setCurrentProgress:pProgress];
}

#pragma mark - Animation

- (void)setCurrentProgressAndEndIfNeeded:(NSAnimationProgress)pProgress {
	if(animating) {
		pProgress = MAX(0.0, MIN(1.0, pProgress));
		[self setCurrentProgress:pProgress];
		if(pProgress >= 1.0) {
			if([[self delegate] respondsToSelector:@selector(animationDidEnd:)]) {
				[[self delegate] animationDidEnd:self];
			}
			[self stopAnimation];
		}
	}
}
- (void)timer:(NSTimer *)pTimer {
	CGFloat t = MIN(duration, [NSDate timeIntervalSinceReferenceDate] - startTime);
	CGFloat b = 0.0;
	CGFloat c = 1.0;
	CGFloat d = duration;
	NSAnimationProgress progress;
	
	switch([self animationCurve]) {
		case NSAnimationEaseIn :
			progress = ZWEasingSineEaseIn(t, b, c, d);
			break;
		case NSAnimationEaseOut :
			progress = ZWEasingSineEaseOut(t, b, c, d);
			break;
		case NSAnimationEaseInOut :
			progress = ZWEasingSineEaseInOut(t, b, c, d);
			break;
		default :
			progress = ZWEasingLinear(t, b, c, d);
			break;
	}
	[self setCurrentProgressAndEndIfNeeded:progress];
}



@end
