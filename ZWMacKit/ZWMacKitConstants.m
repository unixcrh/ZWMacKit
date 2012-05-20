#import "ZWMacKitConstants.h"
#import <QuartzCore/QuartzCore.h>
#import "NSColor+ZWMacExtensions.h"


unsigned int CAAutoresizingMaskAll = (kCALayerMinXMargin | 
									  kCALayerMinYMargin | 
									  kCALayerMaxXMargin | 
									  kCALayerMaxYMargin | 
									  kCALayerWidthSizable | 
									  kCALayerHeightSizable);
NSUInteger NSWindowToolbarHeight = 78;
NSUInteger NSViewAutoresizingMaskAll = (NSViewMinXMargin |
										NSViewMinYMargin |
										NSViewMaxXMargin |
										NSViewMaxYMargin |
										NSViewWidthSizable |
										NSViewHeightSizable);