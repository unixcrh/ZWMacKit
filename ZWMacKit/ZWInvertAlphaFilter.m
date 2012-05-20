#import "ZWInvertAlphaFilter.h"
#import <QuartzCore/QuartzCore.h>


static CIKernel *ZWInvertAlphaFilterKernel;
static dispatch_once_t ZWInvertAlphaFilterKernelOnce = 0;

@implementation ZWInvertAlphaFilter

#pragma mark - Properties

@synthesize inputImage;

#pragma mark - Initialization

+ (void)load {
	@autoreleasepool {
		[CIFilter registerFilterName:@"ZWInvertAlpha"
#if MAC_OS_X_VERSION_10_7
						 constructor:(id <CIFilterConstructor>)[self class]
#else
						 constructor:[self class]
#endif
					 classAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
									  @"Invert Alpha", kCIAttributeFilterDisplayName,
									  [NSArray arrayWithObject:kCICategoryColorAdjustment], kCIAttributeFilterCategories,
									  nil]];
	}
}
- (id)init {
	if((self = [super init])) {
		dispatch_once(&ZWInvertAlphaFilterKernelOnce, ^{
			NSArray *kernels = [CIKernel kernelsWithString:@"kernel vec4 ZWInvertAlphaFilterKernel(sampler i) { vec4 t = sample(i, samplerCoord(i)); t.a = 1.0 - t.a; return t; }"];
			ZWInvertAlphaFilterKernel = [kernels objectAtIndex:0];
		});
	}
	return self;
}
- (CIImage *)outputImage {
	CISampler *src = [CISampler samplerWithImage:self.inputImage];
	return [self apply:ZWInvertAlphaFilterKernel, src, nil];
}

@end
