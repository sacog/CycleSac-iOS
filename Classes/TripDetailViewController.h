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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TripPurposeDelegate.h"
#import "ComfortDataSource.h"

@interface TripDetailViewController : UIViewController<UINavigationControllerDelegate, UITextViewDelegate,
    UIPickerViewDataSource, UIPickerViewDelegate>
{
    id <TripPurposeDelegate> delegate;
    UITextView *detailTextView;
    UIPickerView *detailPicker;
    NSInteger pickerCategory;
    NSString *details;
    NSString *comfort;
    ComfortDataSource	*comfortDataSource;
    UITapGestureRecognizer *tapRecognizer;
}

@property (nonatomic, retain) id <TripPurposeDelegate> delegate;

@property (nonatomic, retain) IBOutlet UITextView *detailTextView;

@property (retain, nonatomic) IBOutlet UIPickerView *detailPicker;

@property (nonatomic, retain) ComfortDataSource *comfortDataSource;

@property (nonatomic) UITapGestureRecognizer *tapRecognizer;

-(IBAction)skip:(id)sender;
-(IBAction)saveDetail:(id)sender;

@end
