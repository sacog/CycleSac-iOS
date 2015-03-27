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
 *   Updated/Modified for Atlanta's app deployment. Based on the
 *   CycleTracks codebase for SFCTA.
 *
 ** CycleTracks, Copyright 2009,2010 San Francisco County Transportation Authority
 *                                    San Francisco, CA, USA
 *
 *   @author Matt Paul <mattpaul@mopimp.com>
 *
 *   This file is part of CycleTracks.
 *
 *   CycleTracks is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   CycleTracks is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with CycleTracks.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  CustomPickerDataSource.h
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/22/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>

// Check system version to support picker
// picker styles for iOS >= 7.1,
// 7.0, which gets its own weird style,
// and 5/6
#define IOS_6_OR_EARLIER ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)

// Trip Purpose descriptions
#define kDescCommute	@"Biking between home and your primary work location."
#define kDescSchool		@"Biking to or from school or college."
#define kDescWork		@"Biking to or from a business-related meeting, function, or work-related errand for your job."
#define kDescExercise	@"Biking for exercise or for fun."
#define kDescSocial		@"Biking to or from a socal activity (e.g. to a friend's house, the park, a restaurant, the movies)."
#define kDescErrand		@"Biking to attend to personal business (e.g. grocery shopping, banking, doctor's visit, going to the gym)."
#define kDescOther		@"If none of the other reasons apply to this trip, you can enter trip comments after saving your trip to tell us more."

// Issue descriptions
#define kIssueDescPavementIssue  @"Select this option if the the road needs repairs (pothole, rough concrete, gravel in the road, manhole cover, sewer grate)."
#define kIssueDescTrafficSignal  @"Select this option if the traffic signal is malfunctioning."
#define kIssueDescEnforcement    @"Select this option to note bike lane obstructions (cars, trucks in bike lanes etc.)."
#define kIssueDescNeedParking    @"Select this option if you would like to see secure bike parking in this location."
#define kIssueDescBikeLaneIssue  @"Select this option if the bike lane needs improvement (it ends abruptly or needs repainting)."
#define kIssueDescNoteThisSpot   @"Misc. comments about needed improvements."

#define kDescNoteThis   @"Select an issue or note an asset."

// Asset descriptions
#define kAssetDescBikeParking   @"Note if secure bike parking is in this location."
#define kAssetDescBikeShops @"Note if bike shops are in this location."
#define kAssetDescPublicRestrooms   @"Note if public restrooms are in this location."
#define kAssetDescSecretPassage @"Note for routes outside normal bike lanes."
#define kAssetDescWaterFountains    @"Note if water is available in this location."
#define kAssetDescNoteThisSpot  @"Note any misc. assets in this location."


@interface CustomPickerDataSource : NSObject <UIPickerViewDataSource, UIPickerViewDelegate>
{
	NSArray	*customPickerArray;
	id<UIPickerViewDelegate> parent;
    NSInteger pickerCategory;
}

@property (nonatomic, retain) NSArray *customPickerArray;
@property (nonatomic, retain) NSArray *pickerTitles;
@property (nonatomic, retain) NSArray *pickerImages;
@property (nonatomic, retain) id<UIPickerViewDelegate> parent;

@end
