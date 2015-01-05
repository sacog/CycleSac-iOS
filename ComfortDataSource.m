//
//  ComfortDataSource.m
//  Cycle Philly
//
//  Created by geostats on 12/19/14.
//
//

#import "ComfortDataSource.h"
#import "CustomView.h"

@implementation ComfortDataSource

@synthesize customPickerArray, pickerTitles, pickerImages, parent;


- (id)init {
	// use predetermined frame size
	self = [super init];
	if (!self) return self;
    
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    
        // ios7 or later
    self.pickerTitles = [NSArray arrayWithObjects:@"Excellent", @"Good", @"Fair", @"Poor", @"Terrible", nil];
    self.pickerImages = [NSArray arrayWithObjects: [UIImage imageNamed:@"Excellent.png"], [UIImage imageNamed:@"Good.png"],
        [UIImage imageNamed:@"Fair.png"], [UIImage imageNamed:@"Poor.png"], [UIImage imageNamed:@"Terrible.png"], nil];
    
    return self;
}

- (void)dealloc
{
    [pickerTitles release];
    [pickerImages release];
	[customPickerArray release];
	[super dealloc];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [pickerTitles count];    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    if(view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 48)];
    }
    else {
        NSArray *viewsToRemove = [view subviews];
        for (UIView *v in viewsToRemove) {
            [v removeFromSuperview];
        }
    }
    
    if([pickerImages count] > 0) {
        UIImage *image = [pickerImages objectAtIndex:row];
        UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        [imageView setFrame:CGRectMake(60, 0, 44, 44)];
        [view addSubview:imageView];
        [imageView release];
    }
    
    CGRect labelFrame = CGRectMake(108, 0, pickerView.frame.size.width, 48);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    label.text = [NSString stringWithFormat:@" %@", [pickerTitles objectAtIndex: row]];
    
    [view addSubview:label];
    [label release];
    return [view autorelease];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [parent pickerView:pickerView didSelectRow:row inComponent:component];
}


@end
