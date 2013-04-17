/** Cycle Atlanta, Copyright 2012, 2013 Georgia Institute of Technology
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

#import "FetchUser.h"
#import "FetchTripData.h"
#import "constants.h"
#import "CycleAtlantaAppDelegate.h"
#import "PersonalInfoViewController.h"
#import "Coord.h"
#import "Trip.h"

//copying something from TripManager. should refactor things in the future.
// use this epsilon for both real-time and post-processing distance calculations
#define kEpsilonAccuracy		100.0

// use these epsilons for real-time distance calculation only
#define kEpsilonTimeInterval	10.0
#define kEpsilonSpeed			30.0

@class TripManager;

@implementation FetchTripData

@synthesize managedObjectContext, receivedData, urlRequest, tripDict, downloadingView, downloadCount;

- (id)init{
    self.managedObjectContext = [(CycleAtlantaAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    return self;
}

- (void)loadTrip:(NSDictionary *)coordsDict{
	NSError *error;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    CLLocationDistance distance = 0;
    Coord *prev = nil;
    

    //Add the trip
    Trip * newTrip = (Trip *)[NSEntityDescription insertNewObjectForEntityForName:@"Trip"
                                                            inManagedObjectContext:self.managedObjectContext] ;
    [newTrip setPurpose:[tripDict objectForKey:@"purpose"]];
    [newTrip setStart:[dateFormat dateFromString:[tripDict objectForKey:@"start"]]];
    [newTrip setUploaded:[dateFormat dateFromString:[tripDict objectForKey:@"stop"]]];
    [newTrip setSaved:[NSDate date]];
    [newTrip setNotes:[tripDict objectForKey:@"notes"]];
    [newTrip setDistance:0]; //should force the dintance to be recalcuate when the trips page is loaded.
    //or better, explicity call the recalculate function so it's done.
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
        NSLog(@"TripManager addCoord error %@, %@", error, [error localizedDescription]);
    }
    //Add the coords
    Coord *newCoord = nil;
    Coord *firstCoord = nil;
    BOOL isFirstCoord = true;
    for(NSDictionary *coord in coordsDict){
        newCoord = (Coord *)[NSEntityDescription insertNewObjectForEntityForName:@"Coord" inManagedObjectContext:self.managedObjectContext];
        //HERE
        [newCoord setAltitude:[NSNumber numberWithDouble:[[coord objectForKey:@"altitude"] doubleValue]]];
        [newCoord setLatitude:[NSNumber numberWithDouble:[[coord objectForKey:@"latitude"] doubleValue]]];
        [newCoord setLongitude:[NSNumber numberWithDouble:[[coord objectForKey:@"longitude"] doubleValue]]];
        [newCoord setRecorded:[dateFormat dateFromString:[coord objectForKey:@"recorded"]]];
        [newCoord setSpeed:[NSNumber numberWithDouble:[[coord objectForKey:@"altitude"] doubleValue]]];
        [newCoord setHAccuracy:[NSNumber numberWithDouble:[[coord objectForKey:@"h_accuracy"] doubleValue]]];
        [newCoord setVAccuracy:[NSNumber numberWithDouble:[[coord objectForKey:@"v_accuracy"] doubleValue]]];
        
        [newTrip addCoordsObject:newCoord];
        
        if(prev){
            distance	+= [self distanceFrom:prev to:newCoord realTime:YES];
        }
        prev = newCoord;
        
        if(isFirstCoord){
            firstCoord = newCoord;
            isFirstCoord = false;
        }
    }
    // update duration
    NSTimeInterval duration = [newCoord.recorded timeIntervalSinceDate:firstCoord.recorded];
    //NSLog(@"duration = %.0fs", duration);
    [newTrip setDuration:[NSNumber numberWithDouble:duration]];
    [newTrip setDistance:[NSNumber numberWithDouble:distance]];
    
    
	if (![self.managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"TripManager addCoord error %@, %@", error, [error localizedDescription]);
	}
    NSLog(@"Trip Download: %d", self.downloadCount);
    if (self.downloadCount <= 1){
        [self.downloadingView loadingComplete:kSuccessFetchTitle delayInterval:.7];
    }
    
    [dateFormat release];

}

- (CLLocationDistance)calculateTripDistance:(Trip*)trip
{
	NSLog(@"calculateTripDistance for trip started %@ having %d coords", trip.start, [trip.coords count]);
	
	CLLocationDistance newDist = 0.;
    	
	// filter coords by hAccuracy
	NSPredicate *filterByAccuracy	= [NSPredicate predicateWithFormat:@"hAccuracy < 100.0"];
	NSArray		*filteredCoords		= [[trip.coords allObjects] filteredArrayUsingPredicate:filterByAccuracy];
	NSLog(@"count of filtered coords = %d", [filteredCoords count]);
	
	if ( [filteredCoords count] )
	{
		// sort filtered coords by recorded date
		NSSortDescriptor *sortByDate	= [[[NSSortDescriptor alloc] initWithKey:@"recorded" ascending:YES] autorelease];
		NSArray		*sortDescriptors	= [NSArray arrayWithObjects:sortByDate, nil];
		NSArray		*sortedCoords		= [filteredCoords sortedArrayUsingDescriptors:sortDescriptors];
		
		// step through each pair of neighboring coors and tally running distance estimate
		
		// NOTE: assumes ascending sort order by coord.recorded
		// TODO: rewrite to work with DESC order to avoid re-sorting to recalc
		for (int i=1; i < [sortedCoords count]; i++)
		{
			Coord *prev	 = [sortedCoords objectAtIndex:(i - 1)];
			Coord *next	 = [sortedCoords objectAtIndex:i];
			newDist	+= [self distanceFrom:prev to:next realTime:NO];
		}
	}
	
	return newDist;
}

- (CLLocationDistance)distanceFrom:(Coord*)prev to:(Coord*)next realTime:(BOOL)realTime
{
	CLLocation *prevLoc = [[[CLLocation alloc] initWithLatitude:[prev.latitude doubleValue]
                                                      longitude:[prev.longitude doubleValue]] autorelease];
	CLLocation *nextLoc = [[[CLLocation alloc] initWithLatitude:[next.latitude doubleValue]
                                                      longitude:[next.longitude doubleValue]] autorelease];
	
	CLLocationDistance	deltaDist	= [nextLoc distanceFromLocation:prevLoc];
	NSTimeInterval		deltaTime	= [next.recorded timeIntervalSinceDate:prev.recorded];
	CLLocationDistance	newDist		= 0.;
	
	// sanity check accuracy
	if ( [prev.hAccuracy doubleValue] < kEpsilonAccuracy &&
        [next.hAccuracy doubleValue] < kEpsilonAccuracy )
	{
		// sanity check time interval
		if ( !realTime || deltaTime < kEpsilonTimeInterval )
		{
			// sanity check speed
			if ( !realTime || (deltaDist / deltaTime < kEpsilonSpeed) )
			{
				// consider distance delta as valid
				newDist += deltaDist;
				
				// only log non-zero changes
				/*
				 if ( deltaDist > 0.1 )
				 {
				 NSLog(@"new dist  = %f", newDist);
				 NSLog(@"est speed = %f", deltaDist / deltaTime);
				 }
				 */
			}
			else
				NSLog(@"WARNING speed exceeds epsilon: %f => throw out deltaDist: %f, deltaTime: %f",
					  deltaDist / deltaTime, deltaDist, deltaTime);
		}
		else
			NSLog(@"WARNING deltaTime exceeds epsilon: %f => throw out deltaDist: %f", deltaTime, deltaDist);
	}
	else
		NSLog(@"WARNING accuracy exceeds epsilon: %f => throw out deltaDist: %f",
			  MAX([prev.hAccuracy doubleValue], [next.hAccuracy doubleValue]) , deltaDist);
	
	return newDist;
}

