//
//  DDQuote.m
//  DecisionMaker
//
//  Created by Dominik Pich on 01.04.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import "DDQuote.h"
#import "GTMNSString+HTML.h"

@interface DDQuote ()
@property (readwrite, copy) NSString *text;
@property (readwrite, copy) NSString *source;
@property (readwrite, copy) NSURL *link;
@end

@implementation DDQuote

+ (id)quoteWithDictionary:(NSDictionary*)dict {
    DDQuote *q = [[self.class alloc] init];
    q.text = [dict[@"text"] gtm_stringByUnescapingFromHTML];
    
    id link = dict[@"link"];
    q.link = ([link isKindOfClass:[NSURL class]] ? link : [NSURL URLWithString:link]);
    
    q.source = dict[@"source"];
    
#if __has_feature(objc_arc)
#else
    [q autorelease];
#endif
    return q;
}

+ (id)quoteWithText:(NSString*)string {
    //split
    unsigned length = [string length];
    unsigned paraStart = 0, paraEnd = 0, contentsEnd = 0;
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
    
    DDQuote *q = [[self.class alloc] init];

    //all but last line is text
    NSArray *txtLines = [array subarrayWithRange:NSMakeRange(0, array.count-1)];
    q.text = [[txtLines componentsJoinedByString:@"\n"] gtm_stringByUnescapingFromHTML];
    
    NSString *line = array.lastObject;
    NSUInteger c = [line rangeOfString:@"]"].location;
    
    if(c!=NSNotFound) {
        //src
        q.source = [line substringWithRange:NSMakeRange(1, c-1)];
        //link
        NSString *link = [line substringFromIndex:c+1];
        q.link = [NSURL URLWithString:[link stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
    
#if __has_feature(objc_arc)
#else
    [q autorelease];
#endif
    return q;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Quote :%@\nFrom: %@\nLink: %@", self.text, self.source, self.link];
}

#if __has_feature(objc_arc)
#else
- (void)dealloc {
    [_text release];
    [_source release];
    [_link release];
    [super dealloc];
}
#endif

@end
