//
//  ViewController.m
//  CGContextDrawImageBug
//
//  Created by 李卓立 on 2022/3/15.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *imagePath = [NSBundle.mainBundle pathForResource:@"TestImage" ofType:@"bmp"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    NSParameterAssert(image);
    
    // CGBitmapContextCreate BGRX8888 will result wrong black image
    UIImage *image1 = [self testCGContextBugWithImage:image alpha:NO];
    
    // CGBitmapContextCreate BGRA8888 will result correct image
    UIImage *image2 = [self testCGContextBugWithImage:image alpha:YES];
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithImage:image1];
    [self.view addSubview:imageView1];
    imageView1.frame = CGRectMake(0, 100, 200, 200);
    
    UIImageView *imageView2 = [[UIImageView alloc] initWithImage:image2];
    [self.view addSubview:imageView2];
    imageView2.frame = CGRectMake(0, 400, 200, 200);
}

- (UIImage *)testCGContextBugWithImage:(UIImage *)image alpha:(BOOL)alpha {
    CGImageRef cgimage = image.CGImage;
    NSParameterAssert(cgimage);
    
    CGFloat width = CGImageGetWidth(cgimage);
    CGFloat height = CGImageGetHeight(cgimage);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little;
    if (alpha) {
        // BGRA
        bitmapInfo |= kCGImageAlphaPremultipliedFirst;
    } else {
        // BGRX
        bitmapInfo |= kCGImageAlphaNoneSkipFirst;
    }
    
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, colorspace, bitmapInfo);
    CGColorSpaceRelease(colorspace);
    NSParameterAssert(context);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgimage);
    CGImageRef createdCGImage = CGBitmapContextCreateImage(context);
    
    UIImage *result = [UIImage imageWithCGImage:createdCGImage];
    CGImageRelease(createdCGImage);
    
    return result;
}


@end
