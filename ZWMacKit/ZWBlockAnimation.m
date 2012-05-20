#import "ZWBlockAnimation.h"
#import <ZWCoreKit/ZWEasingEquations.h>

static NSString *ZWBlockAnimationRunLoopMode = @"ZWBlockAnimationRunLoopMode";

@interface ZWBlockAnimation() {
	NSTimeInterval startTime;
	NSTimeInterval duration;
	BOOL animating;
}

@property (copy) void (^block)(NSAnimationProgress progress, BOOL *stop);
@property (assign) NSTimer *timer;

- (void)setCurrentProgressAndEndIfNeeded:(NSAnimationProgress)pProgress;
- (void)timer:(NSTimer *)pTimer;

@end
@implementation ZWBlockAnimation

#pragma mark - Properties

@synthesize block;
@synthesize timer;

#pragma mark - Initialization

+ (id)animationWithBlock:(void (^)(NSAnimationProgress progress, BOOL *stop))pBlock {
	return [[self alloc] initWithBlock:pBlock];
}
- (id)initWithBlock:(void (^)(NSAnimationProgress progress, BOOL *stop))pBlock {
	if((self = [super init])) {
		self.block = pBlock;
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
			[[NSRunLoop currentRunLoop] addTimer:self.timer forMode:ZWBlockAnimationRunLoopMode];
			while(animating) {
				[[NSRunLoop currentRunLoop] runMode:ZWBlockAnimationRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:duration]];
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
		if([[self delegate] respondsToSelector:@selector(animationDidStop:)]) {
			[[self delegate] animationDidStop:self];
		}
	} else {
		[super stopAnimation];
	}
}
- (void)setCurrentProgress:(NSAnimationProgress)pProgress {
	BOOL stop = NO;
	if(self.block != nil) {
		self.block(pProgress, &stop);
	}
	[super setCurrentProgress:pProgress];
	if(stop) {
		[self stopAnimation];
	}
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
			progress = ZWEasingCircEaseInOut(t, b, c, d);
			break;
		default :
			progress = ZWEasingLinear(t, b, c, d);
			break;
	}
	[self setCurrentProgressAndEndIfNeeded:progress];
}

@end
