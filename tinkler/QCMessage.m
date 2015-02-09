//
//  QCMessage.m
//  qrcar
//
//  Created by Diogo Guimarães on 15/09/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import "QCMessage.h"

@implementation QCMessage

- (NSString *) messageDateToString:(NSDate *) messageDate{
    //Yesterday's date
    long intervalDays=[self daysBetweenDate:[NSDate date] andDate:messageDate];
    NSLog(@"Days Between: %ld", intervalDays);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //If it was sent today show "HH:mm"
    if(intervalDays>-1){
        [dateFormatter setDateFormat:@"HH:mm"];
        return[dateFormatter stringFromDate:messageDate];
    //If it was sent yesterday show "Yesterday"
    }else if(intervalDays==-1){
        return @"Yesterday";
    //If it was sent this week show day of the week "EEEE"
    }else if(intervalDays>-7){
        [dateFormatter setDateFormat:@"EEEE"];
        return[dateFormatter stringFromDate:messageDate];
    //If it was sent before this week show "dd/mm/yy"
    }else{
        [dateFormatter setDateFormat:@"dd/MM/yy"];
        return[dateFormatter stringFromDate:messageDate];
    }

}

//Date Comparing to get the number of days in the given interval
- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

@end
