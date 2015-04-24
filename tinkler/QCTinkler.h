//
//  QCTinkler.h
//  qrcar
//
//  Created by Diogo Guimarães on 03/01/15.
//  Copyright (c) 2015 Miguel Quintas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface QCTinkler : NSObject

@property (strong, nonatomic) NSString *tinklerId;
@property (strong, nonatomic) NSString *tinklerName;
@property (strong, nonatomic) PFUser *owner;
@property (strong, nonatomic) PFFile *tinklerImage;
@property (strong, nonatomic) PFObject *tinklerType;
@property (strong, nonatomic) NSString *vehiclePlate;
@property (strong, nonatomic) NSDate *vehicleYear;
@property (strong, nonatomic) NSString *petBreed;
@property (strong, nonatomic) NSDate *petAge;
@property (strong, nonatomic) NSString *brand;
@property (strong, nonatomic) NSString *color;
@property (strong, nonatomic) NSString *locationCity;
@property (strong, nonatomic) PFFile *tinklerQRCode;
@property (strong, nonatomic) NSNumber *tinklerQRCodeKey;

- (NSString *) tinklerDateToString:(NSDate *) tinklerDate;
- (NSDate *) tinklerStringToDate:(NSString *) tinklerDate;
- (UIImage *) tinklerFileToImage:(PFFile *) tinklerImage;
- (NSNumber *) birthDateToAge:(NSDate *) birthdate;

@end
