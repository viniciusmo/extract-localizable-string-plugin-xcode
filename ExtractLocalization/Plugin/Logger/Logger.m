//
//  Logger.m
//  ExtractorLocalizableStrings
//
//  Created by viniciusmo on 7/30/14.
//  Copyright (c) 2014 viniciusmo. All rights reserved.
//

#import "Logger.h"

@implementation Logger

+(void)info:(NSString *) message, ...{
    va_list args;
    va_start(args, message);
    NSString * formatString = [[NSString alloc] initWithFormat:message arguments:args];
    NSLog(@"Extract Localizable Plugin : %@",formatString);
}

@end
