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

@end

@implementation TripDetailViewController
@synthesize delegate;
@synthesize detailTextView;

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
    [self.detailTextView becomeFirstResponder];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    detailTextView.layer.borderWidth = 1.0;
    detailTextView.layer.borderColor = [[UIColor blackColor] CGColor];
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 435)];
    scroll.contentSize = CGSizeMake(320, 700);
    scroll.showsHorizontalScrollIndicator = YES;
    
    UIImage* unstoppable = [UIImage imageNamed:@"Unstoppable.png"];
    unstoppable = [unstoppable imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage* great = [UIImage imageNamed:@"Great"];
    great = [great imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage* soso = [UIImage imageNamed:@"SoSo.png"];
    soso = [soso imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage* tired = [UIImage imageNamed:@"Tired.png"];
    tired = [tired imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage* injured = [UIImage imageNamed:@"Injured.png"];
    injured = [injured imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    NSArray *itemArray = [NSArray arrayWithObjects: unstoppable, great, soso, tired, injured, nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    segmentedControl.frame = CGRectMake(21,65,280,50);
    segmentedControl.selectedSegmentIndex = 1;
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:segmentedControl];
    [segmentedControl release];
}


-(void)segmentAction:(UISegmentedControl*)sender {
    
   // UIImage* great = [UIImage imageNamed:@"Great"];
   // great = [great imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
   // [sender setImage:great forSegmentAtIndex:sender.selectedSegmentIndex];
    
}

- (void)MySegmentControlAction:(UISegmentedControl *)segment
{
    if(segment.selectedSegmentIndex == 0)
    {
        // code for the first button, make sure this gets sent to the server
    }
}

-(IBAction)skip:(id)sender{
    NSLog(@"Skip");
    [delegate didCancelNote];
    
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    details = @"";
    
    [delegate didEnterTripDetails:details];
    [delegate saveTrip];
}

-(IBAction)saveDetail:(id)sender{
    NSLog(@"Save Detail");
    [detailTextView resignFirstResponder];
    [delegate didCancelNote];
    
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    details = detailTextView.text;
    
    [delegate didEnterTripDetails:details];
    [delegate saveTrip];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.delegate = nil;
    self.detailTextView = nil;
    
    [delegate release];
    [detailTextView release];
    
    [super dealloc];
}

@end
