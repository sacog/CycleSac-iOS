/** Cycle Philly, 2013 Code For Philly
 *                                    Philadelphia, PA. USA
 *
 *
 *   Contact: Corey Acri <acri.corey@gmail.com>
 *            Lloyd Emelle <lemelle@codeforamerica.org>
 *
 *   Updated/Modified for Philadelphia's app deployment. Based on the
 *   Cycle Atlanta and CycleTracks codebase for SFCTA.
 *
 * Cycle Atlanta, Copyright 2012, 2013 Georgia Institute of Technology
 *                                    Atlanta, GA. USA
 *
 *   @author Christopher Le Dantec <ledantec@gatech.edu>
 *   @author Anhong Guo <guoanhong@gatech.edu>
 *
 *   Cycle Atlanta is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   Cycle Atlanta is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with Cycle Atlanta.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "TripDetailViewController.h"

@interface TripDetailViewController ()
{
    NSArray *pickerData;
}
@end

@implementation TripDetailViewController
@synthesize delegate;
@synthesize detailTextView;
@synthesize detailPicker;
@synthesize comfortDataSource;
@synthesize tapRecognizer;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    //[self.detailTextView becomeFirstResponder];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
    
    detailTextView.layer.borderWidth = 1.0;
    detailTextView.layer.borderColor = [[UIColor blackColor] CGColor];
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 435)];
    scroll.contentSize = CGSizeMake(320, 700);
    scroll.showsHorizontalScrollIndicator = YES;
    
    pickerData = @[@"", @"Excellent - no stress!", @"Good - low stress", @"Fair - some stress",
                   @"Poor - pretty stressful", @"Terrible - high stress!"];
    comfortDataSource = [[ComfortDataSource alloc] init];
	comfortDataSource.parent = self;

    self.detailPicker.dataSource = comfortDataSource;
    self.detailPicker.delegate = comfortDataSource;

    [self.detailTextView setDelegate:self];
    [self.detailTextView setReturnKeyType:UIReturnKeyDone];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(textFieldFinished:) name: UITextViewTextDidChangeNotification object:nil];
    
    [self.view endEditing:YES];
}

-(IBAction)skip:(id)sender{
    NSLog(@"Skip");
    [delegate didCancelNote];
    
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    details = @"";
    
    [delegate didEnterTripDetails:details];
    [delegate didEnterTripComfort:comfort];
    [delegate saveTrip];
}

-(IBAction)saveDetail:(id)sender{
    NSLog(@"Save Detail");
    [detailTextView resignFirstResponder];
    [detailPicker resignFirstResponder];
    
    [delegate didCancelNote];
    
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    details = detailTextView.text;

    [delegate didEnterTripDetails:details];
    [delegate didEnterTripComfort:comfort];
    [delegate saveTrip];
}

- (void)textFieldFinished:(NSNotification *) notification
{
    if([[[notification object] text] hasSuffix:@"\n"])
    {
        [[notification object] resignFirstResponder];
    }
    
}
- (void) didTapAnywhere:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 5;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (row) {
        case 0:
            comfort = @"";
            break;
        case 1:
            comfort = @"Excellent - no stress!";
            break;
        case 2:
            comfort = @"Good - low stress";
            break;
        case 3:
            comfort = @"Fair - some stress";
            break;
        case 4:
            comfort = @"Poor - pretty stressful";
            break;
        case 5:
            comfort = @"Terrible - high stress!";
            break;
        default:
            comfort = @"";
            break;
    }
}

- (void)dealloc {
    self.delegate = nil;
    self.detailTextView = nil;
    self.detailPicker = nil;
    
    [delegate release];
    [detailTextView release];
    [detailPicker release];
    
    [super dealloc];
}

@end
