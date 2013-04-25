#import "DDQuoteService.h"
#import "QuoteViewController.h"
#import "CustomButton.h"

@implementation QuoteViewController {
    NSMutableArray *dataList;
	NSMutableArray *checkPoints;
}

- (IBAction)getQuote:(id)sender {
    [[DDQuoteService defaultService] randomQuoteFromSources:checkPoints withCompletionHandler:^(DDQuote *quote, NSError *error) {
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

//---

- (void)viewDidLoad {
    dataList = [[NSMutableArray alloc] init];
	checkPoints = [[NSMutableArray alloc] init];
    [self fillupDataList];
	
    [super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    
	[checkPoints release];
    [dataList release];
    [_tableView release];
    [super dealloc];
}


#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dataList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[dataList objectAtIndex:section] objectForKey:@"array"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[dataList objectAtIndex:section] objectForKey:@"title"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CheckListTableViewController_Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	// Clean cell.contentView
	for (id subView in cell.contentView.subviews) {
		[subView removeFromSuperview];
	}
	
	// Get Value form dataList
	NSString *textValue = (NSString*)[[[dataList objectAtIndex:indexPath.section] objectForKey:@"array"] objectAtIndex:indexPath.row];
	
	// Some static vars for good object alignment (check images are 25x25)
	static CGFloat imagePuffer = 10;
	static CGFloat imageMargin = 5;
	static CGFloat textLabelSize = 260;
	
	// Create an UITextLabel for the content
	UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(25+imagePuffer+imageMargin, 0, textLabelSize-imagePuffer-imageMargin, 44)];
	[textLabel setBackgroundColor:[UIColor clearColor]];
	[textLabel setHighlightedTextColor:[UIColor whiteColor]];
	[textLabel setFont:[UIFont systemFontOfSize:14]];
	[textLabel setText:textValue];
	// Add Label to cell.contentView
	[cell.contentView addSubview:textLabel];
	[textLabel release];
	
	// Images for checked and unchecked tasks
	UIImage *checked = [UIImage imageNamed:@"check_on.png"];
	UIImage *unchecked = [UIImage imageNamed:@"check_off.png"];
	
	// Create custom Button
	CustomButton *checkbox = [[CustomButton alloc] init];
	// Important: Set @property indexPath to current indexPath
	[checkbox setIndexPath:indexPath];
	[checkbox addTarget:self action:@selector(hitCheckbox:) forControlEvents:UIControlEventTouchUpInside];
	[checkbox setFrame:CGRectMake(5, 22-12.5, 25, 25)];
	// Value is in checkPoints? Fine, show checked Task Image No? Show unchecked Task Image
	if ([checkPoints containsObject:textValue])
	{
		[checkbox setImage:checked forState:UIControlStateNormal];
	}
	else
	{
		[checkbox setImage:unchecked forState:UIControlStateNormal];
	}
	// Add CustomButton to cell.contentView
	[cell.contentView addSubview:checkbox];
	[checkbox release];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hitCheckboxAtIndexPath:indexPath];
}

#pragma mark -
#pragma mark Others

- (void) fillupDataList {
	[dataList removeAllObjects];
    NSDictionary *catsAndSources = [DDQuoteService availableCategoriesWithSources];
	for (id key in [catsAndSources allKeys]) {
        [dataList addObject:@{@"title":key, @"array":catsAndSources[key]}];
    }
	for (id key in [catsAndSources allKeys]) {
        for (id obj in catsAndSources[key]) {
            [checkPoints addObject:obj];
        }
    }
}

- (void) hitCheckbox:(CustomButton*)sender
{
    [self hitCheckboxAtIndexPath:sender.indexPath];
}

- (void) hitCheckboxAtIndexPath:(NSIndexPath*)path
{
    // get value from dataList by indexPath from customButton (set in cellForRowAtIndexPath)
	NSString *object = [[[dataList objectAtIndex:path.section] objectForKey:@"array"] objectAtIndex:path.row];
	
	// if value is in checkPoints remove the value else add the value
	if ([checkPoints containsObject:object]) {
		[checkPoints removeObject:object];
	}
	else {
		[checkPoints addObject:object];
	}
	
	// reload tableView
	[self.tableView reloadData];
}

@end
