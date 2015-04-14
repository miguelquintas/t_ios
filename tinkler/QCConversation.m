//
//  QCConversation.m
//  qrcar
//
//  Created by Diogo Guimarães on 25/10/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import "QCConversation.h"

@implementation QCConversation

- (NSString *) conversationDateToString:(NSDate *) updateDate{
    //Yesterday's date
    long intervalDays=[self daysBetweenDate:[NSDate date] andDate:updateDate];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //If it was sent today show "HH:mm"
    if(intervalDays>-1){
        [dateFormatter setDateFormat:@"HH:mm"];
        return[dateFormatter stringFromDate:updateDate];
        //If it was sent yesterday show "Yesterday"
    }else if(intervalDays==-1){
        return @"Yesterday";
        //If it was sent this week show day of the week "EEEE"
    }else if(intervalDays>-7){
        [dateFormatter setDateFormat:@"EEEE"];
        return[dateFormatter stringFromDate:updateDate];
        //If it was sent before this week show "dd/mm/yy"
    }else{
        [dateFormatter setDateFormat:@"dd/MM/yy"];
        return[dateFormatter stringFromDate:updateDate];
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
