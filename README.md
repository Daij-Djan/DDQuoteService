DDQuoteService
==============
A random quote service that accesses iheartquotes.com and can optionally use a local file as backup.

Usage: Call `[[DDQuoteService defaultService] randomQuoteWithCompletionHandler:^(DDQuote *quote, NSError *error)` and in the completion handler, use the quote. For example to show an alert.

The above call tries iheartquotes.com first and falls back to the local file if no network or in case of error. (if a local file is provided :))

If you only want quotes from certain topics/categories from iheartquotes.com you can specific an array of source names to use with `- (void)randomQuoteFromSources:(NSArray*)sources withCompletionHandler:(DDQuoteServiceCompletionBlock)completionBlock;`

If you dont want iheartquotes.com at all, set `onlineEnabled=NO`

**the provided demo is for ios but the service works under osx, too**

