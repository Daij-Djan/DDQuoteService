#import <UIKit/UIKit.h>

@interface QuoteViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
- (IBAction)getQuote:(id)sender;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@end

