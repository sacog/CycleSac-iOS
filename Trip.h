//
//  Trip.h
//  Cycle Atlanta
//
//  Created by Guo Anhong on 13-2-26.
//  adapted for CyclePhilly 2013, CodeforPhilly.org
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Coord, User;

@interface Trip : NSManagedObject

@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSDate * start;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * comfort;
@property (nonatomic, retain) NSDate * uploaded;
@property (nonatomic, retain) NSString * purpose;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSDate * saved;
@property (nonatomic, retain) NSSet *coords;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) User *user;
@end

@interface Trip (CoreDataGeneratedAccessors)

- (void)addCoordsObject:(Coord *)value;
- (void)removeCoordsObject:(Coord *)value;
- (void)addCoords:(NSSet *)values;
- (void)removeCoords:(NSSet *)values;

@end
