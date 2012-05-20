#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>

enum {
	ZWPixelFormatARGB8888 = 0,
	ZWPixelFormatARGB0565,
	ZWPixelFormatARGB1555,
	ZWPixelFormatARGB4444,
	ZWPixelFormatARGB8000,
	ZWPixelFormatCount,
};
typedef NSInteger ZWPixelFormat;

enum {
	ZWDitherFormatNone = 0,
	ZWDitherFormatFloydSteinberg,
	ZWDitherFormatCount,
};
typedef NSInteger ZWDitherFormat;

typedef unsigned char ZWQuantum;
typedef size_t ZWQuantumAny;
typedef double ZWRealQuantum;
typedef unsigned int ZWPixel;

typedef struct {
	ZWRealQuantum r;
	ZWRealQuantum g;
	ZWRealQuantum b;
	ZWRealQuantum a;
} ZWRealPixelPacket;

typedef struct {
	ZWQuantum r;
	ZWQuantum g;
	ZWQuantum b;
	ZWQuantum a;
} ZWPixelPacket;

typedef struct {
	ZWQuantum r[256];
	ZWQuantum g[256];
	ZWQuantum b[256];
	ZWQuantum a[256];
} ZWQuantumColorMap;

typedef struct {
	ZWRealQuantum r[256];
	ZWRealQuantum g[256];
	ZWRealQuantum b[256];
	ZWRealQuantum a[256];
} ZWRealQuantumColorMap;

#define ZWQuantumRange 255UL
#define ZWQuantumScale  ((double) 1.0/(double) ZWQuantumRange)
#define ZWClampToQuantum(__V__) ((__V__ >= 0) ? ((__V__ <= 255) ? __V__ : 255) : 0);

static inline ZWQuantum ZWClampRealQuantumToQuantum(const ZWRealQuantum value) {
	if(value <= 0.0) {
		return ((ZWQuantum)0);
	} else if(value >= ZWQuantumRange) {
		return ((ZWQuantum)ZWQuantumRange);
	} else {
		return ((ZWQuantum)value + 0.5);
	}
}
static inline ZWQuantumAny ZWGetQuantumRange(const ZWQuantumAny depth) {
	if(depth == 0) {
		return 0;
	}
	size_t r = 1;
	return ((ZWQuantumAny) ((r << (depth - 1)) + ((r << (depth - 1)) - 1)));
}
static inline ZWQuantum ZWScaleAnyToQuantum(const ZWQuantumAny value, const ZWQuantumAny range) {
	return ((ZWQuantum)(((ZWRealQuantum) ZWQuantumRange * value) / range + 0.5));
}
static inline ZWQuantumAny ZWScaleQuantumToAny(const ZWQuantumAny value, const ZWQuantumAny range) {
	return ((ZWQuantumAny) (((ZWRealQuantum) range * value) / ZWQuantumRange + 0.5));
}
static inline ZWRealPixelPacket ZWRealPixelPacketFromPixelPacket(ZWPixelPacket pixelPacket) {
	ZWRealPixelPacket rpp;
	rpp.a = (ZWRealQuantum)pixelPacket.a;
	rpp.r = (ZWRealQuantum)pixelPacket.r;
	rpp.g = (ZWRealQuantum)pixelPacket.g;
	rpp.b = (ZWRealQuantum)pixelPacket.b;
	return rpp;
}
static inline ZWPixelPacket ZWPixelPacketFromRealPixelPacket(ZWRealPixelPacket realPixelPacket) {
	ZWPixelPacket pp;
	pp.a = ZWClampRealQuantumToQuantum(realPixelPacket.a);
	pp.r = ZWClampRealQuantumToQuantum(realPixelPacket.r);
	pp.g = ZWClampRealQuantumToQuantum(realPixelPacket.g);
	pp.b = ZWClampRealQuantumToQuantum(realPixelPacket.b);
	return pp;
}
static inline ZWPixelPacket ZWPixelPacketFromPixel(ZWPixel pixel) {
	ZWPixelPacket pp;
	pp.a = ((pixel >> 0) & 0xFF);
	pp.r = ((pixel >> 8) & 0xFF);
	pp.g = ((pixel >> 16) & 0xFF);
	pp.b = ((pixel >> 24) & 0xFF);
	return pp;
}
static inline ZWPixel ZWPixelFromPixelPacket(ZWPixelPacket pixelPacket) {
	return (ZWPixel)((pixelPacket.a << 0) |
					 (pixelPacket.r << 8) |
					 (pixelPacket.g << 16) |
					 (pixelPacket.b << 24));
}

@interface ZWPixels : NSObject <NSCoding, NSCopying> {
}

#pragma mark - Properties

@property (nonatomic, readonly) NSUInteger width;
@property (nonatomic, readonly) NSUInteger height;
@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) ZWPixelFormat pixelFormat;
@property (nonatomic, readonly) ZWDitherFormat ditherFormat;
@property (nonatomic, readonly) CGImageRef CGImage;
@property (nonatomic, readonly) CGRect colorRect;

- (ZWPixel)pixelAtX:(NSUInteger)pX y:(NSUInteger)pY;
- (void)setPixel:(ZWPixel)pPixel atX:(NSUInteger)pX y:(NSUInteger)pY;
- (ZWPixelPacket)pixelPacketAtX:(NSUInteger)pX y:(NSUInteger)pY;
- (void)setPixelPacket:(ZWPixelPacket)pPixelPacket atX:(NSUInteger)pX y:(NSUInteger)pY;
- (ZWRealPixelPacket)realPixelPacketAtX:(NSUInteger)pX y:(NSUInteger)pY;
- (void)setRealPixelPacket:(ZWRealPixelPacket)pRealPixelPacket atX:(NSUInteger)pX y:(NSUInteger)pY;
- (void)setPixelFormat:(ZWPixelFormat)pPixelFormat ditherFormat:(ZWDitherFormat)pDitherFormat premultiplyAlphaOnColorPass:(BOOL)pPremultiplyAlphaOnColorPass;
- (CGRect)colorRect;

#pragma mark - Initialization

+ (id)pixelsWithData:(NSData *)pData 
			   width:(NSUInteger)pWidth 
			  height:(NSUInteger)pHeight 
		 pixelFormat:(ZWPixelFormat)pPixelFormat 
		ditherFormat:(ZWDitherFormat)pDitherFormat;
- (id)initWithData:(NSData *)pData 
			 width:(NSUInteger)pWidth 
			height:(NSUInteger)pHeight 
	   pixelFormat:(ZWPixelFormat)pPixelFormat 
	  ditherFormat:(ZWDitherFormat)pDitherFormat;
+ (id)pixelsWithWidth:(NSUInteger)pWidth height:(NSUInteger)pHeight;
- (id)initWithWidth:(NSUInteger)pWidth height:(NSUInteger)pHeight;
+ (id)pixelsWithCGImage:(CGImageRef)pCGImage;
- (id)initWithCGImage:(CGImageRef)pCGImage;
- (NSData *)dataByPermutatingChannels:(const ZWQuantum[4])pPermuteMap;

@end
