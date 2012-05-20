#import "ZWPixels.h"
#import <Accelerate/Accelerate.h>
#import <ZWCoreKit/CGColorSpace+ZWExtensions.h>

@interface ZWPixels() {
	NSUInteger width;
	NSUInteger height;
	NSUInteger count;
	ZWPixelFormat pixelFormat;
	ZWDitherFormat ditherFormat;
	CGImageRef CGImage;
	CGRect colorRect;
}

@property (nonatomic, strong) NSMutableData *bufferData;
@property (nonatomic, readonly) ZWPixel *buffer;

- (void)pixelsDidChange;
- (void)processRGB:(BOOL)pProcessRGB alpha:(BOOL)pProcessRGB;

@end
@implementation ZWPixels

#pragma mark - Properties

@synthesize width;
@synthesize height;
@synthesize count;
@dynamic data;
@synthesize pixelFormat;
@synthesize ditherFormat;
@synthesize CGImage;
@synthesize colorRect;
@synthesize bufferData;
@dynamic buffer;

- (void)setPixelFormat:(ZWPixelFormat)pPixelFormat ditherFormat:(ZWDitherFormat)pDitherFormat premultiplyAlphaOnColorPass:(BOOL)pPremultiplyAlphaOnColorPass {
	if(pixelFormat != pPixelFormat || ditherFormat != pDitherFormat) {
		pixelFormat = pPixelFormat;
		ditherFormat = pDitherFormat;
		if(pPremultiplyAlphaOnColorPass) {
			// alpha pass
			[self processRGB:NO alpha:YES];
			
			// create vImage_Buffer
			vImage_Buffer vb;
			vb.data = self.buffer;
			vb.width = width;
			vb.height = height;
			vb.rowBytes = vb.width * sizeof(ZWPixel);
			
			// premultiply
			NSAssert(vImagePremultiplyData_ARGB8888(&vb, &vb, kvImageNoFlags) == kvImageNoError, @"Premultiplying pixels failed.");
			
			[self processRGB:YES alpha:NO];
			
			// unpremultiply
			NSAssert(vImageUnpremultiplyData_ARGB8888(&vb, &vb, kvImageNoFlags) == kvImageNoError, @"Unpremultiplying pixels failed.");
			
		} else {
			[self processRGB:YES alpha:YES];
		}
		[self pixelsDidChange];
	}
}

- (NSData *)data {
	return [bufferData copy];
}
- (CGImageRef)CGImage {
	if(CGImage == nil) {
		CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((__bridge CFDataRef)bufferData);
		CGImage = CGImageCreate(width,
								height,
								8,
								32,
								width * sizeof(ZWPixel),
								CGColorSpaceDeviceRGB(),
								kCGImageAlphaFirst,
								dataProvider,
								nil,
								NO,
								kCGRenderingIntentDefault);
		CGDataProviderRelease(dataProvider);
	}
	return CGImage;
}
- (ZWPixel)pixelAtX:(NSUInteger)pX y:(NSUInteger)pY {
	return self.buffer[pY * width + pX];
}
- (void)setPixel:(ZWPixel)pPixel atX:(NSUInteger)pX y:(NSUInteger)pY {
	self.buffer[pY * width + pX] = pPixel;
	[self pixelsDidChange];
}
- (ZWPixelPacket)pixelPacketAtX:(NSUInteger)pX y:(NSUInteger)pY {
	return ZWPixelPacketFromPixel(self.buffer[pY * width + pX]);
}
- (void)setPixelPacket:(ZWPixelPacket)pPixelPacket atX:(NSUInteger)pX y:(NSUInteger)pY {
	self.buffer[pY * width + pX] = ZWPixelFromPixelPacket(pPixelPacket);
	[self pixelsDidChange];
}
- (ZWRealPixelPacket)realPixelPacketAtX:(NSUInteger)pX y:(NSUInteger)pY {
	return ZWRealPixelPacketFromPixelPacket([self pixelPacketAtX:pX y:pY]);
}
- (void)setRealPixelPacket:(ZWRealPixelPacket)pRealPixelPacket atX:(NSUInteger)pX y:(NSUInteger)pY {
	[self pixelsDidChange];
	[self setPixelPacket:ZWPixelPacketFromRealPixelPacket(pRealPixelPacket) atX:pX y:pY];
}
- (CGRect)colorRect {
	if(CGRectIsEmpty(colorRect)) {
		NSInteger left = width;
		NSInteger top = -1;
		NSInteger right = 0;
		NSInteger bottom = 0;
		BOOL isEmpty = YES;
		ZWPixel *processBuffer = self.buffer;
		for(NSInteger y = 0; y < height; ++y) {
			BOOL isEmptyPixel = YES;
			for(NSInteger x = 0; x < width; ++x) {
				ZWPixelPacket pp = ZWPixelPacketFromPixel(processBuffer[y * width + x]);
				if(pp.a > 0) {
					isEmpty = NO;
					isEmptyPixel = NO;
					if(x < left) {
						left = x;
					}
					if(x >= right) {
						right = x + 1;
					}
				}
			}
			if(!isEmptyPixel) {
				if(top < 0) {
					top = y;
				}
				bottom = y + 1;
			}
		}
		if(isEmpty) {
			colorRect = CGRectMake(0.0, 0.0, width, height);
		}
		colorRect = CGRectMake(left, top, right - left, bottom - top);
	}
	return colorRect;
}
- (ZWPixel *)buffer {
	return (ZWPixel *)[self.bufferData mutableBytes];
}

