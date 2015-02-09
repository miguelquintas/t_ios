//
//  QCQrCode.m
//  qrcar
//
//  Created by Diogo Guimarães on 30/09/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import "QCQrCode.h"

@implementation QCQrCode

+ (CIImage *)createQRForString:(NSString *)qrString
{
    // Need to convert the string to a UTF-8 encoded NSData object
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    // Send the image back
    return qrFilter.outputImage;
}

+ (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image withScale:(CGFloat)scale
{
    // Render the CIImage into a CGImage
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:image fromRect:image.extent];
    
    // Now we'll rescale using CoreGraphics
    UIGraphicsBeginImageContext(CGSizeMake(image.extent.size.width * scale, image.extent.size.width * scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    // We don't want to interpolate (since we've got a pixel-correct image)
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    // Get the image out
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // Tidy up
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    return scaledImage;
}

+ (UIImage *)generateQRCode:(NSString*)objectId :(NSNumber*)qrCodeKey :(NSString*)tinklerType {
    
    //Create QR-Code String
    NSString *qrContent = @"http://tinkler.it?";
    //Append TinklerId after the "?" char
    qrContent = [qrContent stringByAppendingString:objectId];
    qrContent = [qrContent stringByAppendingString:@"!"];
    //Append QR-Code Key after the "!" char
    qrContent = [qrContent stringByAppendingString:[qrCodeKey stringValue]];
    qrContent = [qrContent stringByAppendingString:@"&"];
    qrContent = [qrContent stringByAppendingString:tinklerType];
    NSLog(@"%@", qrContent);
    
    // Generate the image
    CIImage *qrCode = [self createQRForString:qrContent];
    
    // Convert to an UIImage
    UIImage *qrCodeImg = [self createNonInterpolatedUIImageFromCIImage:qrCode withScale:4*[[UIScreen mainScreen] scale]];
    
    return qrCodeImg;
    
}

@end