//after fetching user and trips, send data back to PersonalInfoViewController and TripManager to add into the db

- (void)fetchTripData:(NSDictionary*) tripToLoad statusView:(LoadingView*) statusView downloadCount:(int) downloadCounter{
    self.downloadCount = downloadCounter;
    self.downloadingView = statusView;
    self.tripDict = tripToLoad;
    
    NSMutableString *postBody = [NSMutableString string];
    self.urlRequest = [[NSMutableURLRequest alloc] init] ;
    [urlRequest setURL:[NSURL URLWithString:kFetchURL] ];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    //get the trips one at a time. this is connection heavy but it will return the full trip data.
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"get_coords_by_trip", @"t", [tripDict objectForKey:@"id"], @"q", nil];
    NSString *sep = @"";
    for(NSString * key in postDict) {
        [postBody appendString:[NSString stringWithFormat:@"%@%@=%@",
                                sep,
                                key,
                                [postDict objectForKey:key]]];
        sep = @"&";
    }
    NSLog(@"POST Data: %@", postBody);
    [urlRequest setValue:[NSString stringWithFormat:@"%d", [[postBody dataUsingEncoding:NSUTF8StringEncoding] length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    // create loading view to indicate trip is being uploaded
    //uploadingView = [[LoadingView loadingViewInView:parent.parentViewController.view messageString:kDownloadingUser] retain];
    
    if ( theConnection )
    {
        receivedData=[[NSMutableData data] retain];
    }
    else
    {
        // inform the user that the download could not be made
        NSLog(@"Download failed!");
        
    }
}

#pragma mark NSURLConnection delegate methods


- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	NSLog(@"%d bytesWritten, %d totalBytesWritten, %d totalBytesExpectedToWrite",
		  bytesWritten, totalBytesWritten, totalBytesExpectedToWrite );
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	// this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	NSLog(@"didReceiveResponse: %@", response);
	
	NSHTTPURLResponse *httpResponse = nil;
	if ( [response isKindOfClass:[NSHTTPURLResponse class]] &&
		( httpResponse = (NSHTTPURLResponse*)response ) )
	{
		BOOL success = NO;
		NSString *title   = nil;
		NSString *message = nil;
		switch ( [httpResponse statusCode] )
		{
			case 200:
			case 201:
				success = YES;
				title	= kSuccessFetchTitle;
				message = @"Coords downloaded";//kFetchSuccess;
				break;
			case 500:
			default:
				title = @"Internal Server Error";
				message = kServerError;
		}
		
		NSLog(@"%@: %@", title, message);
        
        // DEBUG
        NSLog(@"+++++++DEBUG didReceiveResponse %@: %@", [response URL],[(NSHTTPURLResponse*)response allHeaderFields]);
        
        if ( success )
		{
            NSLog(@"Coord Download Success.");
            
            //[uploadingView loadingComplete:kSuccessTitle delayInterval:.7];
		} else {
            
            //[uploadingView loadingComplete:kServerError delayInterval:1.5];
        }
	}
	
    // it can be called multiple times, for example in the case of a
	// redirect, so each time we reset the data.
	
    // receivedData is declared as a method instance elsewhere
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
	[receivedData appendData:data];
    //	[activityDelegate startAnimating];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
	
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
    
    // TODO: is this really adequate...?
    //[uploadingView loadingComplete:kConnectionError delayInterval:1.5];
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSString *dataString = [[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"+++++++DEBUG: Received %d bytes of data", [receivedData length]);
    NSError *error;
    NSString *jsonString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    NSDictionary *coordsDict = [NSJSONSerialization JSONObjectWithData: [jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                         options: NSJSONReadingMutableContainers
                                                           error: &error];
    [self loadTrip:coordsDict];
    
    //Debugging received data
//    NSData *JsonDataCoords = [[NSData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:JSON options:0 error:&error]];
//    NSLog(@"%@", [[[NSString alloc] initWithData:JsonDataCoords encoding:NSUTF8StringEncoding] autorelease] );

    
    // release the connection, and the data object
    [connection release];
    [receivedData release];
    [jsonString release];
}

@end
