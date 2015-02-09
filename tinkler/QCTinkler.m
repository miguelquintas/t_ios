//
//  QCTinkler.m
//  qrcar
//
//  Created by Diogo Guimarães on 03/01/15.
//  Copyright (c) 2015 Miguel Quintas. All rights reserved.
//

#import "QCTinkler.h"

@implementation QCTinkler

- (NSString *) tinklerDateToString:(NSDate *) tinklerDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"LLL yyyy"];
    //Optionally for time zone conversions
    //[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    return[formatter stringFromDate:tinklerDate];
}

- (NSDate *) tinklerStringToDate:(NSString *) tinklerDate{
    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    // Format "Feb 2007"
    [dateFormat setDateFormat:@"LLLL yyyy"];
    return [dateFormat dateFromString:tinklerDate];
}

- (UIImage *) tinklerFileToImage:(PFFile *) tinklerImage{
    NSData *imageData = [tinklerImage getData];
    return [UIImage imageWithData:imageData];
}

- (NSNumber *) birthDateToAge:(NSDate *) birthdate{
    NSDateComponents *birthdateComp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:birthdate];
    
    NSDateComponents *todayComp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    NSNumber *petAge = [NSNumber numberWithInteger:[todayComp year]-[birthdateComp year]];
    
    return petAge;
}

@end
