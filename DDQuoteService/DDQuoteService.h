//
//  DDQuoteService.h
//
// give credit to iheartquotes when using
//
//  Created by Dominik Pich on 17.08.11.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDQuote.h"

typedef void (^DDQuoteServiceCompletionBlock)(DDQuote *quote, NSError *error);

@interface DDQuoteService : NSObject

+ (id)defaultService; //http://www.iheartquotes.com/api & local Quotes.plist (if available)

//dictionary with category names each with an array with the Sources
+ (NSDictionary*)availableCategoriesWithSources; //for an up-to-date list of sources see http://www.iheartquotes.com/api

+ (id)localServiceWithFile:(NSString*)path;
+ (id)onlineServiceWithBackupFile:(NSString*)path;

@property(nonatomic, assign, getter = isOnlineEnabled) BOOL onlineEnabled;
@property(nonatomic, copy) NSString *localFile;

//!local support untested, no error handling to speak of :D
- (void)randomQuoteWithCompletionHandler:(DDQuoteServiceCompletionBlock)completionBlock;
- (void)randomQuoteFromSources:(NSArray*)sources withCompletionHandler:(DDQuoteServiceCompletionBlock)completionBlock;
@end

//the format of the local file:
// <plist> = {KEY:sourcename, VALUE:<array_quotes>}*
//   <array_quotes> = <dictionary_quote>1..*
//    <dictionary_quote> = {KEY:txt, VALUE:quote KEY:link VALUE:permalink}