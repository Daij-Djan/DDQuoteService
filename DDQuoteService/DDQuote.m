//
//  DDQuote.m
//  DecisionMaker
//
//  Created by Dominik Pich on 01.04.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import "DDQuote.h"

@interface DDQuote ()
@property (readwrite, copy) NSString *text;
@property (readwrite, copy) NSString *source;
@property (readwrite, copy) NSURL *link;
@end

@implementation DDQuote

+ (id)quoteWithDictionary:(NSDictionary*)dict {
    DDQuote *q = [[self.class alloc] init];
    q.text = dict[@"text"];
    
    id link = dict[@"link"];
    q.link = ([link isKindOfClass:[NSURL class]] ? link : [NSURL URLWithString:link]);
    
    q.source = dict[@"source"];
    
    return q;
}

+ (id)quoteWithText:(NSString*)string {
    DDQuote *q = [[self.class alloc] init];

    //split
    NSUInteger length = [string length];
    NSUInteger paraStart = 0, paraEnd = 0, contentsEnd = 0;
    NSMutableArray *array = [NSMutableArray array];
    NSRange currentRange;
    while (paraEnd < length)
    {
        [string getParagraphStart:&paraStart end:&paraEnd
                      contentsEnd:&contentsEnd forRange:NSMakeRange(paraEnd, 0)];
        currentRange = NSMakeRange(paraStart, contentsEnd - paraStart);
        [array addObject:[string substringWithRange:currentRange]];
    }
    
    if(array.count <= 1) {
        return nil;
    }
    
    //all but last line is text
    NSArray *txtLines = [array subarrayWithRange:NSMakeRange(0, array.count-1)];
    q.text = [txtLines componentsJoinedByString:@"\n"];
    
    NSString *line = array.lastObject;
    NSUInteger c = [line rangeOfString:@"]"].location;
    
    if(c!=NSNotFound) {
        //src
        q.source = [line substringWithRange:NSMakeRange(1, c-1)];
        //link
        NSString *link = [line substringFromIndex:c+1];
        q.link = [NSURL URLWithString:[link stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
    
    return q;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Quote :%@\nFrom: %@\nLink: %@", self.text, self.source, self.link];
}
@end