#pragma mark - Initialization

+ (id)pixelsWithData:(NSData *)pData 
			   width:(NSUInteger)pWidth 
			  height:(NSUInteger)pHeight 
		 pixelFormat:(ZWPixelFormat)pPixelFormat 
		ditherFormat:(ZWDitherFormat)pDitherFormat {
	return [[self alloc] initWithData:pData
								width:pWidth
							   height:pHeight
						  pixelFormat:pPixelFormat
						 ditherFormat:pDitherFormat];
}
- (id)initWithData:(NSData *)pData 
			 width:(NSUInteger)pWidth 
			height:(NSUInteger)pHeight 
	   pixelFormat:(ZWPixelFormat)pPixelFormat 
	  ditherFormat:(ZWDitherFormat)pDitherFormat {
	if((self = [super init])) {
		width = pWidth;
		height = pHeight;
		count = width * height;
		pixelFormat = pPixelFormat;
		ditherFormat = pDitherFormat;
		bufferData = [pData mutableCopy];
	}
	return self;
}
+ (id)pixelsWithWidth:(NSUInteger)pWidth height:(NSUInteger)pHeight {
	return [[self alloc] initWithWidth:pWidth height:pHeight];
}
- (id)initWithWidth:(NSUInteger)pWidth height:(NSUInteger)pHeight {
	if((self = [super init])) {
		width = pWidth;
		height = pHeight;
		count = width * height;
		pixelFormat = ZWPixelFormatARGB8888;
		ditherFormat = ZWDitherFormatNone;
		self.bufferData = [NSMutableData dataWithLength:count * sizeof(ZWPixel)];
	}
	return self;
}
+ (id)pixelsWithCGImage:(CGImageRef)pCGImage {
	return [[self alloc] initWithCGImage:pCGImage];
}
- (id)initWithCGImage:(CGImageRef)pCGImage {
	if((self = [super init])) {
		width = CGImageGetWidth(pCGImage);
		height = CGImageGetHeight(pCGImage);
		count = width * height;
		
		// create two buffer objects
		NSMutableData *b1 = [NSMutableData dataWithLength:count * sizeof(ZWPixel)];
		NSMutableData *b2 = [NSMutableData dataWithLength:count * sizeof(ZWPixel)];
		
		// create two vImage buffers
		vImage_Buffer vb1;
		vb1.data = [b1 mutableBytes];
		vb1.width = width;
		vb1.height = height;
		vb1.rowBytes = vb1.width * sizeof(ZWPixel);
		
		vImage_Buffer vb2;
		vb2.data = [b2 mutableBytes];
		vb2.width = width;
		vb2.height = height;
		vb2.rowBytes = vb2.width * sizeof(ZWPixel);
		
		// convert to ARGB8888 premultiplied
		CGContextRef ctx = CGBitmapContextCreate(vb1.data, 
												 width, 
												 height, 
												 8, 
												 width * sizeof(ZWPixel), 
												 CGColorSpaceDeviceRGB(), 
												 kCGImageAlphaPremultipliedFirst);
		CGContextClearRect(ctx, CGRectMake(0.0, 0.0, width, height));
		CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, width, height), pCGImage);
		CGContextRelease(ctx);
		
		// convert ARGB8888 premultiplied to ARGB8888 unpremultiplied
		NSAssert(vImageUnpremultiplyData_ARGB8888(&vb1, &vb2, kvImageNoFlags) == kvImageNoError, @"Unpremultiplying pixels failed.");
		
		pixelFormat = ZWPixelFormatARGB8888;
		ditherFormat = ZWDitherFormatNone;
		bufferData = b2;
		
	}
	return self;
}

