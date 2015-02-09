//
//  QCQrCode.h
//  qrcar
//
//  Created by Diogo Guimarães on 30/09/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QCQrCode : NSObject

+ (CIImage *)createQRForString:(NSString *)qrString;
+ (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image withScale:(CGFloat)scale;
+ (UIImage *)generateQRCode:(NSString*)objectId :(NSNumber*)qrCodeKey :(NSString*)tinklerType;

@end
