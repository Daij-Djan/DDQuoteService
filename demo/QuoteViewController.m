#import "DDQuoteService.h"
#import "QuoteViewController.h"

@implementation QuoteViewController

- (IBAction)getQuote:(id)sender {
    [[DDQuoteService defaultService] randomQuoteWithCompletionHandler:^(DDQuote *quote, NSError *error) {
        NSString *decisionString = @"";
        if(quote.text.length) {
            decisionString = quote.text;
            if(quote.source.length)
                decisionString = [decisionString stringByAppendingFormat:@"\n\n#%@", NSLocalizedString(quote.source, @"quote source")];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Your quote", @"decision result title")
                                                        message:decisionString
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Yay", @"decision result title")
                                              otherButtonTitles:nil];
        alert.delegate = self;
        [alert show];
    }];
}

@end
