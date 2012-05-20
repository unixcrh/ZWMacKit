#import <Quartz/Quartz.h>


@interface ZWInvertAlphaFilter : CIFilter {
}

#pragma mark - Properties

@property (assign) CIImage *inputImage;

@end
