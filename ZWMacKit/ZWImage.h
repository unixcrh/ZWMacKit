#import <Foundation/Foundation.h>
#import "ZWPixels.h"

@interface ZWImage : NSObject {
}

#pragma mark - Properties

@property (nonatomic, readonly) NSUInteger width;
@property (nonatomic, readonly) NSUInteger height;
@property (nonatomic, readonly) ZWPixelFormat pixelFormat;
@property (nonatomic, readonly) ZWDitherFormat ditherFormat;
@property (nonatomic, readonly) CGImageRef CGImage;

- (void)setPixelFormat:(ZWPixelFormat)pPixelFormat ditherFormat:(ZWDitherFormat)pDitherFormat;

#pragma mark - Initialization

+ (id)imageWithData:(NSData *)pData;
- (id)initWithData:(NSData *)pData;
+ (id)imageWithContentsOfURL:(NSURL *)pURL;
- (id)initWithContentsOfURL:(NSURL *)pURL;
+ (id)imageWithCGImage:(CGImageRef)pCGImage;
- (id)initWithCGImage:(CGImageRef)pCGImage;

#pragma mark - Drawing

- (void)drawInContext:(CGContextRef)pContext atPoint:(CGPoint)pPoint;
- (void)drawInContext:(CGContextRef)pContext inRect:(CGRect)pRect;

@end
