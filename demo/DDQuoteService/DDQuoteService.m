//
//  DDQuoteService.m
//
// give credit to iheartquotes when using
//
//  Created by Dominik Pich on 17.08.11.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import "DDQuoteService.h"
#import "GTMNSString+HTML.h"

#define HEARTS_API_URL @"http://www.iheartquotes.com/api/v1/random"

typedef void (^DDQuoteServiceProceedBlock)(NSString*text, NSError*error);

@implementation DDQuoteService {
    NSOperationQueue *_ddQuoteQueue;
    NSDictionary *_localDictionary;
}

+ (id)defaultService { //http://www.programmableweb.com/api/iheartquotes & local Quotes.txt (if available)
    static DDQuoteService *service = nil;
    if(!service) {
        service = [self onlineServiceWithBackupFile:[[NSBundle mainBundle] pathForResource:@"Quotes" ofType:@"plist"]];
#if __has_feature(objc_arc)
#else
        [service retain];
#endif
    }
    return service;
}

+ (NSDictionary*)availableCategoriesWithSources {
    id geek = @[@"esr", @"humorix_misc", @"humorix_stories", @"joel_on_software", @"macintosh", @"math", @"mav_flame", @"osp_rules", @"paul_graham", @"prog_style", @"subversion"];
    id general = @[@"1811_dictionary_of_the_vulgar_tongue", @"codehappy", @"fortune", @"liberty", @"literature", @"misc", @"murphy", @"oneliners", @"riddles", @"rkba", @"shlomif", @"shlomif_fav", @"stephen_wright"];
    id pop = @[@"calvin", @"forrestgump", @"friends", @"futurama", @"holygrail", @"powerpuff", @"simon_garfunkel", @"simpsons_cbg", @"simpsons_chalkboard", @"simpsons_homer", @"simpsons_ralph", @"south_park", @"starwars", @"xfiles"];
    id religious = @[@"bible", @"contentions", @"osho"];
    id scifi = @[@"cryptonomicon", @"discworld", @"dune", @"hitchhiker"];
    
    return @{@"geek":geek, @"general":general, @"pop":pop, @"religious":religious, @"scifi":scifi};
}

+ (id)localServiceWithFile:(NSString*)path {
    DDQuoteService *service = [[self.class alloc] init];
    service.localFile = path;
#if __has_feature(objc_arc)
#else
    [service autorelease];
#endif
    return service;
}

+ (id)onlineServiceWithBackupFile:(NSString*)path {
    DDQuoteService *service = [[self.class alloc] init];
    service.onlineEnabled = YES;
    service.localFile = path;
#if __has_feature(objc_arc)
#else
    [service autorelease];
#endif
    return service;
}

//---

- (void)setLocalFile:(NSString *)localFile {
    if([_localFile isEqualToString:localFile])
        return;
    
#if __has_feature(objc_arc)
#else
    [_localFile autorelease];
#endif
    
    _localFile = localFile.copy;
    @synchronized(_localDictionary) {
#if __has_feature(objc_arc)
#else
        [_localDictionary autorelease];
#endif
        _localDictionary = nil;
    }
}

- (void)randomQuoteWithCompletionHandler:(DDQuoteServiceCompletionBlock)completionBlock {
    [self randomQuoteFromSources:nil withCompletionHandler:completionBlock];
}

- (void)randomQuoteFromSources:(NSArray*)sources withCompletionHandler:(DDQuoteServiceCompletionBlock)completionBlock {
    DDQuoteServiceProceedBlock proceed = ^(NSString*text, NSError*error) {
        DDQuote *quote = nil;
        
        if(!text && _localFile) {
            //random line from file
            @synchronized(_localDictionary) {
                if(!_localDictionary) {
                    _localDictionary = [[NSDictionary alloc] initWithContentsOfFile:_localFile];
                }

                if(_localDictionary) {
                    //src
                    srand((unsigned int)self);
                    NSArray *validSources = sources.count ? [_localDictionary.allKeys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF IN %@", sources]] : _localDictionary.allKeys;
                    NSInteger sourceIndex = rand() % validSources.count;
                    NSArray *quotes = _localDictionary[validSources[sourceIndex]];
                    
                    //quote
                    NSInteger quoteIndex = rand() % quotes.count;
                    NSMutableDictionary *quoteDict = [quotes[quoteIndex] mutableCopy];
                    quoteDict[@"source"] = validSources[sourceIndex];

                    //apply dict
                    quote = [DDQuote quoteWithDictionary:quoteDict];

#if __has_feature(objc_arc)
#else
                    [quoteDict release];
#endif
                    }
            }
        }
        
        if(text && !quote) {
            //parse text
            quote = [DDQuote quoteWithText:text];
        }
        
        if(!quote && !error) {
            error = [NSError errorWithDomain:NSStringFromClass(self.class) code:0 userInfo:nil]; //general
        }

        //callback
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(quote, error);
        });
    };
    
    //prepare our queue
    if(_ddQuoteQueue) {
        _ddQuoteQueue = [[NSOperationQueue alloc] init];
        _ddQuoteQueue.maxConcurrentOperationCount = 3;
        _ddQuoteQueue.suspended = NO;
    }
    
    if(self.onlineEnabled) {
        NSString *url = HEARTS_API_URL;
        if(sources.count) {
            url = [url stringByAppendingFormat:@"?source=%@", [[sources componentsJoinedByString:@"+"] gtm_stringByEscapingForHTML]];
        }
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
            id txt = nil;
            if(!e && d.length) {
                txt = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
            }
            proceed(txt, e);
        }];
    }
    else {
        [_ddQuoteQueue addOperationWithBlock:^{
            proceed(nil, nil);
        }];
    }
}

#if __has_feature(objc_arc)
#else
- (void)dealloc {
    [_ddQuoteQueue release];
    [_localDictionary release];
    [super dealloc];
}
#endif
@end
