//
//  DDQuote.h
//  DecisionMaker
//
//  Created by Dominik Pich on 01.04.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDQuote : NSObject

+ (id)quoteWithDictionary:(NSDictionary*)dict;
+ (id)quoteWithText:(NSString*)text;

@property (readonly, copy) NSString *text;
@property (readonly, copy) NSString *source;
@property (readonly, copy) NSURL *link;
@end