- (NSData *)dataByPermutatingChannels:(const ZWQuantum[4])pPermuteMap {
	NSMutableData *permutatedData = [self.bufferData mutableCopy];
	vImage_Buffer buffer;
	buffer.data = [permutatedData mutableBytes];
	buffer.width = self.width;
	buffer.height = self.height;
	buffer.rowBytes = buffer.width * sizeof(ZWPixel);
	
	// permutate
	NSAssert(vImagePermuteChannels_ARGB8888(&buffer, &buffer, pPermuteMap, kvImageNoFlags) == kvImageNoError, @"Permutating pixels failed.");
	
	return permutatedData;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)pCoder {
	if((self = [super init])) {
		width = [pCoder decodeIntegerForKey:@"width"];
		height = [pCoder decodeIntegerForKey:@"height"];
		count = [pCoder decodeIntegerForKey:@"count"];
		pixelFormat = [pCoder decodeIntegerForKey:@"pixelFormat"];
		ditherFormat = [pCoder decodeIntegerForKey:@"ditherFormat"];
		bufferData = [pCoder decodeObjectForKey:@"bufferData"];
	}
	return self;
}
- (void)encodeWithCoder:(NSCoder *)pCoder {
	[pCoder encodeInteger:width forKey:@"width"];
	[pCoder encodeInteger:height forKey:@"height"];
	[pCoder encodeInteger:count forKey:@"count"];
	[pCoder encodeObject:bufferData forKey:@"bufferData"];
	[pCoder encodeInteger:pixelFormat forKey:@"pixelFormat"];
	[pCoder encodeInteger:ditherFormat forKey:@"ditherFormat"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)pZone {
	return [[ZWPixels allocWithZone:pZone] initWithData:bufferData width:width height:height pixelFormat:pixelFormat ditherFormat:ditherFormat];
}

#pragma mark - Private Actions

- (void)pixelsDidChange {
	if(CGImage != nil) {
		CGImageRelease(CGImage);
		CGImage = nil;
	}
	colorRect = CGRectNull;
}
- (void)processRGB:(BOOL)pRGB alpha:(BOOL)pAlpha {
	NSInteger x, y, i, j, k;
	
	NSData *originalBufferData = nil;
	const ZWPixel *originalBuffer = nil;
	ZWPixel *processBuffer = self.buffer;
	
	// lossless alpha-only
	if(pixelFormat == ZWPixelFormatARGB8000) {
		for(i = 0; i < count; ++i) {
			ZWPixelPacket pp = ZWPixelPacketFromPixel(processBuffer[i]);
			pp.r = 0;
			pp.g = 0;
			pp.a = 0;
			processBuffer[i] = ZWPixelFromPixelPacket(pp);
		}
	}
	// lossy formats with dithering
	else {
		// setup color ranges
		ZWQuantumAny colorRanges[4];
		switch(pixelFormat) {
			case ZWPixelFormatARGB0565 :
				colorRanges[0] = ZWGetQuantumRange(0);
				colorRanges[1] = ZWGetQuantumRange(5);
				colorRanges[2] = ZWGetQuantumRange(6);
				colorRanges[3] = ZWGetQuantumRange(5);
				break;
			case ZWPixelFormatARGB1555 :
				colorRanges[0] = ZWGetQuantumRange(1);
				colorRanges[1] = ZWGetQuantumRange(5);
				colorRanges[2] = ZWGetQuantumRange(5);
				colorRanges[3] = ZWGetQuantumRange(5);
				break;
			case ZWPixelFormatARGB4444 :
				colorRanges[0] = ZWGetQuantumRange(4);
				colorRanges[1] = ZWGetQuantumRange(4);
				colorRanges[2] = ZWGetQuantumRange(4);
				colorRanges[3] = ZWGetQuantumRange(4);
				break;
			default :
				return;
		}
		
		const NSInteger ditherOffsets[4][2] = {{1,0}, {-1,1}, {0,1}, {1,1}};
		const CGFloat ditherWeights[4] = {7.0 / 16.0, 3.0 / 16.0, 5.0 / 16.0, 1.0 / 16.0};
		
		if(pAlpha && colorRanges[0] > 0) {
			originalBufferData = [self.bufferData copy];
			originalBuffer = (const ZWPixel *)[originalBufferData bytes];
		}
		
		for(y = 0; y < height; ++y) {
			for(x = 0; x < width; ++x) {
				i = y * width + x;
				
				ZWPixelPacket inPixelPacket = ZWPixelPacketFromPixel(processBuffer[i]);
				ZWPixelPacket outPixelPacket = inPixelPacket;
				
				// alpha
				if(pAlpha && colorRanges[0] > 0) {
					outPixelPacket.a = ZWScaleAnyToQuantum(ZWScaleQuantumToAny(inPixelPacket.a, colorRanges[0]), colorRanges[0]);
				}
				
				// rgb
				if(pRGB) {
					outPixelPacket.r = ZWScaleAnyToQuantum(ZWScaleQuantumToAny(inPixelPacket.r, colorRanges[1]), colorRanges[1]);
					outPixelPacket.g = ZWScaleAnyToQuantum(ZWScaleQuantumToAny(inPixelPacket.g, colorRanges[2]), colorRanges[2]);
					outPixelPacket.b = ZWScaleAnyToQuantum(ZWScaleQuantumToAny(inPixelPacket.b, colorRanges[3]), colorRanges[3]);
				}
				
				if(ditherFormat == ZWDitherFormatFloydSteinberg) {
					ZWRealPixelPacket error;
					if(pAlpha) {
						error.a = inPixelPacket.a - outPixelPacket.a;
					}
					if(pRGB) {
						error.r = inPixelPacket.r - outPixelPacket.r;
						error.g = inPixelPacket.g - outPixelPacket.g;
						error.b = inPixelPacket.b - outPixelPacket.b;
					}
					
					for(j = 0; j < 4; ++j) {
						NSInteger dx = x + ditherOffsets[j][0];
						NSInteger dy = y + ditherOffsets[j][1];
						k = dy * width + dx;
						
						if(dx >= 0 && dx < width && dy >= 0 && dy < height) {
							ZWPixelPacket ditherPixelPacket = ZWPixelPacketFromPixel(processBuffer[k]);
							
							// alpha
							if(pAlpha && colorRanges[0] > 0) {
								ZWPixelPacket ditherOriginalPixelPacket = ZWPixelPacketFromPixel(originalBuffer[k]);
								if(ditherOriginalPixelPacket.a != 255) {
									ditherPixelPacket.a = ZWClampRealQuantumToQuantum(ditherPixelPacket.a + error.a * ditherWeights[j]);
								}
							}
							
							// rgb
							if(pRGB) {
								ditherPixelPacket.r = ZWClampRealQuantumToQuantum(ditherPixelPacket.r + error.r * ditherWeights[j]);
								ditherPixelPacket.g = ZWClampRealQuantumToQuantum(ditherPixelPacket.g + error.g * ditherWeights[j]);
								ditherPixelPacket.b = ZWClampRealQuantumToQuantum(ditherPixelPacket.b + error.b * ditherWeights[j]);
							}
							
							processBuffer[k] = ZWPixelFromPixelPacket(ditherPixelPacket);
						}
					}
				}
				
				processBuffer[i] = ZWPixelFromPixelPacket(outPixelPacket);
			}
		}
	}
}

#pragma mark - Dealloc

- (void)dealloc {
	if(CGImage != nil) {
		CGImageRelease(CGImage);
		CGImage = nil;
	}
}

@end
