#import "ZWImage.h"
#import <ZWCoreKit/CGImage+ZWExtensions.h>
#import <ZWCoreKit/CGContext+ZWExtensions.h>

@interface ZWImage() {	
}

@property (strong) ZWPixels *modelPixels;
@property (strong) ZWPixels *presentationPixels;
@property (assign) BOOL automaticallyUpdate;

- (void)updatePresentationPixels;
@end
@implementation ZWImage

#pragma mark - Properties

@dynamic width;
@dynamic height;
@synthesize pixelFormat;
@synthesize ditherFormat;
@dynamic CGImage;
@synthesize modelPixels;
@synthesize presentationPixels;
@synthesize automaticallyUpdate;

- (void)setPixelFormat:(ZWPixelFormat)pValue {
	pixelFormat = pValue;
	if(self.automaticallyUpdate) {
		[self updatePresentationPixels];
	}
}
- (void)setDitherFormat:(ZWDitherFormat)pValue {
	ditherFormat = pValue;
	if(self.automaticallyUpdate) {
		[self updatePresentationPixels];
	}
}
- (NSUInteger)width {
	return self.modelPixels.width;
}
- (NSUInteger)height {
	return self.modelPixels.height;
}
- (CGImageRef)CGImage {
	return self.presentationPixels.CGImage;
}

- (void)setPixelFormat:(ZWPixelFormat)pPixelFormat ditherFormat:(ZWDitherFormat)pDitherFormat {
	self.automaticallyUpdate = NO;
	self.pixelFormat = pPixelFormat;
	self.ditherFormat = pDitherFormat;
	self.automaticallyUpdate = YES;
	[self updatePresentationPixels];
}

#pragma mark - Initialization

+ (id)imageWithData:(NSData *)pData {
	return [[self alloc] initWithData:pData];
}
- (id)initWithData:(NSData *)pData {
	CGImageRef img = CGImageCreateWithData(pData);
	id r = [self initWithCGImage:img];
	CGImageRelease(img);
	return r;
}
+ (id)imageWithContentsOfURL:(NSURL *)pURL {
	return [[self alloc] initWithContentsOfURL:pURL];
}
- (id)initWithContentsOfURL:(NSURL *)pURL {
	CGImageRef img = CGImageCreateWithContentsOfURL(pURL);
	id r = [self initWithCGImage:img];
	CGImageRelease(img);
	return r;
}
+ (id)imageWithCGImage:(CGImageRef)pCGImage {
	return [[self alloc] initWithCGImage:pCGImage];
}
- (id)initWithCGImage:(CGImageRef)pCGImage {
	if((self = [super init])) {
		if(pCGImage == nil) {
			return nil;
		}
		self.automaticallyUpdate = NO;
		self.pixelFormat = ZWPixelFormatARGB8888;
		self.ditherFormat = ZWDitherFormatNone;
		self.automaticallyUpdate = YES;
		self.modelPixels = [ZWPixels pixelsWithCGImage:pCGImage];
		[self updatePresentationPixels];
	}
	return self;
}

#pragma mark - Private Actions

- (void)updatePresentationPixels {
	// ARGB88888
	if(self.pixelFormat == ZWPixelFormatARGB8888) {
		[self willChangeValueForKey:@"CGImage"];
		self.presentationPixels = self.modelPixels;
		[self didChangeValueForKey:@"CGImage"];
	}
	// Other but not same as existing
	else if(self.presentationPixels == nil || (self.presentationPixels.pixelFormat != pixelFormat | self.presentationPixels.ditherFormat != ditherFormat)) {
		[self willChangeValueForKey:@"CGImage"];
		self.presentationPixels = [self.modelPixels copy];
		[self.presentationPixels setPixelFormat:self.pixelFormat ditherFormat:self.ditherFormat premultiplyAlphaOnColorPass:NO];
		[self didChangeValueForKey:@"CGImage"];
	}
}

#pragma mark - Drawing

- (void)drawInContext:(CGContextRef)pContext atPoint:(CGPoint)pPoint {
	CGContextDrawImageAtPoint(pContext, pPoint, self.CGImage);
}
- (void)drawInContext:(CGContextRef)pContext inRect:(CGRect)pRect {
	CGContextDrawImage(pContext, pRect, self.CGImage);
}

@end